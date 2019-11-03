;; elementary cellular automata
(module

  ;; 64Kb per page
  ;; CANVAS_WIDTH = w
  ;; CANVAS_HEIGHT = h
  ;; [0, w*h)       -> state of system, 1 byte per value
  ;; [w*h, 5*w*h)   -> canvas data, 4 bytes per pixel

  (memory (export "mem") 20)

  ;; automata seed value
  (func (export "setup") (param $canvasWidth i32)
    (i32.store8
      (i32.div_u (local.get $canvasWidth) (i32.const 2))
      (i32.const 1)
    )
  )

)
