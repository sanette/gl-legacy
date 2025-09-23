# gl-legacy

Legacy OpenGL immediate-mode bindings for OCaml

Use this together with `tgls` for a complete coverage of (more) modern OpenGL.

__Work in Progress__

Right now the triangle demo works ;)

![triangle](triangle.png)


```ocaml
(...)

    Gl_legacy.gl_begin Gl_legacy.triangles;
    Gl_legacy.color3f 1.0 0.0 0.0;
    Gl_legacy.vertex2f 0.0 0.8;
    Gl_legacy.color3f 0.0 1.0 0.0;
    Gl_legacy.vertex2f (-0.8) (-0.8);
    Gl_legacy.color3f 0.0 0.0 1.0;
    Gl_legacy.vertex2f 0.8 (-0.8);
    Gl_legacy.gl_end ();

(...)
```
