------------------------------------------------------------------------------
--                                                                          --
--      Copyright (C) 1998-2000 E. Briot, J. Brobecker and A. Charlet       --
--                     Copyright (C) 2000-2012, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

pragma Style_Checks (Off);
pragma Warnings (Off, "*is already use-visible*");
with Glib.Type_Conversion_Hooks; use Glib.Type_Conversion_Hooks;
with Interfaces.C.Strings;       use Interfaces.C.Strings;

package body Gtk.Info_Bar is

   package Type_Conversion_Gtk_Info_Bar is new Glib.Type_Conversion_Hooks.Hook_Registrator
     (Get_Type'Access, Gtk_Info_Bar_Record);
   pragma Unreferenced (Type_Conversion_Gtk_Info_Bar);

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Self : out Gtk_Info_Bar) is
   begin
      Self := new Gtk_Info_Bar_Record;
      Gtk.Info_Bar.Initialize (Self);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Self : not null access Gtk_Info_Bar_Record'Class) is
      function Internal return System.Address;
      pragma Import (C, Internal, "gtk_info_bar_new");
   begin
      Set_Object (Self, Internal);
   end Initialize;

   -----------------------
   -- Add_Action_Widget --
   -----------------------

   procedure Add_Action_Widget
      (Self        : not null access Gtk_Info_Bar_Record;
       Child       : not null access Gtk.Widget.Gtk_Widget_Record'Class;
       Response_Id : Gint)
   is
      procedure Internal
         (Self        : System.Address;
          Child       : System.Address;
          Response_Id : Gint);
      pragma Import (C, Internal, "gtk_info_bar_add_action_widget");
   begin
      Internal (Get_Object (Self), Get_Object (Child), Response_Id);
   end Add_Action_Widget;

   ----------------
   -- Add_Button --
   ----------------

   function Add_Button
      (Self        : not null access Gtk_Info_Bar_Record;
       Button_Text : UTF8_String;
       Response_Id : Gint) return Gtk.Widget.Gtk_Widget
   is
      function Internal
         (Self        : System.Address;
          Button_Text : Interfaces.C.Strings.chars_ptr;
          Response_Id : Gint) return System.Address;
      pragma Import (C, Internal, "gtk_info_bar_add_button");
      Tmp_Button_Text : Interfaces.C.Strings.chars_ptr := New_String (Button_Text);
      Stub_Gtk_Widget : Gtk.Widget.Gtk_Widget_Record;
      Tmp_Return      : System.Address;
   begin
      Tmp_Return := Internal (Get_Object (Self), Tmp_Button_Text, Response_Id);
      Free (Tmp_Button_Text);
      return Gtk.Widget.Gtk_Widget (Get_User_Data (Tmp_Return, Stub_Gtk_Widget));
   end Add_Button;

   ---------------------
   -- Get_Action_Area --
   ---------------------

   function Get_Action_Area
      (Self : not null access Gtk_Info_Bar_Record)
       return Gtk.Widget.Gtk_Widget
   is
      function Internal (Self : System.Address) return System.Address;
      pragma Import (C, Internal, "gtk_info_bar_get_action_area");
      Stub_Gtk_Widget : Gtk.Widget.Gtk_Widget_Record;
   begin
      return Gtk.Widget.Gtk_Widget (Get_User_Data (Internal (Get_Object (Self)), Stub_Gtk_Widget));
   end Get_Action_Area;

   ----------------------
   -- Get_Content_Area --
   ----------------------

   function Get_Content_Area
      (Self : not null access Gtk_Info_Bar_Record)
       return Gtk.Widget.Gtk_Widget
   is
      function Internal (Self : System.Address) return System.Address;
      pragma Import (C, Internal, "gtk_info_bar_get_content_area");
      Stub_Gtk_Widget : Gtk.Widget.Gtk_Widget_Record;
   begin
      return Gtk.Widget.Gtk_Widget (Get_User_Data (Internal (Get_Object (Self)), Stub_Gtk_Widget));
   end Get_Content_Area;

   ----------------------
   -- Get_Message_Type --
   ----------------------

   function Get_Message_Type
      (Self : not null access Gtk_Info_Bar_Record)
       return Gtk.Message_Dialog.Gtk_Message_Type
   is
      function Internal
         (Self : System.Address) return Gtk.Message_Dialog.Gtk_Message_Type;
      pragma Import (C, Internal, "gtk_info_bar_get_message_type");
   begin
      return Internal (Get_Object (Self));
   end Get_Message_Type;

   --------------
   -- Response --
   --------------

   procedure Response
      (Self        : not null access Gtk_Info_Bar_Record;
       Response_Id : Gint)
   is
      procedure Internal (Self : System.Address; Response_Id : Gint);
      pragma Import (C, Internal, "gtk_info_bar_response");
   begin
      Internal (Get_Object (Self), Response_Id);
   end Response;

   --------------------------
   -- Set_Default_Response --
   --------------------------

   procedure Set_Default_Response
      (Self        : not null access Gtk_Info_Bar_Record;
       Response_Id : Gint)
   is
      procedure Internal (Self : System.Address; Response_Id : Gint);
      pragma Import (C, Internal, "gtk_info_bar_set_default_response");
   begin
      Internal (Get_Object (Self), Response_Id);
   end Set_Default_Response;

   ----------------------
   -- Set_Message_Type --
   ----------------------

   procedure Set_Message_Type
      (Self         : not null access Gtk_Info_Bar_Record;
       Message_Type : Gtk.Message_Dialog.Gtk_Message_Type)
   is
      procedure Internal
         (Self         : System.Address;
          Message_Type : Gtk.Message_Dialog.Gtk_Message_Type);
      pragma Import (C, Internal, "gtk_info_bar_set_message_type");
   begin
      Internal (Get_Object (Self), Message_Type);
   end Set_Message_Type;

   ----------------------------
   -- Set_Response_Sensitive --
   ----------------------------

   procedure Set_Response_Sensitive
      (Self        : not null access Gtk_Info_Bar_Record;
       Response_Id : Gint;
       Setting     : Boolean)
   is
      procedure Internal
         (Self        : System.Address;
          Response_Id : Gint;
          Setting     : Integer);
      pragma Import (C, Internal, "gtk_info_bar_set_response_sensitive");
   begin
      Internal (Get_Object (Self), Response_Id, Boolean'Pos (Setting));
   end Set_Response_Sensitive;

   ---------------------
   -- Get_Orientation --
   ---------------------

   function Get_Orientation
      (Self : not null access Gtk_Info_Bar_Record)
       return Gtk.Enums.Gtk_Orientation
   is
      function Internal
         (Self : System.Address) return Gtk.Enums.Gtk_Orientation;
      pragma Import (C, Internal, "gtk_orientable_get_orientation");
   begin
      return Internal (Get_Object (Self));
   end Get_Orientation;

   ---------------------
   -- Set_Orientation --
   ---------------------

   procedure Set_Orientation
      (Self        : not null access Gtk_Info_Bar_Record;
       Orientation : Gtk.Enums.Gtk_Orientation)
   is
      procedure Internal
         (Self        : System.Address;
          Orientation : Gtk.Enums.Gtk_Orientation);
      pragma Import (C, Internal, "gtk_orientable_set_orientation");
   begin
      Internal (Get_Object (Self), Orientation);
   end Set_Orientation;

end Gtk.Info_Bar;
