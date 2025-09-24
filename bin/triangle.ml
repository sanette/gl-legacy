open Tsdl
module Gl = Gl_legacy

let () =
  (* Initialize SDL with video *)
  let () = match Sdl.init Sdl.Init.video with
  | Ok () -> ()
  | Error (`Msg e) -> failwith ("SDL_Init Error: " ^ e) in

  (* Set OpenGL attributes *)
  ignore (Sdl.gl_set_attribute Sdl.Gl.context_major_version 2);
  ignore (Sdl.gl_set_attribute Sdl.Gl.context_minor_version 1);

  (* Create window with OpenGL context *)
  let win =
    match
      Sdl.create_window ~w:640 ~h:480 "Legacy GL Demo"
        Sdl.Window.(opengl + shown)
    with
    | Error (`Msg e) -> failwith ("create_window: " ^ e)
    | Ok w -> w
  in
  let _glctx =
    match Sdl.gl_create_context win with
    | Error (`Msg e) -> failwith ("gl_create_context: " ^ e)
    | Ok ctx -> ctx
  in

  let running = ref true in
  let angle = ref 0.0 in
  let event = Sdl.Event.create () in

  while !running do
    (* Handle all events *)
    let rec pump () =
      if Sdl.poll_event (Some event) then begin
        match Sdl.Event.(get event typ) with
        | t when t = Sdl.Event.quit -> running := false
        | _ -> pump ()
      end
    in
    pump ();

    (* Clear screen to black *)
    Gl.clear_color 0.0 0.0 0.0 1.0;
    Gl.clear Gl.color_buffer_bit;

    (* Projection *)
    Gl.matrix_mode Gl.projection;
    Gl.load_identity ();
    Gl.ortho (-1.0) 1.0 (-1.0) 1.0 (-1.0) 1.0;

    (* Modelview *)
    Gl.matrix_mode Gl.modelview;
    Gl.load_identity ();
    Gl.rotatef !angle 0.0 0.0 1.0;

    (* Triangle *)
    Gl.gl_begin Gl.triangles;
    Gl.color3f 1.0 0.0 0.0;
    Gl.vertex2f 0.0 0.8;
    Gl.color3f 0.0 1.0 0.0;
    Gl.vertex2f (-0.8) (-0.8);
    Gl.color3f 0.0 0.0 1.0;
    Gl.vertex2f 0.8 (-0.8);
    Gl.gl_end ();

    Sdl.gl_swap_window win;

    angle := !angle +. 1.0;
    if !angle > 360.0 then angle := 0.0;

    Sdl.delay 16l
  done;

  Sdl.destroy_window win;
  Sdl.quit ()
