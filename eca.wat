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

  ;; rule xi*2^i, i=0...7, applied to the cells (s0, s1, s2)
  (func $automataMap
    (param $x0 i32) (param $x1 i32) (param $x2 i32) (param $x3 i32)
    (param $x4 i32) (param $x5 i32) (param $x6 i32) (param $x7 i32)
    (param $s0 i32) (param $s1 i32) (param $s2 i32)
    (result i32)

    (local $result i32)
    (local $z i32)
    (set_local $z
      (i32.add (local.get $s2)
        (i32.add (i32.mul (local.get $s1) (i32.const 2))
                 (i32.mul (local.get $s0) (i32.const 4))
        )
      )
    )

    (if (i32.eq (local.get $z) (i32.const 0))
      (then (set_local $result (local.get $x0)))
    (else (if (i32.eq (local.get $z) (i32.const 1))
      (then (set_local $result (local.get $x1)))
    (else (if (i32.eq (local.get $z) (i32.const 2))
      (then (set_local $result (local.get $x2)))
    (else (if (i32.eq (local.get $z) (i32.const 3))
      (then (set_local $result (local.get $x3)))
    (else (if (i32.eq (local.get $z) (i32.const 4))
      (then (set_local $result (local.get $x4)))
    (else (if (i32.eq (local.get $z) (i32.const 5))
      (then (set_local $result (local.get $x5)))
    (else (if (i32.eq (local.get $z) (i32.const 6))
      (then (set_local $result (local.get $x6)))
    (else (if (i32.eq (local.get $z) (i32.const 7))
      (then (set_local $result (local.get $x7)))
    )))))))))))))))

    (local.get $result)
  )

)
