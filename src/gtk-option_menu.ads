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

with Gtk.Button;
with Gtk.Widget;

package Gtk.Option_Menu is

   type Gtk_Option_Menu is new Button.Gtk_Button with private;


   procedure Gtk_New (Option_Menu : out Gtk_Option_Menu);
   --  mapping: Gtk_New gtkoptionmenu.h gtk_option_menu_new

   procedure Get_Menu (Option_Menu : in  Gtk_Option_Menu'Class;
                       Menu        : out Widget.Gtk_Widget'Class);
   --  mapping: Get_Menu gtkoptionmenu.h gtk_option_menu_get_menu

   procedure Set_Menu (Option_Menu : in out Gtk_Option_Menu'Class;
                       Menu        : in     Widget.Gtk_Widget'Class);
   --  mapping: Set_Menu gtkoptionmenu.h gtk_option_menu_set_menu

   procedure Remove_Menu (Option_Menu : in out Gtk_Option_Menu'Class;
                          Menu        : in     Widget.Gtk_Widget'Class);
   --  mapping: Remove_Menu gtkoptionmenu.h gtk_option_menu_remove_menu

   procedure Set_History (Option_Menu : in out Gtk_Option_Menu'Class;
                          Index       : in     Gint);
   --  mapping: Set_History gtkoptionmenu.h gtk_option_menu_set_history


private

   type Gtk_Option_Menu is new Button.Gtk_Button with null record;

   --  mapping: USE_OBJECT_ORIENTED gtkoptionmenu.h gtk_option_menu_get_type

end Gtk.Option_Menu;
