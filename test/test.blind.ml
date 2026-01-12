let () =
  print_endline "Tests skipped. Please install tsdl.";
  match Sys.getenv_opt "OCAMLCI" with
  | Some s -> print_endline ("OCAMLCI=" ^ s)
  | None -> print_endline "OCAMLCI not set."
