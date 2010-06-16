-----------------------------------------------------------------------
--               GtkAda - Ada95 binding for Gtk+/Gnome               --
--                                                                   --
--                    Copyright (C) 2010, AdaCore                    --
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

pragma Ada_2005;

with System;
with Interfaces.C.Strings;

with Glib; use Glib;

package Cairo.Matrix is

   procedure Init
     (Matrix : access Cairo_Matrix;
      Xx     : Gdouble;
      Yx     : Gdouble;
      Xy     : Gdouble;
      Yy     : Gdouble;
      X0     : Gdouble;
      Y0     : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Xx: Xx component of the affine transformation
   --  Yx: Yx component of the affine transformation
   --  Xy: Xy component of the affine transformation
   --  Yy: Yy component of the affine transformation
   --  X0: X translation component of the affine transformation
   --  Y0: Y translation component of the affine transformation
   --
   --  Sets matrix to be the affine transformation given by
   --  xx, yx, xy, yy, x0, y0. The transformation is given
   --  by:
   --  <programlisting>
   --   x_new = xx * x + xy * y + x0;
   --   y_new = yx * x + yy * y + y0;
   --  </programlisting>

   procedure Init_Identity (Matrix : access Cairo_Matrix);
   --  Matrix: a Cairo_Matrix
   --
   --  Modifies matrix to be an identity transformation.

   procedure Init_Translate
     (Matrix : access Cairo_Matrix;
      Tx     : Gdouble;
      Ty     : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Tx: amount to translate in the X direction
   --  Ty: amount to translate in the Y direction
   --
   --  Initializes matrix to a transformation that translates by tx and
   --  ty in the X and Y dimensions, respectively.

   procedure Init_Scale
     (Matrix : access Cairo_Matrix;
      Sx     : Gdouble;
      Sy     : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Sx: scale factor in the X direction
   --  Sy: scale factor in the Y direction
   --
   --  Initializes matrix to a transformation that scales by sx and sy
   --  in the X and Y dimensions, respectively.

   procedure Init_Rotate (Matrix : access Cairo_Matrix; Radians : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Radians: angle of rotation, in Radians. The direction of rotation
   --  is defined such that positive angles rotate in the direction from
   --  the positive X axis toward the positive Y axis. With the default
   --  axis orientation of cairo, positive angles rotate in a clockwise
   --  direction.
   --
   --  Initialized matrix to a transformation that rotates by radians.

   procedure Translate
     (Matrix : access Cairo_Matrix;
      Tx     : Gdouble;
      Ty     : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Tx: amount to translate in the X direction
   --  Ty: amount to translate in the Y direction
   --
   --  Applies a translation by tx, ty to the transformation in
   --  matrix. The effect of the new transformation is to first translate
   --  the coordinates by tx and ty, then apply the original transformation
   --  to the coordinates.

   procedure Scale
     (Matrix : access Cairo_Matrix;
      Sx     : Gdouble;
      Sy     : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Sx: scale factor in the X direction
   --  Sy: scale factor in the Y direction
   --
   --  Applies scaling by sx, sy to the transformation in matrix. The
   --  effect of the new transformation is to first scale the coordinates
   --  by sx and sy, then apply the original transformation to the coordinates.

   procedure Rotate (Matrix : access Cairo_Matrix; Radians : Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Radians: angle of rotation, in Radians. The direction of rotation
   --  is defined such that positive angles rotate in the direction from
   --  the positive X axis toward the positive Y axis. With the default
   --  axis orientation of cairo, positive angles rotate in a clockwise
   --  direction.
   --
   --  Applies rotation by radians to the transformation in
   --  matrix. The effect of the new transformation is to first rotate the
   --  coordinates by radians, then apply the original transformation
   --  to the coordinates.

   function Invert (Matrix : access Cairo_Matrix) return Cairo_Status;
   --  Matrix: a Cairo_Matrix
   --
   --  Changes matrix to be the inverse of it's original value. Not
   --  all transformation matrices have inverses; if the matrix
   --  collapses points together (it is <firstterm>degenerate</firstterm>),
   --  then it has no inverse and this function will fail.
   --
   --  Returns: If matrix has an inverse, modifies matrix to
   --   be the inverse matrix and returns CAIRO_STATUS_SUCCESS. Otherwise,
   --   returns CAIRO_STATUS_INVALID_MATRIX.

   procedure Multiply
     (Result : access Cairo_Matrix;
      A      : access constant Cairo_Matrix;
      B      : access constant Cairo_Matrix);
   --  Result: a Cairo_Matrix in which to store the Result
   --  A: A CAiro_MAtrix
   --  B: a Cairo_Matrix
   --
   --  Multiplies the affine transformations in a and b together
   --  and stores the result in result. The effect of the resulting
   --  transformation is to first apply the transformation in a to the
   --  coordinates and then apply the transformation in b to the
   --  coordinates.
   --
   --  It is allowable for result to be identical to either a or b.

   procedure Transform_Distance
     (Matrix : access constant Cairo_Matrix;
      Dx     : access Gdouble;
      Dy     : access Gdouble);
   --  Matrix: a Cairo_Matrix
   --  Dx: X component of a distance vector. An in/out parameter
   --  Dy: Y component of a distance vector. An in/out parameter
   --
   --  Transforms the distance vector (dx,dy) by matrix. This is
   --  similar to Cairo.Matrix.Transform_Point except that the translation
   --  components of the transformation are ignored. The calculation of
   --  the returned vector is as follows:
   --
   --  <programlisting>
   --  dx2 = dx1 * a + dy1 * c;
   --  dy2 = dx1 * b + dy1 * d;
   --  </programlisting>
   --
   --  Affine transformations are position invariant, so the same vector
   --  always transforms to the same vector. If (x1,y1) transforms
   --  to (x2,y2) then (x1+dx1,y1+dy1) will transform to
   --  (x1+dx2,y1+dy2) for all values of x1 and x2.

   procedure Transform_Point
     (Matrix : access constant Cairo_Matrix;
      X      : access Gdouble;
      Y      : access Gdouble);
   --  Matrix: a Cairo_Matrix
   --  X: X position. An in/out parameter
   --  Y: Y position. An in/out parameter
   --
   --  Transforms the point (x, y) by matrix.

private

   pragma Import (C, Init, "cairo_matrix_init");
   pragma Import (C, Init_Identity, "cairo_matrix_init_identity");
   pragma Import (C, Init_Translate, "cairo_matrix_init_translate");
   pragma Import (C, Init_Scale, "cairo_matrix_init_scale");
   pragma Import (C, Init_Rotate, "cairo_matrix_init_rotate");
   pragma Import (C, Translate, "cairo_matrix_translate");
   pragma Import (C, Scale, "cairo_matrix_scale");
   pragma Import (C, Rotate, "cairo_matrix_rotate");
   pragma Import (C, Invert, "cairo_matrix_invert");
   pragma Import (C, Multiply, "cairo_matrix_multiply");
   pragma Import (C, Transform_Distance, "cairo_matrix_transform_distance");
   pragma Import (C, Transform_Point, "cairo_matrix_transform_point");

end Cairo.Matrix;