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


with Gtk.Bin;

package Gtk.Item is

   type Gtk_Item is new Bin.Gtk_Bin with private;

   procedure Item_Select (Item : in Gtk_Item'Class);
   --  mapping: Item_Select gtkitem.h gtk_item_select

   procedure Item_Deselect (Item : in Gtk_Item'Class);
   --  mapping: Item_Deselect gtkitem.h gtk_item_deselect

   procedure Toggle (Item : in Gtk_Item'Class);
   --  mapping: Toggle gtkitem.h gtk_item_toggle

private

   type Gtk_Item is new Gtk.Bin.Gtk_Bin with null record;

   --  mapping: USE_OBJECT_ORIENTED gtkitem.h gtk_item_get_type

end Gtk.Item;
