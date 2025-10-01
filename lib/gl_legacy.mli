(* Gc-legacy --- San Vu Ngoc 2025 *)

(** [The gl-legacy] library is a minimal set of OCaml bindings to the venerable
    {{:https://registry.khronos.org/OpenGL-Refpages/gl2.1/}openGL 2.1} immediate
    mode. In particular, it includes {e Display Lists}, and the interesting {e
    Feedback mode}.

    [gl-legacy] can be used by itself (see the [triangle] or [cube] example),
    but more reasonably it should be thought of as an add-on to the more modern
    {{:https://erratique.ch/software/tgls/doc/index.html}tgls} bindings.

    When mixing this library with [tgls], it is convenient to use the following
    aliases: (for instance if you target OpenGL 3.x)

    {[
      module Gl = Gl_legacy
      module Gl3 = Tgl3.Gl
    ]}

    In this way you may write things such as

    {[
    Gl3.bind_texture Gl3.texture_2d tex_id;
    Gl.enable Gl.texture_2d;
    ]}

    Then, when you have the courage to update your work to remove deprecated
    OpenGL 1-2 functions, they will be easy to spot.
*)

type enum
val enum_to_int : enum -> int
val int_to_enum : int -> enum

(** 4x4 Matrices are flattened to 1D arrays of size 16. (column major: the first
    4 elements are the first column, etc.) *)
type matrixf =  (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t
type matrixd =  (float, Bigarray.float64_elt, Bigarray.c_layout) Bigarray.Array1.t
type render_mode = RENDER | SELECT | FEEDBACK
type display_list = enum
type display_list_mode = COMPILE | COMPILE_AND_EXECUTE
val ( lor ) : enum -> enum -> enum

(** {2 OpenGL functions}

    For documentation, see
    {{:https://registry.khronos.org/OpenGL-Refpages/gl2.1/}here}.

    In particular, that doc tells you the meaning of the arguments, and which
    {!enums} ([enums]) are valid parameters for each function.

    {e If you don't find a function below, it is maybe because it still exists
    in OpenGL 3, and hence can be found from
    {{:https://erratique.ch/software/tgls/doc/index.html}tgls}.}
    For instance if you want to use OpenGL 3.x you should consult:

    - {{:https://erratique.ch/software/tgls/doc/Tgl3/Gl/index.html}[tsdl.tgl3]}
    (OpenGL 3.x bindings)
    - {{:https://www.khronos.org/files/opengl-quick-reference-card.pdf}OpenGL
    3.2 reference card}
    - (more complete) {{:https://registry.khronos.org/OpenGL-Refpages/gl4/}OpenGL 4.5 doc}.

*)


val call_list : enum -> unit
val call_lists : enum array -> unit
val clear : enum -> unit
val clear_color : float -> float -> float -> float -> unit
val color3f : float -> float -> float -> unit
val color4f : float -> float -> float -> float -> unit
val color_material : enum -> enum -> unit
val copy_pixels : int -> int -> int -> int -> enum -> unit
val delete_lists : enum -> int -> unit
val disable : enum -> unit
val enable : enum -> unit
val end_list : unit -> unit
val finish : unit -> unit
val flush : unit -> unit
val frustum : float -> float -> float -> float -> float -> float -> unit
val gen_lists : int -> enum
val gl_begin : enum -> unit
val gl_end : unit -> unit
val light_modelf : enum -> float -> unit
val light_modelfv : enum -> float array -> unit
val lightfv : enum -> enum -> float array -> unit
val list_mode_enum : display_list_mode -> enum
val load_identity : unit -> unit
val load_matrixd :  matrixd -> unit
val load_matrixf : matrixf -> unit
val materialf : enum -> enum -> float -> unit
val materialfv : enum -> enum -> float array -> unit
val matrix_mode : enum -> unit
val mult_matrixd :  matrixd -> unit
val mult_matrixf : matrixf -> unit
val new_list : enum -> display_list_mode -> unit
val normal3f : float -> float -> float -> unit
val ortho : float -> float -> float -> float -> float -> float -> unit
val pop_matrix : unit -> unit
val push_matrix : unit -> unit
val render_mode : render_mode -> int
val render_mode_enum : render_mode -> enum
val rotated : float -> float -> float -> float -> unit
val rotatef : float -> float -> float -> float -> unit
val scalef : float -> float -> float -> unit
val tex_coord2d : float -> float -> unit
val tex_coord2f : float -> float -> unit
val tex_envf : enum -> enum -> float -> unit
val tex_envfv : enum -> enum -> float Ctypes_static.ptr -> unit
val tex_envi : enum -> enum -> enum -> unit
val tex_enviv : enum -> enum -> int Ctypes_static.ptr -> unit
val translatef : float -> float -> float -> unit
val vertex2d : float -> float -> unit
val vertex2f : float -> float -> unit
val vertex3f : float -> float -> float -> unit
val vertex4f : float -> float -> float -> float -> unit
val viewport : int -> int -> int -> int -> unit


(** {2:enums OpenGL constants} *)


val ambient : enum
val ambient_and_diffuse : enum
val back : enum
val blend : enum
val color : enum
val color_buffer_bit : enum
val color_indexes : enum
val color_material_enum : enum
val cull_face : enum
val decal : enum
val depth : enum
val depth_buffer_bit : enum
val depth_test : enum
val diffuse : enum
val emission : enum
val feedback : enum
val front : enum
val front_and_back : enum
val light0 : enum
val light_model_ambient : enum
val light_model_local_viewer : enum
val light_model_two_side : enum
val lighting : enum
val line_loop : enum
val line_smooth : enum
val line_strip : enum
val lines : enum
val modelview : enum
val modulate : enum
val normalize : enum
val point_smooth : enum
val points : enum
val polygon : enum
val polygon_smooth : enum
val position : enum
val projection : enum
val quad_strip : enum
val quads : enum
val render : enum
val replace : enum
val select : enum
val shininess : enum
val specular : enum
val stencil : enum
val stencil_buffer_bit : enum
val texture : enum
val texture_2d : enum
val texture_env : enum
val texture_env_color : enum
val texture_env_mode : enum
val triangle_fan : enum
val triangle_strip : enum
val triangles : enum
val compile : enum
val compile_and_execute : enum

(** Constants for Display Lists *)
module List_type :
  sig
    val byte : enum
    val unsigned_byte : enum
    val short : enum
    val unsigned_short : enum
    val int : enum
    val unsigned_int : enum
    val float : enum
    val two_bytes : enum
    val three_bytes : enum
    val four_bytes : enum
  end

(** Functions and constants for Feedback mode *)
module Feedback :
  sig
    val gl_2d : enum
    val gl_3d : enum
    val gl_3d_color : enum
    val gl_3d_color_texture : enum
    val gl_4d_color_texture : enum
    type buffer =
        GL_2D
      | GL_3D
      | GL_3D_COLOR
      | GL_3D_COLOR_TEXTURE
      | GL_4D_COLOR_TEXTURE
    val buffer_type_enum : buffer -> enum
    val pass_through_token : enum
    val point_token : enum
    val line_token : enum
    val line_reset_token : enum
    val polygon_token : enum
    val bitmap_token : enum
    val draw_pixel_token : enum
    val copy_pixel_token : enum
    type token =
        PASS_THROUGH
      | POINT
      | LINE
      | LINE_RESET
      | POLYGON
      | BITMAP
      | DRAW_PIXEL
      | COPY_PIXEL
    val token_enum : token -> enum
    val token : enum -> token
    val tokenf : float -> token
    val pass_through : float -> unit
    val setup :
      int ->
      buffer ->
      matrixf
  end
