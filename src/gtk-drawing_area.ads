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


with Gtk.Widget;

package Gtk.Drawing_Area is

   type Gtk_Drawing_Area is new Gtk.Widget.Gtk_Widget with private;

   procedure Gtk_New (Widget : out Gtk_Drawing_Area);
   procedure Size
     (Darea  : in Gtk_Drawing_Area'Class;
      Width  : in Gint;
      Height : in Gint);

private

   type Gtk_Drawing_Area is new Gtk.Widget.Gtk_Widget with null record;

   --  mapping: NOT_IMPLEMENTED gtkdrawingarea.h gtk_drawing_area_get_type
   --  mapping: Gtk_New gtkdrawingarea.h gtk_drawing_area_new
   --  mapping: Size gtkdrawingarea.h gtk_drawing_area_size

end Gtk.Drawing_Area;
