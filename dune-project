(lang dune 3.12)
(name gl-legacy)
(version "0.0.1")
(generate_opam_files true)
(license ISC)
(maintainers "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(authors "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(source (github sanette/gl_legacy))

(package
 (name gl-legacy)
 (synopsis "Legacy OpenGL immediate-mode bindings for OCaml")
 (description "Quick bindings to old-style OpenGL (glBegin/glEnd, fixed-function transforms, matrix stack) using ctypes, for teaching or reviving legacy code.")
 (tags ("plot" "2D" "3D" "graphics" "openGL"))
 (depends
  (ocaml (>= 4.14))
  ctypes
  ctypes-foreign
  (mesa-common-dev (= :os-family "debian"))
))
