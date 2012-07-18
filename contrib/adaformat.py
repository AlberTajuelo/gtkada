#!/usr/bin/env python

"""
Various formatting classes for Ada code
"""

import sys
import re
import copy
from collections import namedtuple, defaultdict

# A lot of subprograms below take a "lang" parameter, which indicates how
# values should be converted:
#
#     LANG should be one of:
#        "ada->ada":  the value of the parameter is read from an Ada
#           value (as subprogram whose code is Ada) and passed to a
#           similar subprogram. No conversion needed.
#        "ada->c": all Ada values will be converted to their C equivalent,
#           since the target subprogram's code is written in C.
#        "c->ada": case of C callbacks: the value is passed from C to
#           an Ada subprogram in the user application.

class CType(object):
    """Describes the types in the various cases where they can be used.

       A type applies either to an Ada subprogram written in Ada, or to an
       Ada subprogram implemented via a pragma Import. The latter case is
       abbreviated to a "c" subprogram below.

       For returned values, various pieces of information are needed:
              (adatype, ctype, converter, tmpvars=[])
       They are used as:
              function ... (...) return adatype is
                  function ... (...) return ctype;
                  pragma Import (C, ..., "...");
                  Tmp : ctype;
                  tmpvars;
              begin
                  ...;   --  pre-call code
                  Tmp := ... (...);
                  ...;   --  post-call code
                  return <converter % Tmp>
              end;
       In the example above, "Tmp" is only created if there is some post-call
       code, otherwise we avoid the temporary variable.
       The variable "Tmp" is automatically added, and does not need to
       be specified manually in tmpvars.

       if converted contains the string "%(tmp)s", then we always use a
       temporary variable of type adatype. This is used for instance when the
       variable is initialized through a procedure call rather than a function
       call.
              function ... (...) return adatype is
                  function ... (...) return ctype;
                  pragma Import (C, ..., "...")
                  Tmp_Result : adatype;
                  tmpvars;
              begin
                  ...   --  pre-call code
                  convert % {"var":..., "tmp":"Tmp_Result"};  -- proc call
                  ...   --  post-call code
                  return Tmp_Result;
              end;
       The variable "Tmp_Result" is automatically added, and does not need to
       be specified manually in tmpvars.

       Converter will contain a single %s which will be replaced by the
       name of the temporary variable that holds the result of the call
       to the function.
    """

    def __init__(self, ada, property):
        self.ada = ada       # Fully qualified Ada type
        self.property = property

        self.is_ptr = False
        self.param = ada     # type as parameter
        self.cparam = ada    # type for Ada subprograms binding to C
        self.cleanup = None  # If set, a tmp variable is created to hold the
                             # result of convert during the call, and is then
                             # free by calling this cleanup. Use "%s" as the
                             # name of the variable.
        self.isArray = False

        # In some cases, Ada provides a special value for a parameter that
        # indicates that NULL should be passed to C. Such a test is only done
        # when allow_none is True. val_or_null is then a function in charge
        # of converting the value to a System.Address unless it is equal to
        # a specific null value.

        self.allow_none = False
        self.val_or_null = None

        # If True, the value returned from C must be freed by the caller

        self.transfer_ownership = False

    def convert_from_c(self):
        """How to convert the value returned from C to Ada.
           This function returns a tuple:
              [0] = name of the Ada type
              [1] = name of the C type
              [2] = Conversion from C type to Ada type. The value is read
                    from "%(var)s". It can also use "%(tmp)s" if a temporary
                    variable is needed.
              [3] = List of needed temporary variables (except for the one
                    corresponding to "%(tmp)s".
        """
        return (self.param, self.cparam, "%(var)s", [])

    def convert_from_c_add_with(self, pkg):
        """Add the "with" statements needed to do the conversion stated
           in convert_from_c().
        """
        pass

    def convert_to_c(self):
        """How to convert from Ada parameter to C parameter. If it uses %(tmp)s,
           we assume the converter sets the value of the temporary variable
           itself.
           It can also use %(var)s which will be substituted by the name of the
           parameter.
           Otherwise, it is used as " Tmp := <convert>".
           It might be necessary to also override add_with() to add the necessary
           with statements.
        """

        if self.allow_none and self.val_or_null:
            self.cparam = "System.Address"
            return "%s (%%(var)s'Address)" % self.val_or_null
        else:
            return "%(var)s"

    def direct_cmap(self):
        """Whether the parameter can be passed as is to C"""
        return self.convert_to_c() == "%(var)s"

    def as_property(self):
        """The type to use for the property"""
        return self.property

    def as_return(self, pkg=None):
        """See CType documentation for a description of the returned tuple"""

        returns = self.convert_from_c()

        if returns and pkg:
            # Avoid full dotted notation when inside the package itself
            return (returns[0].replace("%s." % pkg.name, ""),
                    returns[1].replace("%s." % pkg.name, ""),
                    returns[2],
                    returns[3])
        else:
            return returns

    def record_field_type(self, pkg=None):
        """The type to use when self is used in a record.
           [pkg] should be the current package, to avoid fully qualified name
           that reference that package.
        """
        return self.as_c_param(pkg=pkg)

    def as_ada_param(self, pkg):
        """Converts self to a description for an Ada parameter to a
           subprogram.
           `pkg` is the package in which we insert the name. It is used to
           avoid qualified name when in the same package
        """
        # Do not fully qualify within the current package
        p = self.ada[:self.ada.rfind(".")]
        return self.param.replace("%s." % pkg.name, "")

    def as_c_param(self, pkg=None):
        """Returns the C type (as a parameter to a subprogram that imports
           a C function)
        """
        if pkg:
            return self.cparam.replace("%s." % pkg.name, "")
        else:
            return self.cparam

    def as_call(
        self, name, pkg, wrapper="%s", lang="ada->ada", mode="in", value=None):
        """'name' represents a parameter of type 'self'.
           'pkg' is the Package instance in which the call occurs.
           'wrapper' is used in the call itself, and %s is replaced by the
              name of the variable (or the temporary variable).
           Returns an instance of VariableCall.
           See comments at the beginning of this package for valid LANG values
        """
        assert(lang in ("ada->ada", "c->ada", "ada->c"))

        if lang == "ada->ada":
            return VariableCall(
                call=wrapper % name, precall='', postcall='', tmpvars=[])

        elif lang == "ada->c":
            returns = self.convert_from_c()
            ret = returns and returns[2]

            additional_tmp_vars = [] if not returns else returns[3]

            if ret and ret != "%(var)s" and mode != "in":
                # An "out" parameter for an enumeration requires a temporary
                # variable: Internal(Enum'Pos (Param)) is invalid
                tmp = "Tmp_%s" % name
                tmpvars = [Local_Var(name=tmp, type=self.cparam, aliased=True)]

                if "%(tmp)s" in ret:
                    tmp2 = "Tmp2_%s" % name
                    tmpvars += [Local_Var(name=tmp2, type=self.cparam)]
                    postcall = "%s; %s := %s;" % (
                        ret % {"var": tmp, "tmp": tmp2},
                        name,
                        tmp2)
                else:
                    postcall = "%s := %s;" % (
                        name,
                        ret % {"var": tmp})

                call = VariableCall(
                    call=wrapper % tmp,
                    precall="",
                    postcall=postcall,
                    tmpvars=tmpvars + additional_tmp_vars)

            elif "%(tmp)" in self.convert_to_c():
                # The conversion sets the temporary variable itself
                tmp = "Tmp_%s" % name
                call = VariableCall(
                    call=wrapper % tmp,
                    precall=self.convert_to_c() % {"var":name, "tmp":tmp},
                    postcall=self.cleanup % tmp,
                    tmpvars=[Local_Var(name=tmp, type=self.cparam)]
                       + []) # additional_tmp_vars

            elif self.cleanup:
                tmp = "Tmp_%s" % name
                conv = self.convert_to_c() % {"var":name}

                # Initialize the temporary variable with a default value, in case
                # it is an unconstrained type (a chars_ptr_array for instance)
                call = VariableCall(
                    call=wrapper % tmp,
                    precall='',
                    postcall=self.cleanup % tmp,
                    tmpvars=[Local_Var(
                        name=tmp, type=AdaType(self.cparam), default=conv)])

            else:
                conv = self.convert_to_c() % {"var":name}
                call = VariableCall(
                    call=wrapper % conv, precall='', postcall="", tmpvars=[])

            return call

        elif lang == "c->ada":
            ret = self.convert_from_c()

            # Do we need a temporary variable ?
            # An "out" parameter for an enumeration requires a temporary
            # variable: Internal(Enum'Pos (Param)) is invalid

            ret_convert = ret and ret[2]

            if ret_convert and ret_convert != "%(var)s" and mode != "in":
                tmp = "Tmp_%s" % name
                tmpvars = [Local_Var(name=tmp, type=self.ada)] + ret[3]

                if "%(tmp)s" in ret_convert:
                    tmp2 = "Tmp2_%s" % name
                    tmpvars += [Local_Var(name=tmp2, type=self.cparam)]
                    postcall = "%s; %s := %s;" % (
                        ret_convert % {"var": tmp, "tmp": tmp2},
                        name,
                        tmp2)
                else:
                    postcall = "%s := %s;" % (
                        name,
                        self.convert_to_c() % {"var": tmp})

                return VariableCall(
                    call=wrapper % tmp,
                    precall="",
                    postcall=postcall,
                    tmpvars=tmpvars)

            else:
                return VariableCall(
                    call=wrapper % (ret[2] % {"var": name}),
                    precall='', postcall='', tmpvars=ret[3])

    def add_with(self, pkg=None):
        """Add required withs for this type"""
        if pkg:
            pkg.add_with(package_name(self.ada))

        if pkg and self.allow_none and self.val_or_null:
            base = self.val_or_null
            pkg.add_with(package_name(base), specs=False)

    def copy(self):
        """Return a copy of self, possibly modifying some properties."""
        return copy.deepcopy(self)


class Enum(CType):
    def __init__(self, ada, property=None):
        base = ada[ada.rfind(".") + 1:] or ada
        if property is None:
            CType.__init__(self, ada, "Gtk.Enums.Property_%s" % base)
        else:
            CType.__init__(self, ada, property)

        if self.ada.lower() == "boolean":
            self.cparam = "Integer"
        else:
            # Do not convert enumerations to integers. We want to pass the
            # associated literal in case the enumeration in C does not start
            # at 0, or as holes in the series.
            self.cparam = self.ada

    def convert_from_c(self):
        if self.ada.lower() == "boolean":
            return (self.param, self.cparam, "%s'Val (%%(var)s)" % self.ada, [])
        else:
            return super(Enum, self).convert_from_c()

    def convert_to_c(self):
        if self.ada.lower() == "boolean":
            return "%s'Pos (%%(var)s)" % self.ada
        else:
            return super(Enum, self).convert_to_c()

    def record_field_type(self, pkg=None):
        if pkg:
            return self.ada.replace("%s." % pkg.name, "")
        else:
            return self.ada

    @staticmethod
    def register_ada_decl(pkg, ctype, ada=None):
        """Register an enumeration type.
        [pkg] is the name of the current package in which the enumeration
        will be defined.
        """

        # Compute the Ada name automatically if needed.
        if not ada:
            ada = naming.type(name="", cname=ctype).ada

        full_name = "%s.%s" % (pkg, ada)
        t = Enum(full_name, "%s.Property_%s" % (pkg, ada))
        naming.add_type_exception(cname=ctype, type=t)

        # Add the special cases for properties that GIR file use
        t = ctype.replace("Pango", "Pango.").replace("Gdk", "Gdk.")
        naming.girname_to_ctype[t] = ctype


class GObject(CType):
    def __init__(self, ada, userecord=True):
        CType.__init__(self, ada, "Glib.Properties.Property_Object")
        self.cparam = "System.Address"
        self.is_ptr = False
        self.classwide = False  # Parameter should include "'Class"
        self.userecord = userecord  # Parameter should be "access .._Record"

    def convert_from_c(self):
        stub = "Stub_%s" % base_name(self.ada)

        if self.ada == "Glib.Object.GObject":
            conv = "Get_User_Data (%%(var)s, %s)" % stub
        else:
            conv = "%s (Get_User_Data (%%(var)s, %s))" % (self.ada, stub)

        return (self.param,
                self.cparam,
                conv,
                [Local_Var(
                    stub, AdaType("%s_Record" % self.ada, in_spec=False))])

    def convert_to_c(self):
        if self.allow_none:
            return "Get_Object_Or_Null (GObject (%(var)s))"
        else:
            return "Get_Object (%(var)s)"

    def as_ada_param(self, pkg):
        if self.userecord:
            prefix = "" if self.allow_none else "not null "

            if self.classwide:
                self.param = "%saccess %s_Record'Class" % (prefix, self.ada)
            else:
                self.param = "%saccess %s_Record" % (prefix, self.ada)

        return super(GObject, self).as_ada_param(pkg)

    def copy(self):
        result = CType.copy(self)
        return result

class Tagged(GObject):
    """Tagged types that map C objects, but do not derive from GObject"""

    def convert_from_c(self):
        return (self.param, self.cparam, "From_Object (%(var)s)", [])

    def as_ada_param(self, pkg):
        # Make sure to bind as a CType here, not as a GOBject
        return CType.as_ada_param(self, pkg)

class UTF8(CType):
    def __init__(self):
        CType.__init__(self, "UTF8_String", "Glib.Properties.Property_String")
        self.cparam = "Interfaces.C.Strings.chars_ptr"
        self.cleanup = "Free (%s);"

    def convert_from_c(self):
        if self.transfer_ownership:
            return (self.param, self.cparam,
                    "Gtkada.Bindings.Value_And_Free (%(var)s)", [])
        else:
            return (self.param, self.cparam,
                    "Interfaces.C.Strings.Value (%(var)s)", [])

    def convert_from_c_add_with(self, pkg):
        if self.transfer_ownership and pkg:
            pkg.add_with("Gtkada.Bindings", specs=False)

    def convert_to_c(self):
        if self.allow_none:
            return 'if %(var)s = "" then %(tmp)s :=' \
                + ' Interfaces.C.Strings.Null_Ptr; else'\
                + ' %(tmp)s := New_String (%(var)s); end if;'
        else:
            return "New_String (%(var)s)"

    def add_with(self, pkg):
        super(UTF8, self).add_with(pkg)
        if pkg:
            pkg.add_with("Interfaces.C.Strings", specs=False)


class UTF8_List(CType):
    def __init__(self):
        CType.__init__(self, "GNAT.Strings.String_List", "")
        self.cparam = "Interfaces.C.Strings.chars_ptr_array"
        self.cleanup = "GtkAda.Types.Free (%s);"

    def convert_from_c(self):
        return (self.param, "chars_ptr_array_access",
                "To_String_List (%(var)s.all)", [])

    def record_field_type(self, pkg=None):
        return "Interfaces.C.Strings.char_array_access"

    def convert_to_c(self):
        return "From_String_List (%(var)s)"

    def add_with(self, pkg=None):
        super(UTF8_List, self).add_with(pkg=pkg)
        if pkg:
            pkg.add_with("GNAT.Strings", specs=True)
            pkg.add_with("Gtkada.Types", specs=False)
            pkg.add_with("Interfaces.C.Strings", specs=False)
            pkg.add_with("Gtkada.Bindings", specs=False)


class Proxy(CType):
    def __init__(self, ada, property=None, val_or_null=None):
        """[null_value] is used when GIR indicates the parameter has
           allow-none=1, and is used to test whether we should pass NULL
           to C or a pointer to the Ada data.
        """

        if property is None:
            CType.__init__(self, ada, "Glib.Properties.Property_Boxed")
        else:
            CType.__init__(self, ada, property)

        self.val_or_null = val_or_null

    @staticmethod
    def register_ada_record(pkg, ctype, ada=None):
        """Register a <record> type.
        [pkg] is the name of the current package in which the enumeration
        will be defined.
        """

        adaname = base_name(ada or naming.type(name="", cname=ctype).ada)
        full_name = "%s.%s" % (pkg, adaname)
        t = Proxy(full_name)
        naming.add_type_exception(cname="%s*" % ctype, type=t)
        naming.add_type_exception(cname=ctype, type=t)


class Callback(CType):
    def __init__(self, ada):
        CType.__init__(self, ada, "")
        self.cparam = "System.Address"

    def convert_from_c(self):
        # Never return such a callback to Ada (because in fact we are pointing
        # to a function in one of the bodies of GtkAda, not the actual user
        # callback.
        return None

    def convert_to_c(self):
        return "%(var)s'Address"


class Interface(CType):
    def __init__(self, ada):
        CType.__init__(self, ada, "")
        self.cparam = ada
        self.is_ptr = False


class List(CType):
    def __init__(self, ada):
        CType.__init__(self, ada, "Glib.Properties.Property_Object")
        self.__adapkg = ada[:ada.rfind(".")]
        self.cparam = "System.Address"
        self.is_ptr = False

    def convert_from_c(self):
        return (   # Use %(tmp)s so forces the use of temporary var.
            self.param, self.cparam,
            "%s.Set_Object (%%(tmp)s, %%(var)s)" % self.__adapkg, [])

    @staticmethod
    def register_ada_list(pkg, ada, ctype, single=False):
        """Register a list of GObject instantiated in Ada"""
        if single:
            gtype = "GSlist"
            name  = "SList"
        else:
            gtype = "Glist"
            name = "List"

        listCname = "%s%s" % (ctype, name)  # Default list name
        ada = ada or naming.type(cname=listCname).ada

        t = List("%s.%s.%s" % (pkg, ada, gtype))
        naming.add_type_exception(listCname, t)

    def convert_to_c(self):
        return "%s.Get_Object (%%(var)s)" % self.__adapkg

    def add_with(self, pkg=None):
        # A list comes from an instantiation (pkg.instance.glist), so we need
        # to skip backward two "."
        if pkg:
            p = self.ada.rfind(".")
            if p != -1:
                p = self.ada[:p].rfind(".")
                if p != -1:
                    pkg.add_with(self.ada[:p], specs=True)


class AdaType(CType):
    def __init__(self, adatype, pkg=None, in_spec=True, ctype="",
                 convert="%(var)s"):
        """The 'adatype' type is represented as 'ctype' for subprograms
           that import C functions. The parameters of that type are converted
           from Ada to C by using 'convert'. 'convert' must use '%s' once
           to indicate where the name of the parameter should go
        """
        CType.__init__(self, adatype, "")
        self.param   = adatype
        self.cparam  = ctype or adatype
        self.__convert = convert
        self.cleanup = None
        self.is_ptr  = adatype.startswith("access ")

        # ??? Why do we need to call this explicitly ?
        if pkg:
            self.add_with(pkg)

    def convert_to_c(self):
        return self.__convert


class AdaNaming(object):
    def __init__(self):
        self.cname_to_adaname = {}  # c methods to Ada subprograms
        self.girname_to_ctype = {}  # gir names to C types
        self.exceptions = {}        # naming exceptions
        self.type_exceptions = {}   # C types to CType instances

    def add_type_exception(self, cname, type, override=False):
        """Declares a new type exception, unless there already existed
           one for that cname.
        """
        assert(isinstance(type, CType))
        if override or cname not in self.type_exceptions:
            self.type_exceptions[cname] = type

    def add_cmethod(self, cname, adaname):
        """Register the mapping from c method's name to Ada subprogram.
           This is used to replace C function names in the documentation
           with their Ada equivalent"""
        self.cname_to_adaname[cname] = adaname

    def add_girname(self, girname, ctype):
        """Maps a GIR's "name" attribute to its matching C type.
           This is used to resolve such names in the documentation and in
           properties types.
        """
        self.girname_to_ctype[girname] = ctype

    def ctype_from_girname(self, girname):
        """Return the C type corresponding to a GIR name"""

        if not girname:
            return ""
        elif girname.startswith("Gdk") or girname.startswith("Gtk"):
            default = girname
        else:
            default = "Gtk%s" % girname

        return self.girname_to_ctype.get(girname, default)

    def adamethod_name(self, cname, warning_if_not_found=True):
        """Return the ada name corresponding to the C method's name"""
        try:
            return self.cname_to_adaname[cname]
        except KeyError:
            if warning_if_not_found and cname.lower().startswith("gtk_"):
                print "Name quoted in doc has no Ada binding: %s" % cname
            self.cname_to_adaname[cname] = cname  # Display warning once only
            return cname

    def case(self, name):
        """Return the proper casing to use for 'name', taking keywords
           into account. This is for packages.
        """
        name = self.__camel_case_to_ada(name.replace("-", "_")).title()
        if name.endswith("_"):
            name = name[:-1]

        return self.protect_keywords(name)

    def protect_keywords(self, name):
        return ".".join(self.exceptions.get(n, n) for n in name.split("."))

    def __camel_case_to_ada(self, name):
        """Converts a name with CamelCase to Camel_Case"""

        if not name:
            return name

        result = name[0]
        prev = result
        prev_is_underscore = False
        prev_is_upper = True

        for r in name[1:]:
            if prev != "_" \
                    and prev != "." \
                    and not prev.isupper() \
                    and r.isupper():
                result += "_%s" % r
            else:
                result += r

            prev = r

        return result

    def __full_type_from_girname(self, girname):
        """Return the type description from a GIR name"""
        return self.type_exceptions.get(
            girname,  # First try GIR name as is in the table (gint, ...)
            self.type_exceptions.get(
                self.ctype_from_girname(girname), # Else the C type

                # Else return the GIR name itself
                Proxy(self.__camel_case_to_ada(girname))))

    def type(self, name="", cname=None, pkg=None, isArray=False,
             allow_access=True, allow_none=False, userecord=True, useclass=True,
             transfer_ownership=False):
        """Build an instance of CType for the corresponding cname.
           A type a described in a .gir file
           'pkg' is an instance of Package, to which extra
           with clauses will be added if needed.
           'isArray' should be true for an array of the simple type 'name'.
           'allow_access' should be True if the parameter can be represented
           as 'access Type', rather than an explicit type, in the case of
           GObject descendants.
           If `allow_none' is True, then an empty string maps to a
           NULL pointer in C, rather than an empty C string. For a GObject,
           the parameter is passed as "access" rather than "not null access".
           'use_record' is only used for GObject types.
        """

        if cname == "gchar**" or name == "array_of_utf8":
            t = UTF8_List()
        elif cname == "void":
            return None
        elif name == "utf8" or cname == "gchar*" or cname == "char*":
            t = UTF8()
        elif cname:
            # Check whether the C type, including trailing "*", maps
            # directly to an Ada type.
            #t = self.type_exceptions.get(
            #    cname,
            #    Proxy(self.__camel_case_to_ada(cname)))
            t = self.__full_type_from_girname(cname)
            is_ptr = False

            if t.ada[-1] == "*":
                # No, try without the trailing "*"
                t = self.__full_type_from_girname(cname[0:-1])

                if t.ada[-1] != "*":
                    is_ptr = True    # Yes, so we had a pointer
                else:
                    basename = cname[0:-1] # Remove all "*"
                    if basename[-1] == "*":
                        basename = basename[0:-1]
                    t = self.__full_type_from_girname(basename)

            if not isinstance(t, GObject) \
               and not isinstance(t, Interface):
                t.is_ptr = is_ptr
        else:
            t = self.__full_type_from_girname(name)
            t.is_ptr = cname and cname[-1] == '*'

        t = t.copy()
        t.isArray = isArray
        t.classwide = useclass
        t.allow_none = allow_none
        t.userecord = userecord
        t.transfer_ownership = transfer_ownership

        # Needs to be called last, since the output might depend on all the
        # attributes set above

        t.add_with(pkg)

        return t


naming = AdaNaming()


def max_length(iter):
    """Return the length of the longuest element in iter"""
    longuest = 0
    for f in iter:
        longuest = max(longuest, len(f))
    return longuest


def fill_text(text, prefix, length, firstLineLength=0):
    """Split TEXT on several lines (with a given max length and a prefix).
    """

    line = ""
    result = []
    maxLen = firstLineLength or length - len(prefix)

    text = text.replace("\n\n", "\n<br>")

    # Do we have a list item ? If yes, preserve the indentation

    if text.lstrip().startswith("* "):
        line += text[:text.find("*")]

    for w in text.split():  # for each word (this loses whitespaces)
        if w.startswith("<br>"):
            result.append(line)
            maxLen = length - len(prefix)
            line = w[4:]

        elif len(line) + len(w) + 1 > maxLen:
            result.append(line)
            maxLen = length - len(prefix)
            line = w

        elif w:
            line += " " + w

    if line != "":
        result.append(line)

    return ("\n" + prefix).join(result)


def cleanup_doc(doc):
    """Replaces C features in the doc with appropriate Ada equivalents"""

    def replace_type(x):
        t = naming.type(x.group(1))
        t.userecord = False
        return t.ada

    # get_package might have been called before we had the XML node
    # from the Gir file, and therefore no doc for the package. We can
    # now override it, unless it came from binding.xml

    subp = re.compile("([\S_]+)\(\)")
    doc = subp.sub(lambda x: naming.adamethod_name(x.group(1)), doc)

    types = re.compile("#([\w_]+)")
    doc = types.sub(replace_type, doc)

    params = re.compile("@([\w_]+)")
    doc = params.sub(lambda x: x.group(1).title(), doc)

    enums = re.compile("%([A-Z][\w_]+)")
    doc = enums.sub(lambda x: naming.adamethod_name(x.group(1)), doc)

    doc = doc.replace("<emphasis>", "*") \
        .replace("</emphasis>", "*") \
        .replace("<literal>", "'") \
        .replace("</literal>", "'") \
        .replace("<firstterm>", "'") \
        .replace("</firstterm>", "'") \
        .replace("<![CDATA[", "") \
        .replace("]]>", "") \
        .replace("&nbsp;", " ") \
        .replace("<parameter>", "'") \
        .replace("</parameter>", "'") \
        .replace("<filename>", "'") \
        .replace("</filename>", "'") \
        .replace("<footnote>", "[") \
        .replace("</footnote>", "]") \
        .replace("<keycap>", "'") \
        .replace("</keycap>", "'") \
        .replace("<keycombo>", "[") \
        .replace("</keycombo>", "]") \
        .replace("<entry>", "\n\n") \
        .replace("</entry>", "") \
        .replace("<row>", "") \
        .replace("</row>", "") \
        .replace("<tbody>", "") \
        .replace("</tbody>", "") \
        .replace("</tgroup>", "") \
        .replace("<informaltable>", "") \
        .replace("</informaltable>", "") \
        .replace("<note>", "\nNote: ") \
        .replace("</note>", "")

    doc = re.sub("<tgroup[^>]*>", "", doc)
    doc = re.sub("<term><parameter>(.*?)</parameter>&nbsp;:</term>",
                 r"\1:", doc)

    # Lists

    doc = re.sub("<listitem>(\n?<simpara>|\n?<para>)?", "\n\n   * ", doc)

    doc = doc.replace("</para></listitem>", "") \
        .replace("</listitem>", "") \
        .replace("<simpara>", "") \
        .replace("</simpara>", "") \
        .replace("<para>", "\n\n") \
        .replace("</para>", "")

    # Definition of terms (variablelists)

    doc = doc.replace("<variablelist>", "") \
        .replace("</variablelist>", "") \
        .replace("<varlistentry>", "") \
        .replace("</varlistentry>", "") \
        .replace("<term>", "'") \
        .replace("</term>", "'")

    doc = re.sub("<variablelist[^>]*>", "", doc)
    doc = re.sub("<title>(.*?)</title>", r"\n\n== \1 ==\n\n", doc)
    doc = re.sub("<refsect\d[^>]*>", "", doc)
    doc = re.sub("</refsect\d>", "", doc)

    doc = doc.replace("<example>", "") \
             .replace("</example>", "") \
             .replace("<informalexample>", "") \
             .replace("</informalexample>", "") \
             .replace("<itemizedlist>", "").replace("</itemizedlist>", "") \
             .replace("<orderedlist>", "").replace("</orderedlist>", "") \
             .replace("&percnt;", "%") \
             .replace("&lt;", "<").replace("&gt;", ">") \
             .replace("&ast;", "*") \
             .replace("<programlisting>", "\n\n__PRE__<programlisting>")

    doc = re.sub("<programlisting>(.*?)</programlisting>",
                 lambda m: re.sub(
            "\n\n+", "\n", indent_code(m.group(1), addnewlines=False)),
                 doc,
                 flags=re.DOTALL or re.MULTILINE)

    doc = re.sub("\n\n\n+", "\n\n", doc)

    return doc


def format_doc(doc, indent, separate_paragraphs=True, fill=True):
    """Transform the doc from a list of strings to a single string"""

    result = ""
    prev = ""

    # Make sure the doc is a list of paragraphs

    if not isinstance(doc, list):
        doc = [doc]

    # Cleanup the XML tags in each paragraph. This could result in
    # new paragraphs being created

    cleaned = []

    for d in doc:
        d = cleanup_doc(d)
        if fill:
            cleaned.extend(d.split("\n\n"))
        else:
            cleaned.append(d)

    prefix = "\n" + indent + "--"

    for d in cleaned:

        # Separate paragraphs with an empty line, unless it is a markup
        # or we are at the end
        if separate_paragraphs:
            if prev != "" and not prev.lstrip().startswith("<"):
                result += prefix

        if d:
            if d.lstrip().startswith("__PRE__"):
                d = d.lstrip()[7:]
                result += "".join(prefix + " " + p for p in d.splitlines())
            elif fill:
                result += prefix + " "
                result += fill_text(d, indent + "--  ", 79)
            else:
                result += "".join(prefix + " " + p for p in d.splitlines())

            prev = d

    if result and separate_paragraphs and result[0] == "\n":
        result = result[1:]

    return result


def box(name, indent="   "):
    return indent + "-" * (len(name) + 6) + "\n" \
            + indent + "-- " + name + " --\n" \
            + indent + "-" * (len(name) + 6)


def indent_code(code, indent=3, addnewlines=True):
    """Return code properly indented and split on several lines.
       These are heuristics only, not perfect.
    """
    body = code.strip()
    if not body:
        return ""

    if addnewlines:
        # Add newlines where needed, but preserve existing blank lines
        body = re.sub(";(?!\s*\n)", ";\n", body)
        body = re.sub("(?<!and )then(?!\s*\n)", "then\n", body)
        body = re.sub("(?<!or )else(?!\s*\n)", "else\n", body)
        body = re.sub("declare", "\ndeclare", body)
        body = re.sub(r"\bdo\b", "do\n", body)
        body = re.sub("\n\s*\n+", "\n\n", body)

    parent_count = 0
    result = ""

    for l in body.splitlines():
        if l.find("--") != -1:
            eol_comment = l[l.find("--"):].strip()
            l = l[:l.find("--")]
        else:
            eol_comment = ""

        l = l.strip()

        if l.startswith("end") \
           or l.startswith("elsif")  \
           or l.startswith("else")  \
           or l.startswith("begin") \
           or l.startswith("}"):   # for C
            indent -= 3

        old_parent = parent_count
        parent_count = parent_count + l.count("(") - l.count(")")

        if not l:
            if eol_comment:
                result += " " * indent

        elif l[0] == '(':
            result += " " * (indent + 2)
            if parent_count > old_parent:
                indent += (parent_count - old_parent) * 3
        elif not old_parent:
            result += " " * indent
            if parent_count > old_parent:
                indent += (parent_count - old_parent) * 3
        else:
            if parent_count > old_parent:
                indent += (parent_count - old_parent) * 3
            result += " " * indent

        if old_parent > parent_count:
            indent -= (old_parent - parent_count) * 3

        result += l + eol_comment + "\n"

        if (l.endswith("then") and not l.endswith("and then")) \
           or l.endswith("loop") \
           or(l.endswith("else") and not l.endswith("or else"))\
           or l.endswith("begin") \
           or l.endswith("{") \
           or l.endswith("record") \
           or l.endswith("is") \
           or l.endswith("do") \
           or l.endswith("declare"):
            indent += 3

        # Case of generic instantiation:
        #     package A is
        #         new B ();
        if l.startswith("new"):
            indent -= 3


    return result


# The necessary setup to use a variable in a subprogram call. The returned
# values map to the following Ada code:
#   declare
#      $(tmpvars)    # A list of LocalVar
#   begin
#      $(precall)
#      Call ($(call), ...)
#      #(postcall)
#   end;
# and are used in case temporary variables are needed. If not, only 'call'
# will have a non-null value

VariableCall = namedtuple('VariableCall',
                          ['call', 'precall', 'postcall', 'tmpvars'])

class Local_Var(object):
    __slots__ = ["name", "type", "default", "aliased"]

    def __init__(self, name, type, default="", aliased=False):
        self.set_type(type)
        self.name = name
        self.default = default
        self.aliased = aliased

    def __repr__(self):
        return "<Local_Var name=%s type=%s>" % (self.name, self.type)

    def set_type(self, type):
        if isinstance(type, str):
            self.type = AdaType(type)
        else:
            self.type = type

    def _type(self, lang, pkg):
        """`pkg` is the package in which we insert the variable"""
        if isinstance(self.type, CType):
            if lang == "ada":
                return self.type.as_ada_param(pkg)
            elif lang == "c":
                return self.type.as_c_param(pkg)
        return self.type

    def spec(self, pkg, length=0, lang="ada"):
        """Format the declaration for the variable or parameter.
           'length' is the minimum length that the name should occupy (for
           proper alignment when there are several variables.
        """
        t = self._type(lang=lang, pkg=pkg)
        aliased = ""
        if self.aliased:
            aliased = "aliased "

        if self.default:
            return "%-*s : %s%s := %s" % (
                length, self.name, aliased, t, self.default)
        else:
            return "%-*s : %s%s" % (length, self.name, aliased, t)

    def as_call(self, pkg, lang="ada->ada", mode="in", value=None):
        """Pass self (or the value) as a parameter to an Ada subprogram call,
           implemented in the given language. See comments at the beginning
           of this package for valid values of LANG.
           'pkg' is the instance of Package in which the call occurs.
           :return: an instance of VariableCall
        """
        assert(lang in ("ada->ada", "c->ada", "ada->c"))

        wrapper = "%s"
        n = value or self.name
        if mode == "access_c":
            mode = "access"
            wrapper="%s'Access"

        if isinstance(self.type, CType):
            return self.type.as_call(
                name=n, pkg=pkg, lang=lang, mode=mode, wrapper=wrapper)
        else:
            return VariableCall(call=n, precall='', postcall='', tmpvars=[])


class Parameter(Local_Var):
    __slots__ = ["name", "type", "default", "aliased", "mode", "doc",
                 "ada_binding"]

    def __init__(self, name, type, default="", doc="", mode="in",
                 ada_binding=True):
        """A mode "access_c" indicates an "access" parameter for which
           calls will use a 'Access.
           :param ada_binding: if False, the parameter will not be displayed
              in the profile of Ada subprograms (although, of course, it will
              be passed to the C subprograms)
        """
        super(Parameter, self).__init__(name, type, default)
        self.mode = mode
        self.doc  = doc
        self.ada_binding = ada_binding

    def _type(self, lang, pkg):
        mode = self.mode
        if self.mode == "access_c":
            mode = "access"

        if mode == "in" or not hasattr(self.type, "userecord"):
            t = super(Parameter, self)._type(lang=lang, pkg=pkg)
        else:
            userec = self.type.userecord
            self.type.userecord = False
            t = super(Parameter, self)._type(lang=lang, pkg=pkg)
            self.type.userecord = userec

        if mode != "in":
            return "%s %s" % (mode, t)
        return t

    def as_call(self, pkg, lang="ada->ada", value=None):
        """'pkg' is the package instance in which the call occurs."""

        if not self.ada_binding:
            if self.default is not None:
                return VariableCall(call=self.default,
                                    precall='', postcall='', tmpvars=[])
            else:
                return VariableCall(call="Parameter not bound in Ada",
                                    precall='', postcall='', tmpvars=[])
        else:
            return super(Parameter, self).as_call(
                pkg=pkg, lang=lang, mode=self.mode, value=value)

    def direct_cmap(self):
        """Whether the parameter can be passed as is to C"""
        return self.type.direct_cmap()

    def value(self):
        if not self.ada_binding:
            if self.default is not None:
                return self.default
            else:
                return "Parameter not bound in Ada"
        else:
            return self.ada_binding


def base_name(qname):
    """Return the basename for a fully qualified name:
        Pkg.Name  => Name
    """
    if "." in qname:
        return qname[qname.rfind(".") + 1:]
    else:
        return qname


def package_name(qname):
    """Return the package part of a fully qualified name:
       Pkg.Child.Name  => Pkg.Child
       Name      => ""
    """
    if "." in qname:
        return qname[:qname.rfind(".")]
    else:
        return ""


max_profile_length = 79 - len(" is")


class Subprogram(object):
    """An Ada subprogram that we are generating"""

    def __init__(self, name, code="", plist=[], local_vars=[],
                 returns=None, doc=[], showdoc=True, convention=None,
                 lang="ada"):
        """Create a new subprogram.
           'plist' is a list of Parameter.
           'local_vars' is a list of Local_Var.
           'doc' is a string or a list of paragraphs.
           'code' can be the empty string, in which case no body is output.
           'lang' is the language for the types of parameters.
           The code will be automatically pretty-printed, and the appropriate
           pragma Unreferenced are also added automatically.
        """
        assert(returns is None or isinstance(returns, CType))
        self.name = name
        self.plist = plist
        self.returns = returns
        self.local = local_vars
        self.showdoc = showdoc
        self.convention = convention   # "lang"
        self._import = None
        self._nested = []  # nested subprograms
        self._deprecated = (False, "") # True if deprecated
        self._manual_body = None  # Written by user explicitly

        self.lang = lang  # Language for the types of parameters

        if code and code[-1] != ";":
            self.code = code + ";"
        else:
            self.code = code

        if isinstance(doc, list):
            self.doc = doc
        else:
            self.doc = [doc]

    def import_c(self, cname):
        """Declares that 'self' is implemented as a pragma Import.
           This returns 'self' so that it can be chained:
              s = Subprogram(...).import_c('...')
        """
        self._import = 'pragma Import (C, %s, "%s");' % (self.name, cname)
        return self

    def set_param_lang(self, lang):
        """Set the language to use when printing the types of parameters.
           If "c", prints the C type corresponding to the "ada" types.
        """
        self.lang = lang

    def mark_deprecated(self, msg):
        """Mark the subprogram as deprecated"""

        self._deprecated = (True, msg)

    def add_nested(self, *args):
        """Add some nested subprograms"""
        for subp in args:
            self._nested.append(subp)
        return self

    def set_body(self, body):
        """Overrides the body of the subprogram (including profile,...)"""
        self._manual_body = body

    def _profile(self, pkg, indent="   ", lang="ada",
                 maxlen=max_profile_length):
        """Compute the profile for the subprogram"""

        returns = self.returns and self.returns.as_return(pkg=pkg)

        if returns:
            prefix = "function"

            if self.lang == "c":
                suffix = " return %s" % returns[1]
            else:
                suffix = " return %s" % returns[0]
        else:
            prefix = "procedure"
            suffix = ""

        if self.name:
            prefix = indent + prefix + " " + base_name(self.name)
        else:
            prefix = "access %s" % prefix

        if self.plist:
            # First test: all parameters on same line
            plist = [p.spec(pkg=pkg, lang=lang) for p in self.plist]
            p = " (" + "; ".join(plist) + ")"

            # If too long, split on several lines
            if len(p) + len(prefix) + len(suffix) > maxlen:
                max = max_length([p.name for p in self.plist])
                plist = [p.spec(pkg=pkg, length=max, lang=lang)
                         for p in self.plist]
                p = "\n   " + indent + "(" \
                    + (";\n    " + indent).join(plist) + ")"

        else:
            p = ""

        # Should the "return" go on a separate line ?
        if p and len(p.splitlines()[-1]) + len(suffix) > maxlen:
            return prefix + p + "\n   " + indent + suffix
        else:
            return prefix + p + suffix

    def spec(self, pkg, indent="   ", show_doc=True,
             maxlen=max_profile_length):
        """Return the spec of the subprogram"""

        if self.showdoc and show_doc:
            doc = [d for d in self.doc]
            if self._deprecated[0]:
                doc += [self._deprecated[1]]
            doc += [p.doc for p in self.plist]
        else:
            doc = []

        result = self._profile(
            pkg=pkg, indent=indent, lang=self.lang, maxlen=maxlen) + ";"

        if self._import:
            result += "\n" + indent + self._import

        if self._deprecated[0]:
            result += "\n" + indent + "pragma Obsolescent (%s);" % self.name

        if self.convention:
            result += "\n" + indent \
                + "pragma Convention (%s, %s);" % (self.convention, self.name)

        return result + format_doc(doc, indent=indent, separate_paragraphs=False)

    def _find_unreferenced(self, local_vars="", indent="   "):
        """List the pragma Unreferenced statements that are needed for this
           subprogram.
        """
        unreferenced = []
        for p in self.plist:
            if not re.search(
               r'\b%s\b' % p.name, self.code + local_vars, re.IGNORECASE):
                unreferenced.append(p.name)

        if unreferenced:
            return indent + "   pragma Unreferenced (%s);\n" % (
                ", ".join(unreferenced))
        else:
            return ""

    def _format_local_vars(self, pkg, indent="   "):
        """The list of local variable declarations"""
        if self.local:
            max = max_length([p.name for p in self.local])
            result = [v.spec(pkg=pkg, length=max) for v in self.local]
            return indent + "   " + (";\n   " + indent).join(result) + ";\n"
        else:
            return ""

    def body(self, pkg, indent="   "):
        if self._manual_body:
            return self._manual_body

        if not self.code:
            return ""

        result = box(base_name(self.name), indent=indent) + "\n\n"
        profile = self._profile(pkg=pkg, lang=self.lang, indent=indent)
        result += profile

        if profile.find("\n") != -1:
            result += "\n" + indent + "is\n"
        else:
            result += " is\n"

        local = self._format_local_vars(pkg=pkg, indent=indent)
        result += self._find_unreferenced(local_vars=local, indent=indent)

        for s in self._nested:
            result += s.spec(pkg=pkg, indent=indent + "   ") + "\n"
            result += s.body(pkg=pkg, indent=indent + "   ")

        result += local
        result += indent + "begin\n"
        result += indent_code(self.code, indent=len(indent) + 3)
        return result + indent + "end %s;\n" % base_name(self.name)

    def call(self, in_pkg=None, extra_postcall="", values=dict(), lang=None):
        """A call to 'self'.
           The parameters that are passed to self are assumed to have the
           same name as in self's declaration. When 'self' is implemented
           as a pragma Import, proper conversions are done.
           'in_pkg' is used to fully qualify the name of the subprogram, to
           avoid ambiguities. This is optional. This is an instance of Package.

           Returned value is a tuple:
               ("code", "variable_for_return", tmpvars=[])
           where "code" is the code to execute for the call, including
           creation of temporary variables, and "variable_for_return" is
           either None, or the code to get the result of the subprogram.
           So a call is:
               declare
                  tmp_vars;
               begin
                  code;
                  extra_postcall;
                  return variable_for_return;  --  Omitted for procedures
               end;

           See comments at the beginning of this package for valid LANG values.
        """

        assert(in_pkg is not None)
        assert(isinstance(in_pkg, Package))

        if lang:
            pass
        elif self._import:
            lang = "ada->c"
        else:
            lang = "ada->ada"

        assert(lang in ("ada->ada", "c->ada", "ada->c"))

        tmpvars  = []
        precall  = ""
        params   = []
        postcall = extra_postcall

        for arg in self.plist:
            c = arg.as_call(
                pkg=in_pkg,
                lang=lang,   # An instance of VariableCall
                value=values.get(arg.name.lower(), None))
            params.append(c.call)
            tmpvars.extend(c.tmpvars)
            precall += c.precall
            postcall = c.postcall + postcall

        if params:
            call = "%s (%s)" % (self.name, ", ".join(params))
        else:
            call = self.name

        returns = self.returns and self.returns.as_return(pkg=in_pkg)
        if returns is not None:
            if lang == "ada->c":
                self.returns.convert_from_c_add_with(pkg=in_pkg)

                tmpvars.extend(returns[3])
                if "%(tmp)s" in returns[2]:
                    # Result of Internal is used to create a temp. variable,
                    # which is then returned. This variable has the same type
                    # as the Ada type (not necessarily same as Internal)
                    call = returns[2] % {"var":call, "tmp":"Tmp_Return"}

                    tmpvars.append(Local_Var("Tmp_Return", returns[0]))
                    result = ("%s%s;%s" % (precall, call, postcall),
                            "Tmp_Return",
                            tmpvars)

                elif postcall:
                    tmpvars.append(Local_Var("Tmp_Return", returns[1]))
                    call = "Tmp_Return := %s" % call
                    result = ("%s%s;%s" % (precall, call, postcall),
                            returns[2] % {"var": "Tmp_Return"},
                            tmpvars)

                else:
                    # No need for a temporary variable
                    result = (precall, returns[2] % {"var":call}, tmpvars)

            else:
                if postcall:
                    # We need to use a temporary variable, since there are
                    # cleanups to perform. This will not work if the function
                    # returns an unconstrained array though.
                    tmpvars.append(Local_Var("Tmp_Return", returns[0]))
                    call = "Tmp_Return := %s" % call
                    result = ("%s%s;%s" % (precall, call, postcall),
                            "Tmp_Return",
                            tmpvars)
                else:
                    # No need for a temporary variable
                    result = (precall, call, tmpvars)

        else:
            # A procedure
            result = ("%s%s;%s" % (precall, call, postcall), None, tmpvars)

        return result

    def call_to_string(self, call, lang="ada->ada"):
        """CALL is the result of call() above.
           This function returns a string that contains the code for the
           subprogram.
        """
        result = call[0]
        if call[1]:
            if lang == "c->ada":
                # The return value (Ada) needs to be converted back to C (this
                # is the returned value from a callback, for instance)
                result += "return %s" % (
                    self.returns.convert_to_c() % {"var": call[1]}, )
            else:
                result += "return %s" % call[1]
        return result


class Code(object):
    """Some text to insert in a package.
       This can be either some code, or the comments for the code. In the latter case, the
       comment will be automatically formatted (and C names substituted as appropriate).
    """

    def __init__(self, content, iscomment=False):
        self.content = content
        self.iscomment = iscomment

    def format(self, indent=""):
        """Return the code that should be written into a package"""
        if self.iscomment:
            return format_doc(self.content, indent=indent) + "\n"
        else:
            return indent_code(self.content, indent=len(indent), addnewlines=False)

    @staticmethod
    def formatlist(codelist, indent):
        """Format a list of code objects. This properly associates a comment with the
           previous code, with no blank line.
        """

        result = ""
        for r in codelist:
            f = r.format(indent=indent)
            if result and not r.iscomment:
                result += "\n"
            result += f

        return result


class Section(object):
    """A group of types and subprograms in an Ada package.
       There is a single section with a given name in the package
    """

    group_getters_and_setters = False
    # If true, a getter will be displayed with its corresponding setter.
    # Only one doc will be displayed for the two, and no separation line
    # will be output.

    sort_alphabetically = False
    # If true, subprograms are all sorted alphabetically, otherwise the
    # order is alphabetical for getters, but setters appear just after the
    # getter.

    def __init__(self, pkg, name):
        self.pkg = pkg  # The instance of Package in which the section is
        self.name = name
        self.comment = ""
        self.__subprograms = []  # All subprograms  (in_spec, Subprogram())
        self.spec_code = []  # List of Code objects
        self.body_code = []  # List of Code objects

    def add_comment(self, comment, fill=True):
        """If 'fill' is true, the comment is automatically split on several
           lines if needed. Otherwise, the comment is assumed to be already
           formatted properly, minus the leading --
        """
        if comment == "":
            self.comment += "   --\n"
        else:
            self.comment += "".join(
                format_doc(comment, indent="   ", fill=fill)) + \
                "\n"

    def add(self, obj, in_spec=True):
        """Add one or more objects to the section (subprogram, code,...)"""
        if isinstance(obj, Subprogram):
            self.__subprograms.append((in_spec, obj))
        elif isinstance(obj, Package):
            obj.isnested = True
            self.__subprograms.append((in_spec, obj))
        else:
            if isinstance(obj, str):
                obj = Code(obj)
            elif not isinstance(obj, Code):
                print "Unexpected type passed to add: %s" % type(obj)
                raise Exception

            if in_spec:
                self.spec_code.append(obj)
            else:
                self.body_code.append(obj)

    def add_code(self, code, specs=True):
        self.add(code, specs)

    def _group_subprograms(self):
        """Returns a list of subprograms for the specs. In each nested list,
           the subprograms are grouped and a single documentation is output for
           the whole group. At the same time, this preserves the order of
           groups, so they appear in the order in which the first subprogram
           in the group appeared.
        """

        if Section.group_getters_and_setters \
                or not Section.sort_alphabetically:
            result = []
            tmp = dict()  # group_name => [subprograms]

            gtk_new_index = 0;

            for in_spec, s in self.__subprograms:
                if not in_spec:
                    continue

                name = base_name(s.name).replace("Get_", "") \
                        .replace("Query_", "") \
                        .replace("Gtk_New", "") \
                        .replace("Gdk_New", "") \
                        .replace("Initialize", "") \
                        .replace("Set_From_", "") \
                        .replace("Set_", "")

                if base_name(s.name) in ("Gtk_New", "Gdk_New"):
                    # Always create a new group for Gtk_New, since they all
                    # have different parameters. But we still want to group
                    # Gtk_New and Initialize.
                    t = tmp["Gtk_New%d" % gtk_new_index] = [s]
                    result.append(t)
                elif base_name(s.name) == "Initialize":
                    tmp["Gtk_New%d" % gtk_new_index].append(s)
                    gtk_new_index += 1
                elif name in tmp:
                    tmp[name].append(s)  # Also modified in result
                else:
                    tmp[name] = [s]
                    result.append(tmp[name])

            return result

        else:
            return [[s] for in_spec, s in self.__subprograms]

    def spec(self, pkg, indent):
        """Return the spec of the section"""

        result = []

        if self.__subprograms or self.spec_code or self.comment:
            if self.name:
                result.append(box(self.name))
            if self.comment:
                result.append(self.comment)
            else:
                result.append("")

            spec_code = Code.formatlist(self.spec_code, indent=indent)
            if spec_code:
                result.append(spec_code)

            for group in self._group_subprograms():
                for s in group:
                    if isinstance(s, Subprogram):
                        show_doc = ((not Section.group_getters_and_setters
                                     and not group[0].name.startswith("Gtk_New"))
                                    or s == group[-1])

                        result.append(s.spec(pkg=pkg,
                                             show_doc=show_doc,
                                             indent=indent))
                    else:
                        show_doc = True
                        result.append(s.spec())

                    if show_doc:
                        result.append("")

        return "\n".join(result)

    def body(self, pkg, indent):
        result = []

        body_code = Code.formatlist(self.body_code, indent=indent)
        if body_code:
            result.append(body_code)

        self.__subprograms.sort(lambda x, y: cmp(base_name(x[1].name), base_name(y[1].name)))

        # First output for the subprograms only defined in the body

        for in_spec, s in self.__subprograms:
            if not in_spec:
                if isinstance(s, Subprogram):
                    result.append(s.spec(pkg=pkg, indent=indent))
                else:
                    result.append(s.spec())

                result.append("")

        # Then output all the bodiesx

        for in_spec, s in self.__subprograms:
            if isinstance(s, Subprogram):
                b = s.body(pkg=pkg, indent=indent)
            else:
                b = s.body() + "\n"

            if b:
                result.append(b)

        return "\n".join(result)


class Package(object):
    copyright_header = ""
    # Can be overridden by applications to change the copyright header

    def __init__(self, name, doc=[], isnested=False):
        """'doc' is a list of strings, where each string is a paragraph"""
        self.name = name
        self.doc  = doc

        self.sections = []       # [Section]
        self.spec_withs = dict() #  "pkg" -> use:Boolean
        self.body_withs = dict() #  "pkg" -> use:Boolean
        self.private = []        # Private section
        self.language_version = "" # a pragma to be put just after the headers
        self.formal_params = ""  # generic formal parameters
        self.isnested = isnested

    def section(self, name):
        """Return an existing section (or create a new one) with the given
           name.
        """
        for s in self.sections:
            if s.name == name:
                return s

        s = Section(self, name)
        self.sections.append(s)
        return s

    def add_with(self, pkg, specs=True, do_use=True):
        """Add a with+use clause for pkg, where pkg can also be a list.
           Automatic casing is performed. If specs is True, the withs are
           added to the specs of the package, otherwise to the body
        """
        if pkg in ("", "System"):
            return

        if type(pkg) == str:
            pkg = [pkg]
        for p in pkg:
            if p.lower() == self.name.lower():
                continue   # No dependence on self
            if specs:
                self.spec_withs[p] = do_use or self.spec_withs.get(p, False)
                self.body_withs.pop(p, None) # Remove same with in body
            elif p not in self.spec_withs:
                self.body_withs[p] = do_use or self.body_withs.get(p, False)

    def add_private(self, code):
        self.private.append(code)

    def _output_withs(self, withs):
        if withs:
            result = []
            m = max_length(withs)
            for w in sorted(withs.keys()):
                if withs[w]:
                    result.append(
                        "with %-*s use %s;" % (m + 1, w + ";", w))
                else:
                    result.append("with %s;" % w)

            return "\n".join(result) + "\n"
        return ""

    def section_order(self, name):
        """Return a numerical order for sections"""
        order = {"": 0,
                 "Enumeration Properties": 1,

                 # Primitive operations first
                 "Constructors": 2,
                 "Methods": 3,
                 "GtkAda additions": 4,
                 "Inherited subprograms (from interfaces)": 5,

                 # Then non-primitive (so that we can freeze the type, for
                 # instance by instantiating lists)
                 "Interfaces": 6,
                 "Functions": 7,

                 # General data independent of the type
                 "Properties": 8,
                 "Signals": 9}
        return order.get(name, 1000)

    def spec(self):
        """Returns the spec of the package, in the file `out`"""

        result = []

        if not self.isnested:
            indent = ""
            if Package.copyright_header:
                result.append(Package.copyright_header)

            if self.language_version:
                result.append(self.language_version)

            if self.doc:
                result.append(format_doc(self.doc, indent=""))

            result.append("")
            result.append('pragma Warnings (Off, "*is already use-visible*");')
            result.append(self._output_withs(self.spec_withs))

        else:
            indent = "   "

        if self.formal_params:
            result.append(indent + "generic")
            result.append(indent + "   %s" % self.formal_params)
        result.append(indent + "package %s is" % self.name)

        self.sections.sort(lambda x, y: cmp(self.section_order(x.name),
                                            self.section_order(y.name)))

        for s in self.sections:
            sec = s.spec(pkg=self, indent=indent + "   ")
            if sec:
                result.append(sec)

        if self.private:
            result.append(indent + "private")
            result.extend(self.private)

        result.append(indent + "end %s;" % self.name)
        return "\n".join(result)

    def body(self):
        """Returns the body of the package"""

        result = []
        body = ""

        if self.isnested:
            indent = "   "
        else:
            indent = ""

        for s in self.sections:
            b = s.body(pkg=self, indent=indent + "   ")
            if b:
                body += "\n" + b

        if not body:
            return ""

        if not self.isnested:
            if Package.copyright_header:
                result.append(Package.copyright_header)

            if self.language_version:
                result.append(self.language_version)

            result.append("pragma Style_Checks (Off);")
            result.append('pragma Warnings (Off, "*is already use-visible*");')
            result.append(self._output_withs(self.body_withs))

        result.append(indent + "package body %s is" % self.name)
        result.append(body)
        result.append(indent + "end %s;" % self.name)
        return "\n".join(result)
