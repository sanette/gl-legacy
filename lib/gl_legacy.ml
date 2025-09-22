(* Gl_legacy

   Quick library for using legacy OpenGL immediate-mode and matrix stack
   bindings. Works alongside tgls for retro OpenGL 1.x style code.

   Work in progress

   San Vu Ngoc 2025
*)

module C = Ctypes
open Ctypes
open Foreign
open Bigarray

(* ---------------------------------------------------------------------- *)
(* Dynamically open the OpenGL shared library *)

let lib_gl =
  if Sys.os_type = "Win32" then
    Dl.dlopen ~flags:[Dl.RTLD_NOW; Dl.RTLD_GLOBAL] ~filename:"opengl32.dll"
  else if Sys.os_type = "Unix" then
    (* Linux / BSD usually have libGL.so.1 *)
    Dl.dlopen ~flags:[Dl.RTLD_NOW; Dl.RTLD_GLOBAL] ~filename:"libGL.so.1"
  else
    (* macOS *)
    Dl.dlopen ~flags:[Dl.RTLD_NOW; Dl.RTLD_GLOBAL]
      ~filename:"/System/Library/Frameworks/OpenGL.framework/OpenGL"

(* ---------------------------------------------------------------------- *)
(* Helpers to reduce boilerplate *)

let foreign0 name =
  foreign ~from:lib_gl name (void @-> returning void)

let foreign1 name t1 =
  foreign ~from:lib_gl name (t1 @-> returning void)

let foreign2 name t1 t2 =
  foreign ~from:lib_gl name (t1 @-> t2 @-> returning void)

let foreign3 name t1 t2 t3 =
  foreign ~from:lib_gl name (t1 @-> t2 @-> t3 @-> returning void)

let foreign4 name t1 t2 t3 t4 =
  foreign ~from:lib_gl name (t1 @-> t2 @-> t3 @-> t4 @-> returning void)

let foreign6 name t1 t2 t3 t4 t5 t6 =
  foreign ~from:lib_gl name
    (t1 @-> t2 @-> t3 @-> t4 @-> t5 @-> t6 @-> returning void)

(* ---------------------------------------------------------------------- *)
(* Immediate mode core *)

let gl_begin = foreign1 "glBegin" C.uint
let gl_end = foreign0 "glEnd"

(* vertices *)
let vertex2f = foreign2 "glVertex2f" C.float C.float
let vertex3f = foreign3 "glVertex3f" C.float C.float C.float
let vertex4f = foreign4 "glVertex4f" C.float C.float C.float C.float

(* colors *)
let color3f = foreign3 "glColor3f" C.float C.float C.float
let color4f = foreign4 "glColor4f" C.float C.float C.float C.float

(* texcoords *)
let tex_coord2f = foreign2 "glTexCoord2f" C.float C.float

(* normals *)
let normal3f = foreign3 "glNormal3f" C.float C.float C.float

(* ---------------------------------------------------------------------- *)
(* Matrix stack & transforms *)

let matrix_mode   = foreign1 "glMatrixMode" C.uint
let load_identity = foreign0 "glLoadIdentity"
let push_matrix   = foreign0 "glPushMatrix"
let pop_matrix    = foreign0 "glPopMatrix"

let translatef = foreign3 "glTranslatef" C.float C.float C.float
let rotatef = foreign4 "glRotatef" C.float C.float C.float C.float
let scalef = foreign3 "glScalef" C.float C.float C.float

let ortho =
  foreign6 "glOrtho"
    C.double C.double
    C.double C.double
    C.double C.double

let frustum =
  foreign6 "glFrustum"
    C.double C.double
    C.double C.double
    C.double C.double

let viewport =
  foreign4 "glViewport" C.int C.int C.int C.int

let flush  = foreign0 "glFlush"
let finish = foreign0 "glFinish"

(* matrix load/mult *)
let load_matrixf = foreign1 "glLoadMatrixf" (ptr C.float)
let mult_matrixf = foreign1 "glMultMatrixf" (ptr C.float)
let load_matrixd = foreign1 "glLoadMatrixd" (ptr C.double)
let mult_matrixd = foreign1 "glMultMatrixd" (ptr C.double)

(* ---------------------------------------------------------------------- *)
(* Convenience wrappers for Bigarray matrices *)

let check_len16 name len =
  if len <> 16 then invalid_arg (name ^ ": expected length-16 array")

let load_matrixf (m : (float, float32_elt, c_layout) Array1.t) : unit =
  check_len16 "load_matrixf" (Array1.dim m);
  let p = C.bigarray_start C.array1 m in
  load_matrixf p

let mult_matrixf (m : (float, float32_elt, c_layout) Array1.t) : unit =
  check_len16 "mult_matrixf" (Array1.dim m);
  let p = C.bigarray_start C.array1 m in
  mult_matrixf p

let load_matrixd (m : (float, float64_elt, c_layout) Array1.t) : unit =
  check_len16 "load_matrixd" (Array1.dim m);
  let p = C.bigarray_start C.array1 m in
  load_matrixd p

let mult_matrixd (m : (float, float64_elt, c_layout) Array1.t) : unit =
  check_len16 "mult_matrixd" (Array1.dim m);
  let p = C.bigarray_start C.array1 m in
  mult_matrixd p


(* ---------------------------------------------------------------------- *)
(* Clear *)

let clear_color =
  foreign4 "glClearColor" C.float C.float C.float C.float

let clear = foreign1 "glClear" C.uint

(* Clear buffer bits *)
let color_buffer_bit   = Unsigned.UInt.of_int 0x00004000
let depth_buffer_bit   = Unsigned.UInt.of_int 0x00000100
let stencil_buffer_bit = Unsigned.UInt.of_int 0x00000400


(* ---------------------------------------------------------------------- *)
(* Common constants *)

let modelview  = Unsigned.UInt.of_int 0x1700  (* GL_MODELVIEW *)
let projection = Unsigned.UInt.of_int 0x1701  (* GL_PROJECTION *)
let texture    = Unsigned.UInt.of_int 0x1702  (* GL_TEXTURE *)

let points         = Unsigned.UInt.of_int 0x0000
let lines          = Unsigned.UInt.of_int 0x0001
let line_loop      = Unsigned.UInt.of_int 0x0002
let line_strip     = Unsigned.UInt.of_int 0x0003
let triangles      = Unsigned.UInt.of_int 0x0004
let triangle_strip = Unsigned.UInt.of_int 0x0005
let triangle_fan   = Unsigned.UInt.of_int 0x0006
let quads          = Unsigned.UInt.of_int 0x0007
let quad_strip     = Unsigned.UInt.of_int 0x0008
let polygon        = Unsigned.UInt.of_int 0x0009

(*
   emacs: convert camel-case to snake_case:
Query replace regexp:
 \([a-z0-9]\)\([A-Z]\) → \1_\,(downcase \2)
*)
