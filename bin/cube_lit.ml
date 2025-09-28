open Tsdl
module Gl = Gl_legacy

let () =
  match Sdl.init Sdl.Init.video with
  | Error (`Msg e) -> Sdl.log "SDL_Init Error: %s" e; exit 1
  | Ok () -> ();

    let win =
      match Sdl.create_window ~w:640 ~h:480 "Lit Cube"
              Sdl.Window.(opengl + shown) with
      | Error (`Msg e) -> Sdl.log "Window Error: %s" e; exit 1
      | Ok w -> w
    in
    let _ctx = Sdl.gl_create_context win in

    (* Enable depth test and lighting *)
    Gl.enable Gl.depth_test;
    Gl.enable Gl.lighting;
    Gl.enable Gl.light0;
    Gl.enable Gl.color_material_enum;

    (* Light properties *)
    let arr kind values = Gl.lightfv Gl.light0 kind values
    in
    arr Gl.position [| 0.0; 0.0; 2.0; 1.0 |];
    arr Gl.diffuse  [| 1.0; 1.0; 1.0; 1.0 |];
    arr Gl.specular [| 1.0; 1.0; 1.0; 1.0 |];

    (* Projection *)
    Gl.matrix_mode Gl.projection;
    Gl.load_identity ();
    Gl.frustum (-1.0) 1.0 (-1.0) 1.0 1.5 10.0;
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

      Gl.clear (Unsigned.UInt.logor Gl.color_buffer_bit Gl.depth_buffer_bit);

      Gl.load_identity ();
      Gl.translatef 0.0 0.0 (-5.0);
      Gl.rotatef !angle 1.0 1.0 0.0;
      angle := !angle +. 1.0;
      if !angle > 360.0 then angle := !angle -. 360.0;

      (* Cube faces with normals *)
      let draw_face (nx,ny,nz) color vertices =
        let (r,g,b) = color in
        Gl.color3f r g b;
        Gl.gl_begin Gl.quads;
        Gl.normal3f nx ny nz;
        List.iter (fun (x,y,z) -> Gl.vertex3f x y z) vertices;
        Gl.gl_end ()
      in
      draw_face (0.,0.,-1.) (1.,0.,0.)
        [(-1.,-1.,-1.); (1.,-1.,-1.); (1.,1.,-1.); (-1.,1.,-1.)];
      draw_face (0.,0., 1.) (0.,1.,0.)
        [(-1.,-1., 1.); (1.,-1., 1.); (1.,1., 1.); (-1.,1., 1.)];
      draw_face (-1.,0.,0.) (0.,0.,1.)
        [(-1.,-1.,-1.); (-1.,1.,-1.); (-1.,1., 1.); (-1.,-1., 1.)];
      draw_face (1.,0.,0.) (1.,1.,0.)
        [(1.,-1.,-1.); (1.,1.,-1.); (1.,1., 1.); (1.,-1., 1.)];
      draw_face (0.,-1.,0.) (1.,0.,1.)
        [(-1.,-1.,-1.); (1.,-1.,-1.); (1.,-1., 1.); (-1.,-1., 1.)];
      draw_face (0.,1.,0.) (0.,1.,1.)
        [(-1., 1.,-1.); (1., 1.,-1.); (1., 1., 1.); (-1., 1., 1.)];

      Sdl.gl_swap_window win;
      Sdl.delay 16l
    done;

    Sdl.destroy_window win;
    Sdl.quit ()
