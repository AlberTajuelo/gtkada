-----------------------------------------------------------------------
--               GtkAda - Ada95 binding for Gtk+/Gnome               --
--                                                                   --
--   Copyright (C) 1998-2000 E. Briot, J. Brobecker and A. Charlet   --
--                Copyright (C) 2000-2001 ACT-Europe                 --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-- As a special exception, if other files instantiate generics from  --
-- this unit, or you link this unit with other files to produce an   --
-- executable, this  unit  does not  by itself cause  the resulting  --
-- executable to be covered by the GNU General Public License. This  --
-- exception does not however invalidate any other reasons why the   --
-- executable file  might be covered by the  GNU Public License.     --
-----------------------------------------------------------------------

--  <c_version>1.3.6</c_version>

with Gtk.Adjustment;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Widget;

package Gtk.GRange is

   type Gtk_Range_Record is new Gtk.Widget.Gtk_Widget_Record with private;
   type Gtk_Range is access all Gtk_Range_Record'Class;
   subtype Gtk_GRange is Gtk_Range;

   function Get_Type return Gtk.Gtk_Type;
   --  Return the internal value associated with a Gtk_Range.

   procedure Set_Update_Policy
     (The_Range : access Gtk_Range_Record;
      Policy    : Gtk_Update_Type);

   function Get_Adjustment
     (The_Range : access Gtk_Range_Record)
      return Gtk.Adjustment.Gtk_Adjustment;

   procedure Set_Adjustment
     (The_Range  : access Gtk_Range_Record;
      Adjustment : Gtk.Adjustment.Gtk_Adjustment);

   procedure Set_Inverted
     (The_Range : access Gtk_Range_Record;
      Setting   : Boolean := True);

   function Get_Inverted (The_Range : access Gtk_Range_Record) return Boolean;

   procedure Set_Increments
     (The_Range : access Gtk_Range_Record;
      Step      : Gdouble;
      Page      : Gdouble);
   --  Set the Step and the Page size for the range. The Step size is used when
   --  the user clicks on the Gtk_Scrollbar arrows or moves the Gtk_Scale via
   --  the arrow keys. The Page size is used when moving by pages via the
   --  Page-Up and Page-Down keys for instance.

   procedure Set_Range
     (The_Range : access Gtk_Range_Record;
      Min       : Gdouble;
      Max       : Gdouble);
   --  Set the allowable values in the Gtk_Range, and clamps the range value to
   --  the between Min and Max.

   procedure Set_Value
     (The_Range : access Gtk_Range_Record;
      Value     : Gdouble);
   --  Set the current value of the given Range. If the value is outside the
   --  minimum or the maximum value range, it will be clamped to fit inside
   --  the range.
   --  Cause the "value_changed" signal to be emitted if the value is
   --  different.

   function Get_Value (The_Range : access Gtk_Range_Record) return Gdouble;
   --  Return the current value of the range.

   ----------------
   -- Properties --
   ----------------

   --  <properties>
   --  The following properties are defined for this widget. See
   --  Glib.Properties for more information on properties.
   --
   --  - Name:  Update_Policy_Property
   --    Type:  Gtk_Update_Type
   --    Flags: read-write
   --    Descr: How the range should be updated on the screen
   --    See also: Set_Update_Policy
   --
   --  </properties>

   Update_Policy_Property : constant Gtk.Enums.Property_Gtk_Update_Type;

private
   type Gtk_Range_Record is new Gtk.Widget.Gtk_Widget_Record with null record;

   Update_Policy_Property : constant Gtk.Enums.Property_Gtk_Update_Type :=
     Gtk.Enums.Build ("update_policy");

   pragma Import (C, Get_Type, "gtk_range_get_type");
end Gtk.GRange;
