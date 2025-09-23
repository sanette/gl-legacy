(* Blind test. We don't create an openGL context, so nothing will be drawn. *)

module Gl = Gl_legacy

let () =
  if Gl.lib_gl <> None then begin
(* Clear screen to black *)
    (* Gl.clear_color 0.0 0.0 0.0 1.0; *)
    (* Gl.clear Gl.color_buffer_bit; *)

    (* (\* Projection *\) *)
    (* Gl.matrix_mode Gl.projection; *)
    (* Gl.load_identity (); *)
    (* Gl.ortho (-1.0) 1.0 (-1.0) 1.0 (-1.0) 1.0; *)

    (* (\* Modelview *\) *)
    (* Gl.matrix_mode Gl.modelview; *)
    (* Gl.load_identity (); *)
    (* Gl.rotatef 45. 0.0 0.0 1.0; *)

    (* (\* Triangle *\) *)
    (* Gl.gl_begin Gl.triangles; *)
    (* Gl.color3f 1.0 0.0 0.0; *)
    (* Gl.vertex2f 0.0 0.8; *)
    (* Gl.color3f 0.0 1.0 0.0; *)
    (* Gl.vertex2f (-0.8) (-0.8); *)
    (* Gl.color3f 0.0 0.0 1.0; *)
    (* Gl.vertex2f 0.8 (-0.8); *)
    (* Gl.gl_end (); *)

    print_endline "Tests OK"
  end
  else print_endline "Tests skipped"
