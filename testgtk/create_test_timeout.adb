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
with Gtk.Box; use Gtk.Box;
with Gtk.Button; use Gtk.Button;
with Gtk.Container; use Gtk.Container;
with Gtk.Dialog; use Gtk.Dialog;
with Gtk.Label; use Gtk.Label;
with Gtk.Main; use Gtk.Main;
with Gtk.Misc; use Gtk.Misc;
with Gtk.Signal; use Gtk.Signal;
with Gtk.Object; use Gtk.Object;
with Gtk.Status_Bar; use Gtk.Status_Bar;
with Gtk.Widget; use Gtk.Widget;
with Gtk; use Gtk;

package body Create_Test_Timeout is

   package Widget_Cb is new Signal.Object_Callback (Gtk_Widget);
   package Widget2_Cb is new Signal.Callback (Gtk_Widget, Gtk_Widget_Access);
   package Label_Timeout is new Timeout (Gtk_Label'Class);
   package Label_Cb is new Signal.Object_Callback (Gtk_Label);

   Dialog : aliased Gtk_Dialog;
   Timeout   : Guint;
   Count  : Integer := 0;

   function Timeout_Test (Label : in Gtk_Label'Class) return Boolean is
   begin
      Count := Count + 1;
      Set (Label, "count:" & Integer'Image (Count));
      return True;
   end Timeout_Test;

   procedure Stop_Timeout (Label : in out Gtk_Label'Class) is
      pragma Warnings (Off, Label);
   begin
      if Timeout /= 0 then
         Timeout_Remove (Timeout);
         Timeout := 0;
      end if;
   end Stop_Timeout;

   procedure Destroy_Timeout (Window : in out Gtk_Widget'Class) is
      Dummy_Label : Gtk_Label;
   begin
      Stop_Timeout (Dummy_Label);
      Gtk.Widget.Destroy (Window);
      Count := 0;
   end Destroy_Timeout;

   procedure Start_Timeout (Label : in out Gtk_Label'Class) is
   begin
      if Timeout = 0 then
         Timeout := Label_Timeout.Add (100, Timeout_Test'Access, Label);
      end if;
   end Start_Timeout;

   procedure Run (Widget : in out Gtk.Button.Gtk_Button'Class) is
      Id       : Guint;
      Button   : Gtk_Button;
      Label    : Gtk_Label;
   begin

      if not Is_Created (Dialog) then
         Gtk_New (Dialog);
         Id := Widget2_Cb.Connect (Dialog, "destroy", Destroyed'Access,
                                   Dialog'Access);
         Set_Title (Dialog, "Timeout Test");
         Border_Width (Dialog, Border_Width => 0);

         Gtk_New (Label, "count : 0");
         Set_Padding (Label, 10, 10);
         Pack_Start (Get_Vbox (Dialog), Label, True, True, 0);
         Show (Label);

         Gtk_New (Button, "close");
         Id := Widget_Cb.Connect (Button, "clicked", Destroy_Timeout'Access,
                                  Dialog);
         Set_Flags (Button, Can_Default);
         Grab_Default (Button);
         Pack_Start (Get_Action_Area (Dialog), Button, True, True, 0);
         Show (Button);

         Gtk_New (Button, "start");
         Id := Label_Cb.Connect (Button, "clicked", Start_Timeout'Access, Label);
         Set_Flags (Button, Can_Default);
         Pack_Start (Get_Action_Area (Dialog), Button, True, True, 0);
         Show (Button);

         Gtk_New (Button, "stop");
         Id := Label_Cb.Connect (Button, "clicked", Stop_Timeout'Access, Label);
         Set_Flags (Button, Can_Default);
         Pack_Start (Get_Action_Area (Dialog), Button, True, True, 0);
         Show (Button);
      end if;

      if not Gtk.Widget.Visible_Is_Set (Dialog) then
         Gtk.Widget.Show (Dialog);
      else
         Gtk.Widget.Destroy (Dialog);
      end if;

   end Run;

end Create_Test_Timeout;

