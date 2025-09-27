(* Display list example *)

open Tsdl
module Gl = Gl_legacy
module Enum = Unsigned.UInt

let draw_cube () =
  Gl.gl_begin Gl.quads;

  (* Front face (red) *)
  Gl.color3f 1.0 0.0 0.0;
  Gl.vertex3f (-1.0) (-1.0)  1.0;
  Gl.vertex3f ( 1.0) (-1.0)  1.0;
  Gl.vertex3f ( 1.0) ( 1.0)  1.0;
  Gl.vertex3f (-1.0) ( 1.0)  1.0;

  (* Back face (green) *)
  Gl.color3f 0.0 1.0 0.0;
  Gl.vertex3f (-1.0) (-1.0) (-1.0);
  Gl.vertex3f (-1.0) ( 1.0) (-1.0);
  Gl.vertex3f ( 1.0) ( 1.0) (-1.0);
  Gl.vertex3f ( 1.0) (-1.0) (-1.0);

  (* Left face (blue) *)
  Gl.color3f 0.0 0.0 1.0;
  Gl.vertex3f (-1.0) (-1.0) (-1.0);
  Gl.vertex3f (-1.0) (-1.0)  1.0;
  Gl.vertex3f (-1.0) ( 1.0)  1.0;
  Gl.vertex3f (-1.0) ( 1.0) (-1.0);

  (* Right face (yellow) *)
  Gl.color3f 1.0 1.0 0.0;
  Gl.vertex3f (1.0) (-1.0) (-1.0);
  Gl.vertex3f (1.0) ( 1.0) (-1.0);
  Gl.vertex3f (1.0) ( 1.0)  1.0;
  Gl.vertex3f (1.0) (-1.0)  1.0;

  (* Top face (cyan) *)
  Gl.color3f 0.0 1.0 1.0;
  Gl.vertex3f (-1.0) (1.0) (-1.0);
  Gl.vertex3f (-1.0) (1.0)  1.0;
  Gl.vertex3f ( 1.0) (1.0)  1.0;
  Gl.vertex3f ( 1.0) (1.0) (-1.0);

  (* Bottom face (magenta) *)
  Gl.color3f 1.0 0.0 1.0;
  Gl.vertex3f (-1.0) (-1.0) (-1.0);
  Gl.vertex3f ( 1.0) (-1.0) (-1.0);
  Gl.vertex3f ( 1.0) (-1.0)  1.0;
  Gl.vertex3f (-1.0) (-1.0)  1.0;

  Gl.gl_end ()

let () =
  (* Init SDL2 *)
  match Sdl.init Sdl.Init.video with
  | Error (`Msg e) -> Sdl.log "SDL init error: %s" e; exit 1
  | Ok () -> ();

  let win =
    match Sdl.create_window ~w:640 ~h:480 "Display list cube"
            Sdl.Window.(opengl + shown) with
    | Error (`Msg e) -> Sdl.log "Window error: %s" e; exit 1
    | Ok w -> w
  in
  let _ctx = Sdl.gl_create_context win in

  (* OpenGL setup *)
  Gl.viewport 0 0 640 480;
  Gl.clear_color 0.0 0.0 0.0 1.0;
  Gl.enable Gl.depth_test;

  (* Projection matrix *)
  Gl.matrix_mode Gl.projection;
  Gl.load_identity ();
  Gl.frustum (-1.0) 1.0 (-0.75) 0.75 1.5 20.0;

  (* Build display list for cube *)
  let cube_list =
    let id = Gl.gen_lists 1 in
    Gl.new_list id Gl.compile;
    draw_cube ();
    Gl.end_list ();
    id
  in

  (* Main loop *)
  let angle = ref 0.0 in
  let event = Sdl.Event.create () in
  let running = ref true in
  while !running do
    (* Poll events *)
    while Sdl.poll_event (Some event) do
      match Sdl.Event.(enum (get event typ)) with
      | `Quit -> running := false
      | _ -> ()
    done;

    (* Clear screen *)
    Gl.clear (Enum.logor Gl.color_buffer_bit Gl.depth_buffer_bit);

    (* Modelview transform *)
    Gl.matrix_mode Gl.modelview;
    Gl.load_identity ();
    Gl.translatef 0.0 0.0 (-5.0);
    Gl.rotatef !angle 1.0 1.0 0.0;

    (* Draw cube *)
    Gl.call_list cube_list;

    Sdl.gl_swap_window win;
    angle := !angle +. 1.0;
    Sdl.delay 16l
  done;

  Gl.delete_lists cube_list 1;
  Sdl.destroy_window win;
  Sdl.quit ()
