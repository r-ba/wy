(module

  ;; 6 page * 64Kb per page
  ;; CANVAS_HEIGHT = 200
  ;; CANVAS_WIDTH = 320
  ;; CANVAS_HEIGHT * CANVAS_WIDTH = 64000

  ;; [0,64000)        -> state of system, 1 byte per value
  ;; [64000, 320000)  -> canvas data, 4 bytes per pixel
  ;; [320000, 384000) -> palette data, rgba values

  (memory (export "mem") 6)

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

  ;; (x,y,n) -> x+y mod n
  (func $moduloSum (param $x i32) (param $y i32) (param $n i32) (result i32)
    (i32.rem_u
      (i32.add (local.get $x) (local.get $y))
      (local.get $n)
    )
  )

  ;; update individual row in the system
  (func $updateRow (param $row i32) (param $modulo i32)

    (local $i i32)
    (local $rowIndex i32)
    (local $prevRowIndex i32)
    (set_local $i (i32.const 0))
    (set_local $rowIndex
      (i32.mul (local.get $row) (i32.const 320)))
    (set_local $prevRowIndex
      (i32.add
        (i32.sub (local.get $rowIndex) (i32.const 320))
        (i32.const 1)
      )
    )

    (i32.store8
      (local.get $rowIndex)
      (i32.load8_u (i32.sub (local.get $prevRowIndex) (i32.const 1)))
    )

    (loop
      ;; memory[rowIndex+1] = memory[rowIndex] + memory[prevRowIndex]
      (i32.store8
        (i32.add (local.get $rowIndex) (i32.const 1))
        (call $moduloSum
          (i32.load8_u (local.get $rowIndex))
          (i32.load8_u (local.get $prevRowIndex))
          (local.get $modulo))
      )

      ;; increment indices
      (set_local $i (i32.add (local.get $i) (i32.const 1)))
      (set_local $rowIndex (i32.add (local.get $rowIndex) (i32.const 1)))
      (set_local $prevRowIndex (i32.add (local.get $prevRowIndex) (i32.const 1)))

      ;; loop if i < 320
      (br_if 0
        (i32.lt_u (local.get $i) (i32.const 319)))
    )
  )

  ;; update state of dynamical system
  (func $updateSystem (param $modulo i32)

    (local $row i32)
    (set_local $row (i32.const 0))

    (loop
      (set_local $row (i32.add (local.get $row) (i32.const 1)))
      (call $updateRow (local.get $row) (local.get $modulo))
      (br_if 0
        (i32.lt_u (local.get $row) (i32.const 199))
      )
    )
  )

  ;; lookup palette value
  (func $getColour (param $address i32) (result i32)
    (i32.load8_u offset=320000 (local.get $address))
  )

)
