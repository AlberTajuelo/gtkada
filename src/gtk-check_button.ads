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

with Gtk.Toggle_Button;

package Gtk.Check_Button is

   type Gtk_Check_Button is new Toggle_Button.Gtk_Toggle_Button with private;


   procedure Gtk_New (Widget : out Gtk_Check_Button);
   --  mapping: Create_New gtkcheckbutton.h gtk_check_button_new

   procedure Gtk_New (Widget : out Gtk_Check_Button;
                      With_Label : in String);
   --  mapping: Create_New gtkcheckbutton.h gtk_check_button_new_with_label

private

   type Gtk_Check_Button is new Toggle_Button.Gtk_Toggle_Button
     with null record;

   --  Services not mappend ...
   --
   --  mapping: USE_OBJECT_ORIENTED gtkcheckbutton.h gtk_check_button_get_type

end Gtk.Check_Button;

