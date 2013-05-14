------------------------------------------------------------------------------
--                  GtkAda - Ada95 binding for Gtk+/Gnome                   --
--                                                                          --
--                     Copyright (C) 2011-2013, AdaCore                     --
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

with Ada.Numerics; use Ada.Numerics;

with Glib;         use Glib;
with Glib.Error;   use Glib.Error;

with Cairo;        use Cairo;
with Pango.Cairo;  use Pango.Cairo;
with Gdk.Cairo;    use Gdk.Cairo;
with Gdk.Display;  use Gdk.Display;
with Gdk.RGBA;     use Gdk.RGBA;
with Gdk.Screen;   use Gdk.Screen;
with Gdk.Window;   use Gdk;

with Gtk.Enums;         use Gtk.Enums;
with Gtk.Style_Context; use Gtk.Style_Context;
with Gtk.Style;         use Gtk.Style;
with Gtk.Widget;        use Gtk.Widget;
with Gtk.Css_Provider;   use Gtk.Css_Provider;
with Gtk.Style_Provider; use Gtk.Style_Provider;

package body Gtkada.Style is

   Dec_To_Hex : constant array (0 .. 15) of Character :=
     (0 => '0', 1 => '1', 2 => '2', 3 => '3', 4 => '4', 5 => '5',
      6 => '6', 7 => '7', 8 => '8', 9 => '9', 10 => 'A', 11 => 'B',
      12 => 'C', 13 => 'D', 14 => 'E', 15 => 'F');

   ------------
   -- To_HSV --
   ------------

   function To_HSV (Color : Cairo_Color) return HSV_Color
   is
      Max, Min, Del       : Gdouble;
      Del_R, Del_G, Del_B : Gdouble;
      Ret                 : HSV_Color;
      Tmp                 : Gdouble;

   begin
      Max := Gdouble'Max (Gdouble'Max (Color.Red, Color.Green), Color.Blue);
      Min := Gdouble'Min (Gdouble'Min (Color.Red, Color.Green), Color.Blue);
      Del := Max - Min;

      Ret.V := Max;
      Ret.A := Color.Alpha;

      if Del = 0.0 then
         Ret.H := 0.0;
         Ret.S := 0.0;

      else
         Ret.S := Del / Max;

         Del_R := (((Del - Color.Red) / 6.0) + (Del / 2.0)) / Del;
         Del_G := (((Del - Color.Green) / 6.0) + (Del / 2.0)) / Del;
         Del_B := (((Del - Color.Blue) / 6.0) + (Del / 2.0)) / Del;

         if Max = Color.Red then
            Tmp := Del_B - Del_G;
         elsif Max = Color.Green then
            Tmp := (1.0 / 3.0) + Del_R - Del_B;
         elsif Max = Color.Blue then
            Tmp := (2.0 / 3.0) + Del_G - Del_R;
         end if;

         if Tmp < 0.0 then
            Tmp := Tmp + 1.0;
         end if;

         if Tmp >= 1.0 then
            Tmp := Tmp - 1.0;
         end if;

         Ret.H := Tmp;
      end if;

      return Ret;
   end To_HSV;

   --------------
   -- To_Cairo --
   --------------

   function To_Cairo (HSV : HSV_Color) return Cairo_Color
   is
      Var_H, Var_J, Var_1, Var_2, Var_3 : Gdouble;
      Ret  : Cairo_Color;

   begin
      Ret.Alpha := HSV.A;

      if HSV.S = 0.0 then
         Ret.Red := HSV.V;
         Ret.Green := HSV.V;
         Ret.Blue := HSV.V;

      else
         if HSV.H = 1.0 then
            Var_H := 0.0;
         else
            Var_H := HSV.H * 6.0;
         end if;

         Var_J := Gdouble'Floor (Var_H);
         Var_1 := HSV.V * (1.0 - HSV.S);
         Var_2 := HSV.V * (1.0 - HSV.S * (Var_H - Var_J));
         Var_3 := HSV.V * (1.0 - HSV.S * (1.0 - (Var_H - Var_J)));

         if Var_J = 0.0 then
            Ret.Red := HSV.V;
            Ret.Green := Var_3;
            Ret.Blue := Var_1;
         elsif Var_J = 1.0 then
            Ret.Red := Var_2;
            Ret.Green := HSV.V;
            Ret.Blue := Var_1;
         elsif Var_J = 2.0 then
            Ret.Red := Var_1;
            Ret.Green := HSV.V;
            Ret.Blue := Var_3;
         elsif Var_J = 3.0 then
            Ret.Red := Var_1;
            Ret.Green := Var_2;
            Ret.Blue := HSV.V;
         elsif Var_J = 4.0 then
            Ret.Red := Var_3;
            Ret.Green := Var_1;
            Ret.Blue := HSV.V;
         else
            Ret.Red := HSV.V;
            Ret.Green := Var_1;
            Ret.Blue := Var_2;
         end if;
      end if;

      return Ret;
   end To_Cairo;

   --------------
   -- To_Cairo --
   --------------

   function To_Cairo (Color : Gdk.Color.Gdk_Color) return Cairo_Color is
   begin
      return (Red   => Gdouble (Gdk.Color.Red (Color)) / 65535.0,
              Green => Gdouble (Gdk.Color.Green (Color)) / 65535.0,
              Blue  => Gdouble (Gdk.Color.Blue (Color)) / 65535.0,
              Alpha => 1.0);
   end To_Cairo;

   --------------
   -- To_Cairo --
   --------------

   function To_Cairo (Color : Gdk.RGBA.Gdk_RGBA) return Cairo_Color is
   begin
      return (Red   => Color.Red,
              Green => Color.Green,
              Blue => Color.Blue,
              Alpha => Color.Alpha);
   end To_Cairo;

   ------------
   -- To_Hex --
   ------------

   function To_Hex (Color : Gdk.RGBA.Gdk_RGBA) return String is
      function To_Hex (Val : Gdouble) return String;
      function To_Hex (Val : Gdouble) return String is
         V : constant Integer := Integer (Val * 255.0);
      begin
         return Dec_To_Hex (V / 16)
           & Dec_To_Hex (V mod 16);
      end To_Hex;

   begin
      return '#' & To_Hex (Color.Red)
        & To_Hex (Color.Green) & To_Hex (Color.Blue);
   end To_Hex;

   ----------------------
   -- Shade_Or_Lighten --
   ----------------------

   function Shade_Or_Lighten
     (Color  : Gdk.RGBA.Gdk_RGBA;
      Amount : Glib.Gdouble := 0.4) return Gdk.RGBA.Gdk_RGBA
   is
      --  See http://www.nbdtech.com/Blog/archive/2008/04/27/
      --    Calculating-the-Perceived-Brightness-of-a-Color.aspx

      Threshold : constant Gdouble := 130.0 * 130.0 / (255.0 * 255.0);

      --  The square of the brightness
      Brightness_Square : constant Gdouble :=
        Color.Red * Color.Red * 0.241
        + Color.Green * Color.Green * 0.691
        + Color.Blue * Color.Blue * 0.068;

      A : Gdouble;
   begin
      if Brightness_Square < Threshold then
         --  We cannot lighten pure black just by multiplying, so instead we do
         --  an addition, so that we still end up with a different color

         return (Red   => Gdouble'Min (Color.Red + Amount, 1.0),
                 Green => Gdouble'Min (Color.Green + Amount, 1.0),
                 Blue  => Gdouble'Min (Color.Blue + Amount, 1.0),
                 Alpha => 1.0);

      else
         A := 1.0 - Amount;   --  darken the color
         return (Red   => Gdouble'Min (Color.Red * A, 1.0),
                 Green => Gdouble'Min (Color.Green * A, 1.0),
                 Blue  => Gdouble'Min (Color.Blue * A, 1.0),
                 Alpha => 1.0);
      end if;
   end Shade_Or_Lighten;

   -----------
   -- Shade --
   -----------

   function Shade
     (Color : Gdk.Color.Gdk_Color;
      Value : Glib.Gdouble)
      return Cairo_Color
   is
   begin
      return Shade (To_Cairo (Color), Value);
   end Shade;

   -----------
   -- Shade --
   -----------

   function Shade
     (Color : Cairo_Color;
      Value : Glib.Gdouble)
      return Cairo_Color
   is
      HSV : HSV_Color;

   begin
      if Value /= 1.0 then
         HSV := To_HSV (Color);
         HSV.V := Gdouble'Min (1.0, HSV.V * Value);

         return To_Cairo (HSV);
      end if;

      return Color;
   end Shade;

   ----------------------
   -- Set_Source_Color --
   ----------------------

   procedure Set_Source_Color
     (Cr : Cairo.Cairo_Context; Color : Cairo_Color) is
   begin
      Cairo.Set_Source_Rgba
        (Cr, Color.Red, Color.Green, Color.Blue, Color.Alpha);
   end Set_Source_Color;

   -----------------------
   -- Rounded_Rectangle --
   -----------------------

   procedure Rounded_Rectangle
     (Cr         : Cairo.Cairo_Context;
      X, Y, W, H : Glib.Gdouble;
      Radius     : Glib.Gdouble)
   is
   begin
      New_Sub_Path (Cr);
      Cairo.Arc
        (Cr, X + W - Radius, Y + Radius, Radius, -Pi / 2.0, 0.0);
      Cairo.Arc
        (Cr, X + W - Radius, Y + H - Radius, Radius, 0.0, Pi / 2.0);
      Cairo.Arc
        (Cr, X + Radius, Y + H - Radius, Radius, Pi / 2.0, Pi);
      Cairo.Arc
        (Cr, X + Radius, Y + Radius, Radius, Pi, 3.0 * Pi / 2.0);
      Close_Path (Cr);
   end Rounded_Rectangle;

   -----------------
   -- Draw_Shadow --
   -----------------

   procedure Draw_Shadow
     (Cr                  : Cairo.Cairo_Context;
      Widget              : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      Shadow_Type         : Gtk.Enums.Gtk_Shadow_Type;
      X, Y, Width, Height : Glib.Gint;
      Corner_Radius       : Glib.Gdouble := 0.0)
   is
      Hilight : Cairo_Color;
      Shadow  : Cairo_Color;
      HSV     : HSV_Color;

      Ctx : constant Gtk_Style_Context := Get_Style_Context (Widget);
      Border : Gtk_Border;

      X_Thick : Gdouble;
      Radius  : Gdouble;
      dX, dY, dW, dH : Gdouble;
      Color : Gdk_RGBA;

   begin
      if Shadow_Type = Shadow_None then
         return;
      end if;

      Ctx.Get_Border (Gtk_State_Flag_Normal, Border);

      X_Thick := Gdouble (Border.Left + Border.Right);
      Ctx.Get_Background_Color (Gtk_State_Flag_Normal, Color);

      Cairo.Save (Cr);

      HSV := To_HSV (To_Cairo (Color));

      HSV.V := 0.3;
      Shadow := To_Cairo (HSV);

      HSV.V := 0.9;
      Hilight := To_Cairo (HSV);

      dX := Gdouble (X) + X_Thick + 0.5;
      dY := Gdouble (Y) + X_Thick + 0.5;
      dW := Gdouble (Width) - 2.0 * X_Thick - 1.0;
      dH := Gdouble (Height) - 2.0 * X_Thick - 1.0;

      if Corner_Radius < X_Thick then
         Radius := X_Thick;
      else
         Radius := Corner_Radius;
      end if;

      if Shadow_Type = Shadow_Out or else Shadow_Type = Shadow_Etched_Out then
         Set_Line_Width (Cr, X_Thick);
         Set_Source_Color (Cr, Hilight);

      else
         if X_Thick < 0.5 then
            Set_Line_Width (Cr, 0.5);
         else
            Set_Line_Width (Cr, X_Thick);
         end if;

         Set_Source_Color (Cr, Shadow);
      end if;

      Rounded_Rectangle
        (Cr, dX, dY, dW, dH, Radius);
      Cairo.Stroke (Cr);

      if Shadow_Type = Shadow_Out or else Shadow_Type = Shadow_Etched_Out then
         if X_Thick < 0.5 then
            Set_Line_Width (Cr, 0.5);
         else
            Set_Line_Width (Cr, X_Thick);
         end if;

         Set_Source_Color (Cr, Shadow);

      else
         Set_Line_Width (Cr, X_Thick);
         Set_Source_Color (Cr, Hilight);
      end if;

      Rounded_Rectangle
        (Cr,
         dX + X_Thick, dY + X_Thick, dW - 2.0 * X_Thick, dH - 2.0 * X_Thick,
         Radius - X_Thick * 1.0);
      Cairo.Stroke (Cr);

      Cairo.Restore (Cr);
   end Draw_Shadow;

   --------------------
   -- Draw_Rectangle --
   --------------------

   procedure Draw_Rectangle
     (Cr                  : Cairo.Cairo_Context;
      Color               : Gdk.Color.Gdk_Color;
      Filled              : Boolean;
      X, Y, Width, Height : Glib.Gint;
      Corner_Radius       : Glib.Gdouble := 0.0) is
   begin
      Draw_Rectangle
        (Cr, To_Cairo (Color), Filled, X, Y, Width, Height, Corner_Radius);
   end Draw_Rectangle;

   --------------------
   -- Draw_Rectangle --
   --------------------

   procedure Draw_Rectangle
     (Cr                  : Cairo.Cairo_Context;
      Color               : Cairo_Color;
      Filled              : Boolean;
      X, Y, Width, Height : Glib.Gint;
      Corner_Radius       : Glib.Gdouble := 0.0)
   is
      dX, dY, dW, dH : Gdouble;
      Line_Width     : Gdouble;

   begin
      dX := Gdouble (X);
      dY := Gdouble (Y);
      dW := Gdouble (Width);
      dH := Gdouble (Height);

      if not Filled then
         Line_Width := Get_Line_Width (Cr) / 2.0;
         dX := dX + Line_Width;
         dY := dY + Line_Width;
         dW := dW - 2.0 * Line_Width;
         dH := dH - 2.0 * Line_Width;
      end if;

      if Corner_Radius = 0.0 then
         Rectangle (Cr, dX, dY, dW, dH);
      else
         Rounded_Rectangle (Cr, dX, dY, dW, dH, Corner_Radius);
      end if;

      Set_Source_Color (Cr, Color);

      if Filled then
         Cairo.Fill (Cr);
      else
         Stroke (Cr);
      end if;
   end Draw_Rectangle;

   ---------------
   -- Draw_Line --
   ---------------

   procedure Draw_Line
     (Cr             : Cairo.Cairo_Context;
      Color          : Gdk.Color.Gdk_Color;
      X1, Y1, X2, Y2 : Glib.Gint) is
   begin
      Draw_Line (Cr, To_Cairo (Color), X1, Y1, X2, Y2);
   end Draw_Line;

   ---------------
   -- Draw_Line --
   ---------------

   procedure Draw_Line
     (Cr             : Cairo.Cairo_Context;
      Color          : Cairo_Color;
      X1, Y1, X2, Y2 : Glib.Gint)
   is
      Line_Width     : Gdouble;
   begin
      Set_Source_Color (Cr, Color);
      Line_Width := Get_Line_Width (Cr) / 2.0;

      Move_To (Cr, Gdouble (X1) + Line_Width, Gdouble (Y1) + Line_Width);
      Line_To (Cr, Gdouble (X2) + Line_Width, Gdouble (Y2) + Line_Width);
      Stroke (Cr);
   end Draw_Line;

   -----------------
   -- Draw_Layout --
   -----------------

   procedure Draw_Layout
     (Cr     : Cairo.Cairo_Context;
      Color  : Gdk.Color.Gdk_Color;
      X, Y   : Glib.Gint;
      Layout : Pango.Layout.Pango_Layout)
   is
   begin
      Draw_Layout (Cr, To_Cairo (Color), X, Y, Layout);
   end Draw_Layout;

   -----------------
   -- Draw_Layout --
   -----------------

   procedure Draw_Layout
     (Cr     : Cairo.Cairo_Context;
      Color  : Cairo_Color;
      X, Y   : Glib.Gint;
      Layout : Pango.Layout.Pango_Layout)
   is
   begin
      Set_Source_Color (Cr, Color);
      Move_To (Cr, Gdouble (X), Gdouble (Y));
      Pango.Cairo.Show_Layout (Cr, Layout);
   end Draw_Layout;

   -----------------
   -- Draw_Pixbuf --
   -----------------

   procedure Draw_Pixbuf
     (Cr     : Cairo.Cairo_Context;
      Pixbuf : Gdk.Pixbuf.Gdk_Pixbuf;
      X, Y   : Glib.Gint)
   is
   begin
      Gdk.Cairo.Set_Source_Pixbuf (Cr, Pixbuf, Gdouble (X), Gdouble (Y));
      Cairo.Paint (Cr);
   end Draw_Pixbuf;

   --------------
   -- Snapshot --
   --------------

   function Snapshot
     (Widget : not null access Gtk_Widget_Record'Class)
      return Cairo.Cairo_Surface
   is
      Ctx     : Cairo_Context;
      Surface : Cairo_Surface;
      Color   : Gdk_RGBA;

      Window_Provider  : Gtk_Widget := Gtk_Widget (Widget);
   begin
      Surface := Gdk.Window.Create_Similar_Surface
        (Self    => Get_Window (Widget),
         Content => Cairo_Content_Color,
         Width   => Get_Allocated_Width (Widget),
         Height  => Get_Allocated_Height (Widget));

      while Window_Provider /= null
        and then not Window_Provider.Get_Has_Window
      loop
         Window_Provider := Window_Provider.Get_Parent;
      end loop;

      if Window_Provider /= null then
         Get_Style_Context (Window_Provider).Get_Background_Color
           (Gtk_State_Flag_Normal, Color);
      end if;

      Ctx := Create (Surface);
      Set_Source_RGBA (Ctx, Color);
      Paint (Ctx);
      Draw (Widget, Ctx);  --  Capture current rendering
      Destroy (Ctx);
      return Surface;
   end Snapshot;

   -------------------
   -- Load_Css_File --
   -------------------

   procedure Load_Css_File
     (Path : String; Error : access procedure (Str : String) := null)
   is
      Css     : Gtk_Css_Provider;
      Display : Gdk_Display;
      Screen  : Gdk_Screen;
      Err     : aliased GError;
   begin
      Gtk_New (Css);
      if not Css.Load_From_Path (Path, Err'Access) then
         if Error /= null then
            Error (Get_Message (Err));
         end if;
      else
         Display := Get_Default;
         Screen  := Get_Default_Screen (Display);
         Gtk.Style_Context.Add_Provider_For_Screen
           (Screen, +Css, Priority => Priority_Theme + 1);
      end if;

      Unref (Css);
   end Load_Css_File;

   ---------------------
   -- Load_Css_String --
   ---------------------

   procedure Load_Css_String
     (Data : String; Error : access procedure (Str : String) := null)
   is
      Css     : Gtk_Css_Provider;
      Display : Gdk_Display;
      Screen  : Gdk_Screen;
      Err     : aliased GError;
   begin
      Gtk_New (Css);
      if not Css.Load_From_Data (Data, Err'Access) then
         if Error /= null then
            Error (Get_Message (Err));
         end if;
      else
         Display := Get_Default;
         Screen  := Get_Default_Screen (Display);
         Gtk.Style_Context.Add_Provider_For_Screen
           (Screen, +Css, Priority => Priority_Theme + 1);
      end if;

      Unref (Css);
   end Load_Css_String;

   ----------------
   -- Get_Offset --
   ----------------

   procedure Get_Offset
     (Window : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      Parent : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      X, Y   : out Gint)
   is
      Parent_Win : constant Gdk_Window := Parent.Get_Window;
      Win      : Gdk_Window := Window.Get_Window;
      Wx, Wy   : Gint;
   begin
      X := 0;
      Y := 0;
      while Win /= null and then Win /= Parent_Win loop
         Gdk.Window.Get_Position (Win, Wx, Wy);
         X := X + Wx;
         Y := Y + Wy;
         Win := Gdk.Window.Get_Parent (Win);
      end loop;
   end Get_Offset;

   ------------------
   -- Draw_Overlay --
   ------------------

   procedure Draw_Overlay
     (Widget  : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      Overlay : in out Cairo.Cairo_Surface;
      Do_Draw : not null access procedure
        (Context : Cairo.Cairo_Context;
         Draw    : Boolean))
   is
      Toplevel : constant Gtk_Widget := Widget.Get_Toplevel;
      X, Y     : Gint := 0;  --  location of Split relative to Toplevel
      Top_Win  : constant Gdk_Window := Toplevel.Get_Window;
      Hide_Previous : Boolean := True;

   begin
      Get_Offset (Widget, Toplevel, X, Y);

      --  Save the display of the toplevel window, so that we can easily
      --  erase the resize handle later. We cannot capture Split only,
      --  because that would not include a background color if Split does
      --  not have a window.
      --  ??? Apparently, we need to redraw once, we can't simply capture
      --  the screen. There might be a way using:
      --     pixbuf = gtk.gdk.Pixbuf(gtk.gdk.COLORSPACE_RGB, False, 9, w, h)
      --     shot = pixbuf.get_from_drawable(win.window, win.get_colormap(),
      --                  0, 0, 0, 0, w, h)

      if Overlay = Null_Surface then
         declare
            Cr2 : Cairo_Context;
         begin
            Overlay := Gdk.Window.Create_Similar_Surface
              (Self    => Top_Win,
               Content => Cairo_Content_Color,
               Width   => Toplevel.Get_Allocated_Width,
               Height  => Toplevel.Get_Allocated_Height);
            Cr2 := Create (Overlay);
            Reset_Clip (Cr2);

            --  ??? Optimization: we could translate and clip Cr2, so that
            --  only the part of Toplevel corresponding to Split is actually
            --  stored in Split.Overlay.
--              Cairo.Rectangle
--                (Cr2,
--                 Gdouble (X - 5), Gdouble (Y - 5),
--                 Gdouble (Get_Allocated_Width (Split) + 10),
--                 Gdouble (Get_Allocated_Height (Split) + 10));
--              Cairo.Clip (Cr2);

            Draw (Toplevel, Cr2);
            Destroy (Cr2);

            Hide_Previous := False;
         end;
      end if;

      declare
         --  The call to Gdk.Cairo.Create returns a new cairo_context which
         --  is clipped. Drawing on it would in fact show nothing below the
         --  child windows. One way to create a usable context would be to
         --  use:
         --      Surf : constant Cairo_Surface := Cairo.Get_Target (Cr);
         --      Cr3  : constant Cairo_Context := Create (Surf);
         --  But in fact it seems we can safely call Reset_Clip instead on
         --  the context.

         Cr      : constant Cairo_Context := Gdk.Cairo.Create (Top_Win);
      begin
         Reset_Clip (Cr);  --  draw on top of child windows
         Translate (Cr, Gdouble (X), Gdouble (Y));

         if Hide_Previous then
            Cairo.Save (Cr);

            --  Position is x_dest - x_src, y_dest - y_src
            --     Where x_dest is the location at which we are drawing
            --     within the target cairo_context, i.e. X + Handle_X
            --     and x_src is the location within the overlay from which
            --     we are copying, ie X + Handle_X
            --  However, this position does not take into account the
            --  translation of the context, so we have to compensate.
            Set_Source_Surface (Cr, Overlay, -Gdouble (X), -Gdouble (Y));

            Set_Operator (Cr, Cairo_Operator_Source);
            Do_Draw (Cr, Draw => False);
            Cairo.Restore (Cr);
         end if;

         Do_Draw (Cr, Draw => True);
         Cairo.Destroy (Cr);
      end;
   end Draw_Overlay;

   --------------------
   -- Delete_Overlay --
   --------------------

   procedure Delete_Overlay
     (Widget  : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      Overlay : in out Cairo.Cairo_Surface)
   is
   begin
      if Overlay /= Null_Surface then
         Surface_Destroy (Overlay);
         Overlay := Null_Surface;

         --  Force a redraw
         Gdk.Window.Invalidate_Rect
           (Widget.Get_Window,
            (0, 0, Widget.Get_Allocated_Width,
             Widget.Get_Allocated_Height), True);
      end if;
   end Delete_Overlay;

   -------------
   -- Lighten --
   -------------

   function Lighten
     (Color : Gdk.RGBA.Gdk_RGBA;
      Amount : Glib.Gdouble) return Gdk.RGBA.Gdk_RGBA is
   begin
      return (Red   => Glib.Gdouble'Min (1.0, Color.Red + Amount),
              Green => Glib.Gdouble'Min (1.0, Color.Green + Amount),
              Blue  => Glib.Gdouble'Min (1.0, Color.Blue + Amount),
              Alpha => Color.Alpha);
   end Lighten;

end Gtkada.Style;
