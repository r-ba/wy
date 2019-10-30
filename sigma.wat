(module

  ;; 1 page * 64Kb per page
  ;; CANVAS_HEIGHT = 200
  ;; CANVAS_WIDTH = 320
  ;; CANVAS_HEIGHT * CANVAS_WIDTH = 64000

  (memory (export "mem") 1)

  ;; seed value to dynamical system
  (func $setup

    (local $i i32)
    (set_local $i (i32.const 319))

    ;; memory[i] = 1 for [0, 320)
    (loop
      (i32.store8 (local.get $i) (i32.const 1))
      ;; loop if i-- != 0
      (br_if 0
        (local.tee $i (i32.sub (local.get $i) (i32.const 1))))
    )
    (i32.store8 (local.get $i) (i32.const 1))
  )

  ;; run setup at start
  (start $setup)

)
