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

package body Gdk is

   ------------------
   --  Get_Object  --
   ------------------

   function Get_Object (Object : in Root_Type'Class) return System.Address is
   begin
      return Object.Ptr;
   end Get_Object;

   ------------------
   --  Is_Created  --
   ------------------

   function Is_Created (Object : in Root_Type) return Boolean is
      use type System.Address;
   begin
      return Get_Object (Object) /= System.Null_Address;
   end Is_Created;

   ------------------
   --  Set_Object  --
   ------------------

   procedure Set_Object (Object : in out Root_Type'Class;
                         Value  : in     System.Address) is
   begin
      Object.Ptr := Value;
   end Set_Object;

   --------------------
   -- Unchecked_Cast --
   --------------------

   function Unchecked_Cast (From : in Root_Type'Class)
                            return To
   is
      T : To;
   begin
      Set_Object (T, Get_Object (From));
      return T;
   end Unchecked_Cast;

end Gdk;
