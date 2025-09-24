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

let uu_of_int = Unsigned.UInt.of_int

(* ---------------------------------------------------------------------- *)
(* Dynamically open the OpenGL shared library *)

let lib_gl =
  if Sys.os_type = "Win32" then
    Dl.dlopen ~flags:[Dl.RTLD_NOW; Dl.RTLD_GLOBAL] ~filename:"opengl32.dll"
    |> Option.some
  else if Sys.os_type = "Unix" then
    (* Linux / BSD usually have libGL.so.1 *)
    try
      Dl.dlopen ~flags:[Dl.RTLD_NOW; Dl.RTLD_GLOBAL] ~filename:"libGL.so.1"
    |> Option.some
    with (* maybe macOS *)
      _ ->
      Dl.dlopen ~flags:[Dl.RTLD_NOW; Dl.RTLD_GLOBAL]
        ~filename:"/System/Library/Frameworks/OpenGL.framework/OpenGL"
      |> Option.some
  else begin
    print_endline "Could not find OpenGL library file.";
    None
  end
(* ---------------------------------------------------------------------- *)
(* Helpers to reduce boilerplate *)

let foreign0 name =
  foreign ?from:lib_gl name (void @-> returning void)

let foreign1 name t1 =
  foreign ?from:lib_gl name (t1 @-> returning void)

let foreign2 name t1 t2 =
  foreign ?from:lib_gl name (t1 @-> t2 @-> returning void)

let foreign3 name t1 t2 t3 =
  foreign ?from:lib_gl name (t1 @-> t2 @-> t3 @-> returning void)

let foreign4 name t1 t2 t3 t4 =
  foreign ?from:lib_gl name (t1 @-> t2 @-> t3 @-> t4 @-> returning void)

let foreign6 name t1 t2 t3 t4 t5 t6 =
  foreign ?from:lib_gl name
    (t1 @-> t2 @-> t3 @-> t4 @-> t5 @-> t6 @-> returning void)

(* ---------------------------------------------------------------------- *)
(* Immediate mode core *)

let enum = C.uint

let gl_begin = foreign1 "glBegin" enum
let gl_end = foreign0 "glEnd"
let enable = foreign1 "glEnable" enum

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

let matrix_mode   = foreign1 "glMatrixMode" enum
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

let clear = foreign1 "glClear" enum

(* Clear buffer bits *)
let color_buffer_bit   = uu_of_int 0x00004000
let depth_buffer_bit   = uu_of_int 0x00000100
let stencil_buffer_bit = uu_of_int 0x00000400

let depth_test  = uu_of_int 0x0B71

let lightfv = foreign3 "glLightfv" enum enum (ptr C.float)

let materialfv = foreign3 "glMaterialfv" enum enum (ptr C.float)

(* enums *)
let lighting      = uu_of_int 0x0B50
let light0        = uu_of_int 0x4000
let diffuse       = uu_of_int 0x1201
let specular      = uu_of_int 0x1202
let position      = uu_of_int 0x1203
let front         = uu_of_int 0x0404

let color_material = uu_of_int 0x0B57

(* ---------------------------------------------------------------------- *)
(* Common constants *)

let modelview  = uu_of_int 0x1700  (* GL_MODELVIEW *)
let projection = uu_of_int 0x1701  (* GL_PROJECTION *)
let texture    = uu_of_int 0x1702  (* GL_TEXTURE *)

let points         = uu_of_int 0x0000
let lines          = uu_of_int 0x0001
let line_loop      = uu_of_int 0x0002
let line_strip     = uu_of_int 0x0003
let triangles      = uu_of_int 0x0004
let triangle_strip = uu_of_int 0x0005
let triangle_fan   = uu_of_int 0x0006
let quads          = uu_of_int 0x0007
let quad_strip     = uu_of_int 0x0008
let polygon        = uu_of_int 0x0009

(* Constants for glRenderMode *)
let render   = uu_of_int 0x1C00
let select   = uu_of_int 0x1C02
let feedback = uu_of_int 0x1C01

type render_mode =
  | RENDER
  | SELECT
  | FEEDBACK

let render_mode_enum = function
  | RENDER -> render
  | SELECT -> select
  | FEEDBACK -> feedback

module Feedback = struct
  (* Constants for feedback buffer types *)
  let gl_2d        = uu_of_int 0x0600
  let gl_3d        = uu_of_int 0x0601
  let gl_3d_color  = uu_of_int 0x0602
  let gl_3d_color_texture = uu_of_int 0x0603
  let gl_4d_color_texture = uu_of_int 0x0604

  type buffer =
    | GL_2D
    | GL_3D
    | GL_3D_COLOR
    | GL_3D_COLOR_TEXTURE
    | GL_4D_COLOR_TEXTURE

  (* Query replace regex
     | \([A-Z0-9_]*\)
   → | \1 -> \,(downcase \1)

     ou bien
     \([A-Z0-9_]*\) → -> \,(downcase \1))

  *)
  let buffer_type_enum = function
    | GL_2D -> gl_2d
    | GL_3D -> gl_3d
    | GL_3D_COLOR -> gl_3d_color
    | GL_3D_COLOR_TEXTURE -> gl_3d_color_texture
    | GL_4D_COLOR_TEXTURE -> gl_4d_color_texture


  (* Feedback buffer tokens *)
  let pass_through_token   = uu_of_int 0x0700
  let point_token          = uu_of_int 0x0701
  let line_token           = uu_of_int 0x0702
  let line_reset_token     = uu_of_int 0x0707
  let polygon_token        = uu_of_int 0x0703
  let bitmap_token         = uu_of_int 0x0704
  let draw_pixel_token     = uu_of_int 0x0705
  let copy_pixel_token     = uu_of_int 0x0706

  (* on copie le bloc "let..." ci-dessus puis:
     Query replace regexp:
     let \([a-z_]*\)_token *=.*
   → | \,(upcase \1)

  *)
  type token =
    | PASS_THROUGH
    | POINT
    | LINE
    | LINE_RESET
    | POLYGON
    | BITMAP
    | DRAW_PIXEL
    | COPY_PIXEL

(*
Query replace regexp :
 | \([A-Z0-9_]*\)
 | \1 -> \,(downcase \1)_token

*)
  let token_enum = function
    | PASS_THROUGH -> pass_through_token
    | POINT -> point_token
    | LINE -> line_token
    | LINE_RESET -> line_reset_token
    | POLYGON -> polygon_token
    | BITMAP -> bitmap_token
    | DRAW_PIXEL -> draw_pixel_token
    | COPY_PIXEL -> copy_pixel_token

(*
Query replace regexpm
  | \([A-Z0-9_]*\)
 | i when i = \,(downcase \1)_token -> \1

*)
  let token = function
    | i when i = pass_through_token -> PASS_THROUGH
    | i when i = point_token -> POINT
    | i when i = line_token -> LINE
    | i when i = line_reset_token -> LINE_RESET
    | i when i = polygon_token -> POLYGON
    | i when i = bitmap_token -> BITMAP
    | i when i = draw_pixel_token -> DRAW_PIXEL
    | i when i = copy_pixel_token -> COPY_PIXEL
    | _ -> raise (invalid_arg "feedback_token")


  (* Feedback-related functions
    https://registry.khronos.org/OpenGL-Refpages/gl2.1/xhtml/glRenderMode.xml
  *)

  (* GLint glRenderMode(GLenum mode) *)
  let render_mode =
    foreign "glRenderMode" (enum @-> returning C.int)

  let render_mode mode =
    render_mode (render_mode_enum mode)

  (* void glFeedbackBuffer(GLsizei size, GLenum type, GLfloat *buffer) *)
  let feedback_buffer =
    foreign "glFeedbackBuffer" (C.int @-> enum @-> ptr C.float @-> returning C.void)

  (* void glPassThrough(GLfloat token) *)
  let pass_through =
    foreign1 "glPassThrough" C.float

  (* Create a feedback buffer of size `n` floats *)
  let make_feedback_buffer n : (float, float32_elt, c_layout) Array1.t =
    Array1.create float32 c_layout n

  let feedback_buffer_ptr (ba : (float, float32_elt, c_layout) Array1.t) =
    C.bigarray_start C.array1 ba

  (* Return a feedback buffer. To be used *before* render_mode is called*)
  let setup n mode =
    let mode = buffer_type_enum mode in
    let ba = make_feedback_buffer n in
    let ptr = feedback_buffer_ptr ba in
    feedback_buffer n mode ptr;
    ba

end

(*
   emacs: convert camel-case to snake_case:
Query replace regexp:
 \([a-z0-9]\)\([A-Z]\) → \1_\,(downcase \2)
*)
