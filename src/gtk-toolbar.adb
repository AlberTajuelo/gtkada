------------------------------------------------------------------------------
--                  GtkAda - Ada95 binding for Gtk+/Gnome                   --
--                                                                          --
--      Copyright (C) 1998-2000 E. Briot, J. Brobecker and A. Charlet       --
--                     Copyright (C) 1998-2012, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

with System;
with Gtk.Tool_Item;  use Gtk.Tool_Item;
with Gtk.Widget;
with Glib.Type_Conversion_Hooks;

package body Gtk.Toolbar is

   package Type_Conversion is new Glib.Type_Conversion_Hooks.Hook_Registrator
     (Get_Type'Access, Gtk_Toolbar_Record);
   pragma Warnings (Off, Type_Conversion);

   use type Gtk.Widget.Gtk_Widget;

   ---------------------
   -- Get_Orientation --
   ---------------------

   function Get_Orientation
     (Toolbar : access Gtk_Toolbar_Record) return Gtk_Orientation
   is
      function Internal (Toolbar : System.Address) return Gtk_Orientation;
      pragma Import (C, Internal, "gtk_toolbar_get_orientation");

   begin
      return Internal (Get_Object (Toolbar));
   end Get_Orientation;

   ---------------
   -- Get_Style --
   ---------------

   function Get_Style
     (Toolbar : access Gtk_Toolbar_Record) return Gtk_Toolbar_Style
   is
      function Internal (Toolbar : System.Address) return Gtk_Toolbar_Style;
      pragma Import (C, Internal, "gtk_toolbar_get_style");

   begin
      return Internal (Get_Object (Toolbar));
   end Get_Style;

   -------------------
   -- Get_Icon_Size --
   -------------------

   function Get_Icon_Size
     (Toolbar : access Gtk_Toolbar_Record) return Gtk_Icon_Size
   is
      function Internal (Toolbar : System.Address) return Gtk_Icon_Size;
      pragma Import (C, Internal, "gtk_toolbar_get_icon_size");

   begin
      return Internal (Get_Object (Toolbar));
   end Get_Icon_Size;

   ------------------
   -- Get_Tooltips --
   ------------------

   function Get_Tooltips
     (Toolbar : access Gtk_Toolbar_Record) return Boolean
   is
      function Internal (Toolbar : System.Address) return Gboolean;
      pragma Import (C, Internal, "gtk_toolbar_get_tooltips");

   begin
      return Internal (Get_Object (Toolbar)) /= 0;
   end Get_Tooltips;

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Widget : out Gtk_Toolbar) is
   begin
      Widget := new Gtk_Toolbar_Record;
      Gtk.Toolbar.Initialize (Widget);
   end Gtk_New;

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New
     (Widget      : out Gtk_Toolbar;
      Orientation : Gtk_Orientation;
      Style       : Gtk_Toolbar_Style) is
   begin
      Widget := new Gtk_Toolbar_Record;
      pragma Warnings (Off);
      Initialize (Widget, Orientation, Style);
      pragma Warnings (On);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Widget : access Gtk_Toolbar_Record'Class)
   is
      function Internal return System.Address;
      pragma Import (C, Internal, "gtk_toolbar_new");

   begin
      Set_Object (Widget, Internal);
   end Initialize;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Widget      : access Gtk_Toolbar_Record'Class;
      Orientation : Gtk_Orientation;
      Style       : Gtk_Toolbar_Style) is
   begin
      Gtk.Toolbar.Initialize (Widget);
      Set_Orientation (Widget, Orientation);
      Set_Style (Widget, Style);
   end Initialize;

   -------------------
   -- Set_Icon_Size --
   -------------------

   procedure Set_Icon_Size
     (Toolbar   : access Gtk_Toolbar_Record;
      Icon_Size : Gtk_Icon_Size)
   is
      procedure Internal
        (Toolbar : System.Address; Icon_Size : Gtk_Icon_Size);
      pragma Import (C, Internal, "gtk_toolbar_set_icon_size");

   begin
      Internal (Get_Object (Toolbar), Icon_Size);
   end Set_Icon_Size;

   ---------------------
   -- Set_Orientation --
   ---------------------

   procedure Set_Orientation
     (Toolbar     : access Gtk_Toolbar_Record;
      Orientation : Gtk_Orientation)
   is
      procedure Internal
        (Toolbar     : System.Address;
         Orientation : Gtk_Orientation);
      pragma Import (C, Internal, "gtk_toolbar_set_orientation");

   begin
      Internal (Get_Object (Toolbar), Orientation);
   end Set_Orientation;

   ---------------
   -- Set_Style --
   ---------------

   procedure Set_Style
     (Toolbar : access Gtk_Toolbar_Record;
      Style   : Gtk_Toolbar_Style)
   is
      procedure Internal (Toolbar : System.Address; Style : Gtk_Toolbar_Style);
      pragma Import (C, Internal, "gtk_toolbar_set_style");

   begin
      Internal (Get_Object (Toolbar), Style);
   end Set_Style;

   ------------------
   -- Set_Tooltips --
   ------------------

   procedure Set_Tooltips
     (Toolbar : access Gtk_Toolbar_Record; Enable : Boolean)
   is
      procedure Internal (Toolbar : System.Address; Enable : Gint);
      pragma Import (C, Internal, "gtk_toolbar_set_tooltips");

   begin
      Internal (Get_Object (Toolbar), Boolean'Pos (Enable));
   end Set_Tooltips;

   -----------------
   -- Unset_Style --
   -----------------

   procedure Unset_Style (Toolbar : access Gtk_Toolbar_Record)
   is
      procedure Internal (Toolbar : System.Address);
      pragma Import (C, Internal, "gtk_toolbar_unset_style");
   begin
      Internal (Get_Object (Toolbar));
   end Unset_Style;

   ---------------------
   -- Unset_Icon_Size --
   ---------------------

   procedure Unset_Icon_Size (Toolbar : access Gtk_Toolbar_Record)
   is
      procedure Internal (Toolbar : System.Address);
      pragma Import (C, Internal, "gtk_toolbar_unset_icon_size");
   begin
      Internal (Get_Object (Toolbar));
   end Unset_Icon_Size;

   --------------------
   -- Get_Drop_Index --
   --------------------

   function Get_Drop_Index
     (Toolbar : access Gtk_Toolbar_Record;
      X       : Gint;
      Y       : Gint)
      return Gint
   is
      function Internal
        (Toolbar : System.Address;
         X       : Gint;
         Y       : Gint)
        return Gint;
      pragma Import (C, Internal, "gtk_toolbar_get_drop_index");
   begin
      return Internal (Get_Object (Toolbar), X, Y);
   end Get_Drop_Index;

   -----------------
   -- Get_N_Items --
   -----------------

   function Get_N_Items
     (Toolbar : access Gtk_Toolbar_Record)
     return Gint
   is
      function Internal
        (Toolbar : System.Address)
        return Gint;
      pragma Import (C, Internal, "gtk_toolbar_get_n_items");
   begin
      return Internal (Get_Object (Toolbar));
   end Get_N_Items;

   ----------------------
   -- Get_Relief_Style --
   ----------------------

   function Get_Relief_Style
     (Toolbar : access Gtk_Toolbar_Record)
      return Gtk_Relief_Style
   is
      function Internal
        (Toolbar : System.Address)
         return Gtk_Relief_Style;
      pragma Import (C, Internal, "gtk_toolbar_get_relief_style");
   begin
      return Internal (Get_Object (Toolbar));
   end Get_Relief_Style;

   --------------------
   -- Get_Show_Arrow --
   --------------------

   function Get_Show_Arrow
     (Toolbar : access Gtk_Toolbar_Record)
      return Boolean
   is
      function Internal
        (Toolbar : System.Address)
         return Gboolean;
      pragma Import (C, Internal, "gtk_toolbar_get_show_arrow");
   begin
      return Boolean'Val (Internal (Get_Object (Toolbar)));
   end Get_Show_Arrow;

   --------------------
   -- Set_Show_Arrow --
   --------------------

   procedure Set_Show_Arrow
     (Toolbar    : access Gtk_Toolbar_Record;
      Show_Arrow : Boolean := True)
   is
      procedure Internal
        (Toolbar    : System.Address;
         Show_Arrow : Gboolean);
      pragma Import (C, Internal, "gtk_toolbar_set_show_arrow");
   begin
      Internal (Get_Object (Toolbar), Boolean'Pos (Show_Arrow));
   end Set_Show_Arrow;

   ------------
   -- Insert --
   ------------

   procedure Insert
     (Toolbar : access Gtk_Toolbar_Record;
      Item    : access Gtk_Tool_Item_Record'Class;
      Pos     : Gint := -1)
   is
      procedure Internal
        (Toolbar : System.Address;
         Item    : System.Address;
         Pos     : Gint);
      pragma Import (C, Internal, "gtk_toolbar_insert");
   begin
      Internal (Get_Object (Toolbar), Get_Object (Item), Pos);
   end Insert;

   --------------------
   -- Get_Item_Index --
   --------------------

   function Get_Item_Index
     (Toolbar : access Gtk_Toolbar_Record;
      Item    : access Gtk_Tool_Item_Record'Class)
      return Gint
   is
      function Internal
        (Toolbar : System.Address;
         Item    : System.Address)
         return Gint;
      pragma Import (C, Internal, "gtk_toolbar_get_item_index");
   begin
      return Internal (Get_Object (Toolbar), Get_Object (Item));
   end Get_Item_Index;

   ------------------
   -- Get_Nth_Item --
   ------------------

   function Get_Nth_Item
     (Toolbar : access Gtk_Toolbar_Record;
      N       : Gint)
      return Gtk_Tool_Item
   is
      function Internal
        (Toolbar : System.Address;
         N       : Gint)
         return System.Address;
      pragma Import (C, Internal, "gtk_toolbar_get_nth_item");
      Stub : Gtk_Tool_Item_Record;
   begin
      return Gtk_Tool_Item
        (Get_User_Data
          (Internal (Get_Object (Toolbar), N), Stub));
   end Get_Nth_Item;

   -----------------------------
   -- Set_Drop_Highlight_Item --
   -----------------------------

   procedure Set_Drop_Highlight_Item
     (Toolbar   : access Gtk_Toolbar_Record;
      Tool_Item : access Gtk_Tool_Item_Record'Class;
      Index     : Gint)
   is
      procedure Internal
        (Toolbar   : System.Address;
         Tool_Item : System.Address;
         Index     : Gint);
      pragma Import (C, Internal, "gtk_toolbar_set_drop_highlight_item");
   begin
      Internal (Get_Object (Toolbar), Get_Object (Tool_Item), Index);
   end Set_Drop_Highlight_Item;

end Gtk.Toolbar;
