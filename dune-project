(lang dune 3.15)
(name gl-legacy)
(version "0.1.0")
(generate_opam_files true)
(license ISC)
(maintainers "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(authors "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(source (github sanette/gl-legacy))

(package
 (name gl-legacy)
 (synopsis "Legacy OpenGL immediate-mode bindings for OCaml")
 (description "Quick bindings to old-style OpenGL (glBegin/glEnd, fixed-function transforms, matrix stack), Display Lists, Feedback Mode. For teaching or reviving legacy code. Can be used together with [tgls] for a complete openGL coverage.")
 (tags ("plot" "2D" "3D" "graphics" "openGL"))
 (depends
  (ocaml (>= 4.14))
  ctypes
  (ctypes-foreign (>= 0.21.1))
  (conf-libgl (and (<> :os "macos") (<> :os "win32"))) ;; currently conf-libgl requires "pkg-config --exists gl" which fails on macOS even though they usually have openGL framework installed. On windows, I get "pkg-config": command not found.
))
