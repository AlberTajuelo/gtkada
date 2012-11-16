"""This package contains data which must be edited by hand when adding new
   bindings.
"""

from adaformat import *

# General packages that don't depend on others and must be processed first

enums = ("GtkEnums",
         "PangoEnums",
         )

# List of interfaces to bind. These are processed before the widgets themselves.
# These are GIR names

interfaces = (# "Action",   From Gio
              "Activatable",
              #"AppChooser",
              "--Atk.ImplementorIface",
              "Buildable",
              "CellEditable",
              "CellLayout",
              "Editable",
              "FileChooser",
              "FontChooser",
              "Icon",
              "Orientable",
              "PrintOperationPreview",
              "RecentChooser",
              "Scrollable",
              "StyleProvider",
              "ToolShell",
              #"TreeDragDest",
              #"TreeDragSource",
              #"TreeSortable"
              #"TreeModel",
             )

# List of widgets to bind.
# Contains C type names.
# Start the name with -- for objects we do not want to bind

binding = ("--GdkAtom",   # No binding necessary, too low-level
           "GdkCursor",
           "GdkDevice",
           "GdkDragContext",
           "GdkEvent",
           "GdkRGBA",
           "GdkScreen",
           "GdkWindow",

           "--PangoAttrIterator",
           "PangoAttrList",
           "PangoAttribute",
           "--PangoColor",
           "PangoContext",
           "PangoCoverage",
           "PangoFont",
           "PangoFontDescription",
           "PangoFontFace",
           "PangoFontFamily",
           "PangoFontMap",
           "PangoFontMetrics",
           "PangoFontset",
           "--PangoGlyphItem",
           "--PangoGlyphItemIter",
           "--PangoGlyphString",
           "--PangoItem",
           "--PangoRenderer",
           "--PangoScriptIter",
           "PangoLanguage",
           "PangoLayout",
           "PangoLayoutIter",
           "PangoLayoutLine",
           "PangoMatrix",
           "PangoTabArray",

           # "GEmblemedIcon",

           "GtkAboutDialog",
           "GtkAccelGroup",
           "GtkAccelLabel",
           "GtkAccelMap",
           #"GtkAccessible",  # Needs ATK
           "GtkAction",
           "GtkActionGroup",
           "GtkAdjustment",
           "GtkAlignment",
           #"GtkApplication",
           "GtkArrow",
           "GtkAspectFrame",
           "GtkAssistant",
           "GtkBin",
           "GtkBorder",
           "GtkBox",
           "GtkBuilder",
           "GtkButton",
           "GtkButtonBox",
           "GtkCalendar",
           "GtkCellArea",
           "GtkCellAreaBox",
           "--GtkCellAreaClass",
           "GtkCellAreaContext",
           "GtkCellRenderer",
           "GtkCellRendererAccel",
           "GtkCellRendererCombo",
           "GtkCellRendererPixbuf",
           "GtkCellRendererProgress",
           "GtkCellRendererSpin",
           "GtkCellRendererSpinner",
           "GtkCellRendererText",
           "GtkCellRendererToggle",
           "GtkCellView",
           "GtkCheckButton",
           "GtkCheckMenuItem",
           "GtkClipboard",
           "GtkColorButton",
           "GtkColorSelection",
           "GtkColorSelectionDialog",
           "GtkComboBox",
           "GtkComboBoxText",
           "GtkContainer",
           "--GtkContainerClass",
           "GtkCssProvider",
           "GtkDialog",
           "GtkDrawingArea",
           "GtkEntry",
           "GtkEntryBuffer",
           "GtkEntryCompletion",
           "GtkEventBox",
           "GtkExpander",
           "GtkFileChooserButton",
           "GtkFileChooserDialog",
           "GtkFileChooserWidget",
           "GtkFileFilter",
           "GtkFixed",
           "GtkFontButton",
           "GtkFontChooserDialog",
           "GtkFontChooserWidget",
           "GtkFontSelection",
           "GtkFontSelectionDialog",
           "GtkFrame",
           "GtkGradient",
           "GtkGrid",
           "GtkHandleBox",
           "GtkHBox",
           "GtkHButtonBox",
           "GtkHPaned",
           "GtkHScale",
           "GtkHScrollbar",
           "GtkHSeparator",
           "GtkHSV",
           "GtkIconFactory",
           "GtkIconInfo",
           "GtkIconSet",
           "GtkIconSource",
           "GtkIconTheme",
           "GtkIconView",
           "GtkImage",
           "GtkImageMenuItem",
           "GtkInfoBar",
           "GtkInvisible",
           "GtkLabel",
           "GtkLayout",
           "GtkLinkButton",
           # "GtkLockButton",  # requires GPermission
           "GtkMain",
           "GtkMisc",
           "GtkMenu",
           "GtkMenuBar",
           "GtkMenuItem",
           "GtkMenuShell",
           "GtkMenuToolButton",
           "GtkMessageDialog",
           "--GtkMountOperation",  # Requires a lot of GIO
           "GtkNotebook",
           # "GtkNumerableIcon",   # Requires a lot of GIO
           "GtkOffscreenWindow",
           "GtkOverlay",
           "GtkPaned",
           "GtkPageSetup",
           "GtkPaperSize",
           "GtkPrintContext",
           "GtkPrintOperation",
           "GtkPrintSettings",
           "--GtkPlug",   #  X11-specific, no binding
           "GtkProgressBar",
           "GtkRadioAction",
           "GtkRadioButton",
           "GtkRadioMenuItem",
           "GtkRadioToolButton",
           "GtkRange",
           "GtkRecentAction",
           "GtkRecentChooserDialog",
           "GtkRecentChooserMenu",
           "GtkRecentChooserWidget",
           "GtkRecentFilter",
           "GtkRecentInfo",
           "GtkRecentManager",
           "GtkScale",
           "GtkScaleButton",
           "GtkSelectionData",
           "GtkSeparator",
           "GtkSeparatorMenuItem",
           "GtkSeparatorToolItem",
           "GtkSizeGroup",
           "GtkScrollbar",
           "GtkScrolledWindow",
           "GtkSettings",
           "--GtkSocket",  #  X11-specific, no binding
           "GtkSpinner",
           "GtkSpinButton",
           "GtkStatusbar",
           "GtkStatusIcon",
           "GtkStockItem",
           "GtkStyle",
           "GtkStyleContext",
           "GtkStyleProperties",
           "GtkSwitch",
           "GtkSymbolicColor",
           "GtkTable",
           "GtkTargetEntry",
           "GtkTargetList",
           "GtkTearoffMenuItem",
           "GtkTextChildAnchor",
           "GtkTextIter",
           "GtkTextTag",
           # "GtkTreePath",   #  into GtkTreeModel
           "GtkToggleAction",
           "GtkToggleButton",
           "GtkToggleToolButton",
           "GtkToolButton",
           "GtkToolbar",
           "GtkToolItem",
           "GtkToolItemGroup",
           "GtkTooltip",
           "GtkToolPalette",
           "GtkUIManager",
           "GtkVBox",
           "GtkVButtonBox",
           "GtkVPaned",
           "GtkVScale",
           "GtkVScrollbar",
           "GtkVSeparator",
           "GtkViewport",
           "GtkVolumeButton",
           "GtkWidget",
           "--GtkWidgetClass",
           "GtkWindow",
           "GtkWindowGroup",
          )

# Handling of functions with user data. The names below are the likely names
# for callback functions that accept user_data. The GIR file doesn't point to
# these specific parameters.

user_data_params = ["Data", "Func_Data", "User_Data", "D"]
destroy_data_params = ["destroy", "func_notify"]

# Maps c methods to Ada subprograms or enumeration (for docs).
# All methods that are generated automatically will be added
# as they are processed.

naming.cname_to_adaname = {
    "gtk_show_uri":                 "gtk_show_uri()",
    "gtk_icon_factory_add_default": "Gtk.Icon_Factory.Add_Default",
    "gtk_icon_factory_add":         "Gtk.Icon_Factory.Add",
    "gdk_pixbuf_new_from_data":     "Gdk.Pixbuf.Gdk_New_From_Data",
    "gdk_pixbuf_new_from_file":     "Gdk.Pixbuf.Gdk_New_From_File",
    "gdk_pixbuf_new_from_xpm_data": "Gdk.Pixbuf.Gdk_New_From_Xpm_Data",
    "gdk_pixbuf_animation_new_from_file":
                                    "Gdk.Pixbuf.Gdk_New_From_File",
    "gdk_pixbuf_new":               "Gdk.Pixbuf.Gdk_New",
    "gdk_pixbuf_new_subpixbuf":     "Gdk.Pixbuf.Gdk_New_Subpixbuf",

    "TRUE": "True",
    "FALSE": "False",
    "NULL": "null",

    "GDK_2BUTTON_PRESS": "Gdk_2button_Press",
    "GDK_3BUTTON_PRESS": "Gdk_3button_Press",
    "GDK_EVENT_LAST": None,

    # ??? Doesn't exist
    "gtk_activatable_get_action": "Gtk.Activatable.Get_Action",
}

# Maps GIR's "name" to a "c:type". This isn't needed for the classes
# themselves, since this is automatically read from the GIR file.
# Mostly used for properties. The values must correspond to entries in
# self.type_exceptions.

naming.girname_to_ctype = {
    "GdkPixbuf.Pixbuf":    "GdkPixbuf",
    "Pango.EllipsizeMode": "PangoEllipsizeMode",
    "Pango.FontDescription": "PangoFontDescription*",
    "Pango.AttrList":      "PangoAttrList",
    "Gio.Icon":            "GIcon*",
    "Gdk.Pixmap":          "GdkPixmap*",
    "Gdk.Image":           "GdkImage*",
    "GdkPixbuf.PixbufAnimation": "GdkPixbufAnimation*",
    "Gdk.Bitmap":          "GdkBitmap*",
    "Gdk.Color":           "GdkColor*",
    "Gdk.RGBA":            "GdkRGBA",
    "GObject.Object":      "GObject*",
    "GObject.Closure":     "GClosure*",
    "Cairo.Context":       "cairo_t",
    "ModifierType":        "GdkModifierType",
    "GObject.InitiallyUnowned": "GObject*",  # An alias
}

# Naming exceptions. In particular maps Ada keywords.

naming.exceptions = {
    "Entry": "GEntry",
    "Type":  "The_Type",
    "Range": "GRange",
    "Delay": "The_Delay",
    "Select": "Gtk_Select",
    "End":   "The_End",
    "Return": "Do_Return",
    "Function": "Func",
    "Digits": "The_Digits",
    "Reverse": "Gtk_Reverse",
    "Raise": "Gdk_Raise",
    "Use": "GUse",
    "Uri": "URI",
    "In": "Gtk_In",

    "Gtk_Uimanager": "Gtk_UI_Manager",
    "Gicon": "G_Icon",
}

# Maps C types to type descriptions.
# All standard widgets will be added automatically. Only special
# namings are needed here

naming.type_exceptions = {
    "gboolean":          Enum("Boolean",
                              "Glib.Properties.Property_Boolean"),
    "gdouble":  Proxy("Gdouble", "Glib.Properties.Property_Double"),
    "double":   Proxy("Gdouble", "Glib.Properties.Property_Double"),
    "int":      Proxy("Gint",    "Glib.Properties.Property_Int"),
    "gint":     Proxy("Gint",    "Glib.Properties.Property_Int"),
    "guint":    Proxy("Guint",   "Glib.Properties.Property_Uint"),
    "guint16":  Proxy("Guint16", "Glib.Properties.Property_Uint"),
    "gfloat":   Proxy("Gfloat",  "Glib.Properties.Property_Float"),
    "GAppInfo": Proxy("Glib.GApp_Info"),

    # These should not be necessary, but if we don't put them the gnerated
    # binding is wrong (for instance we end up passing Gdk_Event_Record as
    # parameters to functions, or Gdk_RGBA directly to C)
    "GdkRGBA":  Record("Gdk.RGBA.Gdk_RGBA",  # impose casing
                      "Gdk.RGBA.Property_RGBA"),
    "GdkRGBA*":  Proxy("Gdk.RGBA.Gdk_RGBA", "Gdk.RGBA.Property_RGBA",
                                "Gdk.RGBA.Gdk_RGBA_Or_Null"),
    "GdkEvent*": Proxy("Gdk.Event.Gdk_Event", ""),

    "cairo_t*":              Proxy("Cairo.Cairo_Context"),
    "cairo_content_t":       Proxy("Cairo.Cairo_Content"),
    "cairo_pattern_t*":      Proxy("Cairo.Cairo_Pattern"),
    "cairo_surface_t*":      Proxy("Cairo.Cairo_Surface"),
    "cairo_region_t*":       Proxy("Cairo.Region.Cairo_Region"),
    "cairo_font_options_t":  Proxy("Cairo.Cairo_Font_Options"),

    # Force mapping to a Proxy. This is also hard-coded in GITClass.__init__
    "PangoFontDescription*": Proxy("Pango.Font.Pango_Font_Description",
                                   "Pango.Font.Property_Font_Description"),

    "GError*":           Proxy("Glib.Error.GError"),
    "GObject*":          GObject("Glib.Object.GObject"),
    "GClosure*":         Proxy("System.Address", ""),
    "GInitiallyUnowned": GObject("Glib.Object.GInitiallyUnowned"),
    "GIcon*":            Proxy("Glib.G_Icon.G_Icon"),
    "GValue":            Proxy("Glib.Values.GValue", ""),
    "GdkAtom":           Proxy("Gdk.Types.Gdk_Atom"),

    # Specific to this binding generator (referenced from binding.xml)
    "VisualList":  List("Gdk.Visual.Gdk_Visual_List.GList"),
    "ObjectList":  List("Glib.Object.Object_Simple_List.GList"),
    "ObjectSList": List("Glib.Object.Object_List.GSlist"),
    "StringList":  List("Gtk.Enums.String_List.Glist"),
    "StringSList": List("Gtk.Enums.String_SList.GSlist"),
    "TreePathList": List("Gtk.Tree_Model.Gtk_Tree_Path_List.Glist"),
    "TextTagList": List("Gtk.Text_Tag.Text_Tag_List.GSList"),

    "gpointer":       Proxy("System.Address", ""),
    "GDestroyNotify": Proxy("Glib.G_Destroy_Notify_Address"),
    "GQuark":        Proxy("Glib.GQuark"),
    "GObject":       Proxy("Glib.Object.GObject"),
    "GParamSpec":    Proxy("Glib.Param_Spec"),
    "GClosure":      Proxy("GClosure"),
    "GConnectFlags": Proxy("Glib.G_Connect_Flags"),

    "GtkTreeIter*":    Proxy("Gtk.Tree_Model.Gtk_Tree_Iter"),
    "WidgetPath*":     Proxy("Gtk.Widget.Widget_Path"),

    # ??? Shouldn't we use a naming exception instead ?
    "GtkStatusbar":    GObject("Gtk.Status_Bar.Gtk_Status_Bar"),
    "GtkTreeModel":    GObject("Gtk.Tree_Model.Gtk_Tree_Model"),
    "GtkTreePath*":    Proxy("Gtk.Tree_Model.Gtk_Tree_Path"),

    "GtkRcStyle":      GObject("Gtk.Rc.Gtk_Rc_Style"),

    "GtkTreeViewRowSeparatorFunc":
        Callback("Gtk.Tree_View.Gtk_Tree_View_Row_Separator_Func"),
    "GtkCellLayoutDataFunc":
        Callback("Gtk.Cell_Layout.Cell_Data_Func"),

    "GKeyFile*":           Proxy("Glib.Key_File.G_Key_File"),

    "GdkColor*": Proxy("Gdk.Color.Gdk_Color",
                       "Gdk.Color.Property_Gdk_Color",
                       "Gdk.Color.Gdk_Color_Or_Null"),
    "GdkDragContext":     GObject("Gdk.Drag_Contexts.Drag_Context"),
    "GdkFont":            Proxy("Gdk.Font.Gdk_Font"),
    "GdkVisual*":         Proxy("Gdk.Visual.Gdk_Visual"),
    "GdkPixmap*":         Proxy("Gdk.Pixmap.Gdk_Pixmap"),
    "GdkBitmap*":         Proxy("Gdk.Bitmap.Gdk_Bitmap"),
    "GdkImage*":          Proxy("Gdk.Image.Gdk_Image"),
    "GdkPixbuf":          GObject("Gdk.Pixbuf.Gdk_Pixbuf"),
    "GdkPixbufAnimation*": Proxy("Gdk.Pixbuf.Gdk_Pixbuf_Animation"),

    "GdkRectangle*":      Proxy("Gdk.Rectangle.Gdk_Rectangle"),

    "GdkRectangle":      Proxy("Gdk.Rectangle.Gdk_Rectangle"),  # in gdkevents.h

    # ??? The above should not be needed, we should infer it from the Gir.
    # we need it to generate the "Stub" object in Gdk.Device.Get_Position
    "Gdk.ModifierType":   Proxy("Gdk.Types.Gdk_Modifier_Type"),
    "GdkModifierType":    Proxy("Gdk.Types.Gdk_Modifier_Type"),
    "GdkKeyType":         Proxy("Gdk.Types.Gdk_Key_Type"),
    "GdkWindowAttr*":     Proxy("Gdk.Gdk_Window_Attr"),

    # Override type: we do not want to show they derive from GObject
    "GdkCursor":         Proxy("Gdk.Gdk_Cursor"),
    "GdkCursor*":        Proxy("Gdk.Gdk_Cursor"),
    "GdkWindow":         Proxy("Gdk.Gdk_Window"),
    "GdkWindow*":        Proxy("Gdk.Gdk_Window"),
}
