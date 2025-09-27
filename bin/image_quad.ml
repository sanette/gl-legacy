(* Example mixing Core openGL (tgl3) and legacy *)

open Tsdl
open Tsdl_image
module Gl = Gl_legacy
module Gl3 = Tgl3.Gl

let () =
  match Sdl.init Sdl.Init.video with
  | Error (`Msg e) -> Sdl.log "SDL_Init Error: %s" e; exit 1
  | Ok () -> ();

    let win =
      match Sdl.create_window ~w:565 ~h:536 "Textured Quad"
              Sdl.Window.(opengl + shown) with
      | Error (`Msg e) -> Sdl.log "Window Error: %s" e; exit 1
      | Ok w -> w
    in
    let _ctx = Sdl.gl_create_context win in

    (* Load image via SDL_image *)
    let surf =
      match Image.load "image.png" with
      | Error (`Msg e) -> failwith ("Failed to load image: " ^ e)
      | Ok s -> s
    in
    let w,h = Sdl.get_surface_size surf in

    (* Create texture with Tgl3 *)

    let tex_id_arr =
      Bigarray.Array1.create Bigarray.int32 Bigarray.c_layout 1
    in
    Gl3.gen_textures 1 (tex_id_arr);
    let tex_id = Int32.to_int tex_id_arr.{0} in

    Gl3.bind_texture Gl3.texture_2d tex_id;

    Gl3.tex_parameteri Gl3.texture_2d Gl3.texture_min_filter Gl3.linear;
    Gl3.tex_parameteri Gl3.texture_2d Gl3.texture_mag_filter Gl3.linear;

    let pixels = Sdl.get_surface_pixels surf Bigarray.int8_unsigned in
    (* Tell GL not to expect 4-byte row alignment *)
    Gl3.pixel_storei Gl3.unpack_alignment 1;

    Gl3.tex_image2d
      Gl3.texture_2d 0 Gl3.rgba
      w h 0
      Gl3.rgba Gl3.unsigned_byte
      (`Data pixels);

    Sdl.free_surface surf;

    (* Enable texturing in legacy *)
    Gl.enable Gl.texture_2d;

    let running = ref true in
    let event = Sdl.Event.create () in

    while !running do
      (* Handle events *)
      let rec poll () =
        if Sdl.poll_event (Some event) then begin
          match Sdl.Event.(get event typ) with
          | t when t = Sdl.Event.quit -> running := false
          | _ -> poll ()
        end
      in
      poll ();

      (* Clear screen *)
      Gl3.clear (Gl3.color_buffer_bit lor Gl3.depth_buffer_bit);

      (* Draw textured quad in immediate mode *)
      Gl.gl_begin Gl.quads;
      Gl.tex_coord2f 0.0 0.0; Gl.vertex3f (-1.0) (1.0) 0.0;
      Gl.tex_coord2f 1.0 0.0; Gl.vertex3f ( 1.0) (1.0) 0.0;
      Gl.tex_coord2f 1.0 1.0; Gl.vertex3f ( 1.0) (-1.0) 0.0;
      Gl.tex_coord2f 0.0 1.0; Gl.vertex3f (-1.0) (-1.0) 0.0;
      Gl.gl_end ();

      Sdl.gl_swap_window win;
      Sdl.delay 16l
    done;

    Sdl.destroy_window win;
    Sdl.quit ()
