-----------------------------------------------------------------------
--          GtkAda - Ada95 binding for the Gimp Toolkit              --
--                                                                   --
-- Copyright (C) 1998 Emmanuel Briot and Joel Brobecker              --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU Library General Public       --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- Library General Public License for more details.                  --
--                                                                   --
-- You should have received a copy of the GNU Library General Public --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
-----------------------------------------------------------------------

with Gtk.Style;
with Gtk.Widget;

package Gtk.Rc is


   procedure Init;
   --  mapping: Init gtkrc.h gtk_rc_init

   procedure Parse (Filename : in String);
   --  mapping: Parse gtkrc.h gtk_rc_parse

   procedure Parse_String (Rc_String : in String);
   --  mapping: Parse_String gtkrc.h gtk_rc_parse_string

   procedure Get_Style (Widget : in     Gtk.Widget.Gtk_Widget'Class;
                        Style  :    out Gtk.Style.Gtk_Style);
   --  mapping: Get_Style gtkrc.h gtk_rc_get_style

   procedure Add_Widget_Name_Style (Style   : in out Gtk.Style.Gtk_Style;
                                    Pattern : in     String);
   --  mapping: Add_Widget_Name_Style gtkrc.h gtk_rc_add_widget_name_style

   procedure Add_Widget_Class_Style (Style   : in out Gtk.Style.Gtk_Style;
                                     Pattern : in     String);
   --  mapping: Add_Widget_Class_Style gtkrc.h gtk_rc_add_widget_class_style


   pragma Import (C, Init, "gtk_rc_init");

end Gtk.Rc;
