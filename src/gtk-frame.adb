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

with System;
with Gdk; use Gdk;

package body Gtk.Frame is

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Widget : out Gtk_Frame;
                      Label  : in String := "")
   is
      function Internal (Label  : in String)
                         return      System.Address;
      pragma Import (C, Internal, "gtk_frame_new");
   begin
      Set_Object (Widget, Internal (Label & Ascii.NUL));
   end Gtk_New;

   ---------------
   -- Set_Label --
   ---------------

   procedure Set_Label
      (Frame : in Gtk_Frame'Class;
       Label : in String)
   is
      procedure Internal
         (Frame : in System.Address;
          Label : in String);
      pragma Import (C, Internal, "gtk_frame_set_label");
   begin
      Internal (Get_Object (Frame),
                Label & Ascii.NUL);
   end Set_Label;

   ---------------------
   -- Set_Label_Align --
   ---------------------

   procedure Set_Label_Align
      (Frame  : in Gtk_Frame'Class;
       Xalign : in Gfloat;
       Yalign : in Gfloat)
   is
      procedure Internal
         (Frame  : in System.Address;
          Xalign : in Gfloat;
          Yalign : in Gfloat);
      pragma Import (C, Internal, "gtk_frame_set_label_align");
   begin
      Internal (Get_Object (Frame),
                Xalign,
                Yalign);
   end Set_Label_Align;

   ---------------------
   -- Set_Shadow_Type --
   ---------------------

   procedure Set_Shadow_Type
      (Frame    : in Gtk_Frame'Class;
       The_Type : in Gtk_Shadow_Type)
   is
      procedure Internal
         (Frame    : in System.Address;
          The_Type : in Gint);
      pragma Import (C, Internal, "gtk_frame_set_shadow_type");
   begin
      Internal (Get_Object (Frame),
                Gtk_Shadow_Type'Pos (The_Type));
   end Set_Shadow_Type;

end Gtk.Frame;
