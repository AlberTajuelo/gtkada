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

with Glib; use Glib;
with Gtk.Button; use Gtk.Button;
with Gtk.Container; use Gtk.Container;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Frame; use Gtk.Frame;
with Gtk.Signal; use Gtk.Signal;
with Gtk.Paned; use Gtk.Paned;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Window; use Gtk.Window;
with Gtk; use Gtk;

package body Create_Paned is

   package Widget_Cb is new Signal.Object_Callback (Gtk_Widget);

   Window : Gtk.Window.Gtk_Window;

   procedure Run (Widget : in out Gtk.Button.Gtk_Button'Class) is
      VPaned : Gtk_Paned;
      HPaned : Gtk_Paned;
      Frame  : Gtk_Frame;
      Button : Gtk_Button;
      Id     : Guint;
   begin

      if not Is_Created (Window) then
         Gtk_New (Window, Window_Toplevel);
         Id := Widget_Cb.Connect (Window, "destroy", Destroy'Access, Window);
         Set_Title (Window, "Panes");
         Border_Width (Window, Border_Width => 0);

         Gtk_New_Vpaned (VPaned);
         Add (Window, VPaned);
         Border_Width (VPaned, 5);
         Show (VPaned);

         Gtk_New_Hpaned (HPaned);
         Add1 (Vpaned, HPaned);

         Gtk_New (Frame);
         Set_Shadow_Type (Frame, Shadow_In);
         Set_Usize (Frame, 60, 60);
         Add1 (HPaned, Frame);
         Show (Frame);

         Gtk_New (Button, "Hi There");
         Add (Frame, Button);
         Show (Button);

         Gtk_New (Frame);
         Set_Shadow_Type (Frame, Shadow_In);
         Set_Usize (Frame, 80, 60);
         Add2 (HPaned, Frame);
         Show (Frame);

         Show (HPaned);

         Gtk_New (Frame);
         Set_Shadow_Type (Frame, Shadow_In);
         Set_Usize (Frame, 60, 80);
         Add2 (VPaned, Frame);
         Show (Frame);
      end if;

      if not Gtk.Widget.Visible_Is_Set (Window) then
         Gtk.Widget.Show (Window);
      else
         Gtk.Widget.Destroy (Window);
      end if;

   end Run;

end Create_Paned;
