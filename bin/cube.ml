open Tsdl
module Gl = Gl_legacy

let () =
  (* Initialize SDL video *)
  match Sdl.init Sdl.Init.video with
  | Error (`Msg e) -> Sdl.log "SDL_Init Error: %s" e; exit 1
  | Ok () -> ();

    (* Create SDL window *)
    let win =
      match Sdl.create_window ~w:640 ~h:480 "Rotating Cube"
              Sdl.Window.(opengl + shown) with
      | Error (`Msg e) -> Sdl.log "Window Error: %s" e; exit 1
      | Ok w -> w
    in

    (* Create GL context *)
    let _ctx = Sdl.gl_create_context win in

    (* Enable depth test *)
    Gl.enable Gl.depth_test;

    (* Projection setup *)
    Gl.matrix_mode Gl.projection;
    Gl.load_identity ();
    Gl.frustum (-1.0) 1.0 (-1.0) 1.0 1.5 10.0;

    (* Switch back to modelview *)
    Gl.matrix_mode Gl.modelview;

    let running = ref true in
    let angle = ref 0.0 in
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

      (* Clear buffers *)
      Gl.clear Gl.(color_buffer_bit lor depth_buffer_bit);


      (* Reset modelview *)
      Gl.load_identity ();
      Gl.translatef 0.0 0.0 (-5.0);

      (* Rotate cube *)
      Gl.rotatef !angle 1.0 1.0 0.0;
      angle := !angle +. 1.0;
      if !angle > 360.0 then angle := !angle -. 360.0;

      (* Draw cube *)
      let draw_face r g b vertices =
        Gl.color3f r g b;
        Gl.gl_begin Gl.quads;
        List.iter (fun (x,y,z) -> Gl.vertex3f x y z) vertices;
        Gl.gl_end ()
      in
      draw_face 1.0 0.0 0.0 [(-1.,-1.,-1.); (1.,-1.,-1.); (1.,1.,-1.); (-1.,1.,-1.)];
      draw_face 0.0 1.0 0.0 [(-1.,-1., 1.); (1.,-1., 1.); (1.,1., 1.); (-1.,1., 1.)];
      draw_face 0.0 0.0 1.0 [(-1.,-1.,-1.); (-1.,1.,-1.); (-1.,1., 1.); (-1.,-1., 1.)];
      draw_face 1.0 1.0 0.0 [(1.,-1.,-1.); (1.,1.,-1.); (1.,1., 1.); (1.,-1., 1.)];
      draw_face 1.0 0.0 1.0 [(-1.,-1.,-1.); (1.,-1.,-1.); (1.,-1., 1.); (-1.,-1., 1.)];
      draw_face 0.0 1.0 1.0 [(-1., 1.,-1.); (1., 1.,-1.); (1., 1., 1.); (-1., 1., 1.)];

      (* Swap buffers *)
      Sdl.gl_swap_window win;

      (* Delay for ~16ms (60fps) *)
      Sdl.delay 16l
    done;

    Sdl.destroy_window win;
    Sdl.quit ()
