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

--  <c_version>1.3.4</c_version>

with Gtk.Adjustment;
with Gtk.Enums; use Gtk.Enums;
with Gtk.GRange;

package Gtk.Scale is

   type Gtk_Scale_Record is new Gtk.GRange.Gtk_Range_Record with private;
   subtype Gtk_Hscale_Record is Gtk_Scale_Record;
   subtype Gtk_Vscale_Record is Gtk_Scale_Record;

   type Gtk_Scale is access all Gtk_Scale_Record'Class;
   subtype Gtk_Hscale is Gtk_Scale;
   subtype Gtk_Vscale is Gtk_Scale;

   procedure Gtk_New_Hscale
     (Scale      : out Gtk_Scale;
      Adjustment : Gtk.Adjustment.Gtk_Adjustment);

   procedure Gtk_New_Vscale
     (Scale      : out Gtk_Scale;
      Adjustment : Gtk.Adjustment.Gtk_Adjustment);

   function Get_Type return Gtk.Gtk_Type;
   --  Return the internal value associated with a Gtk_Scale.

   procedure Initialize_Hscale
     (Scale      : access Gtk_Scale_Record'Class;
      Adjustment : Gtk.Adjustment.Gtk_Adjustment);

   procedure Initialize_Vscale
     (Scale      : access Gtk_Scale_Record'Class;
      Adjustment : Gtk.Adjustment.Gtk_Adjustment);

   procedure Set_Digits
     (Scale      : access Gtk_Scale_Record;
      The_Digits : Gint);

   procedure Set_Draw_Value
     (Scale      : access Gtk_Scale_Record;
      Draw_Value : Boolean);

   procedure Set_Value_Pos
     (Scale : access Gtk_Scale_Record;
      Pos   : Gtk_Position_Type);

   function Get_Value_Width (Scale : access Gtk_Scale_Record) return Gint;

   procedure Get_Value_Size
     (Scale  : access Gtk_Scale_Record;
      Width  : out Gint;
      Height : out Gint);

   procedure Draw_Value (Scale : access Gtk_Scale_Record);

private
   type Gtk_Scale_Record is new Gtk.GRange.Gtk_Range_Record with null record;

   pragma Import (C, Get_Type, "gtk_scale_get_type");
end Gtk.Scale;
