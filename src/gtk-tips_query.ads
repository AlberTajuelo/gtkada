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


with Gtk.Label;
with Gtk.Widget;

package Gtk.Tips_Query is

   type Gtk_Tips_Query is new Gtk.Label.Gtk_Label with private;

   procedure Gtk_New (Widget : out Gtk_Tips_Query);
   procedure Set_Caller
      (Tips_Query : in Gtk_Tips_Query'Class;
       Caller     : in Gtk.Widget.Gtk_Widget'Class);
   procedure Set_Labels
      (Tips_Query     : in Gtk_Tips_Query'Class;
       Label_Inactive : in String;
       Label_No_Tip   : in String);
   procedure Start_Query (Tips_Query : in out Gtk_Tips_Query'Class);
   procedure Stop_Query (Tips_Query : in out Gtk_Tips_Query'Class);

private
   type Gtk_Tips_Query is new Gtk.Label.Gtk_Label with null record;

   --  mapping: NOT_IMPLEMENTED gtktipsquery.h gtk_tips_query_get_type
   --  mapping: Gtk_New gtktipsquery.h gtk_tips_query_new
   --  mapping: Set_Caller gtktipsquery.h gtk_tips_query_set_caller
   --  mapping: Set_Labels gtktipsquery.h gtk_tips_query_set_labels
   --  mapping: Start_Query gtktipsquery.h gtk_tips_query_start_query
   --  mapping: Stop_Query gtktipsquery.h gtk_tips_query_stop_query
end Gtk.Tips_Query;
