(module

  ;; 64Kb per page
  ;; CANVAS_WIDTH = w
  ;; CANVAS_HEIGHT = h

  ;; [0, w*h)       -> state of system, 1 byte per value
  ;; [w*h, 5*w*h)   -> canvas data, 4 bytes per pixel
  ;; [5*w*h, inf)   -> palette data, rgba values

  (memory (export "mem") 20)

  ;; seed value to dynamical system
  (func (export "setup") (param $canvasWidth i32)

    (local $i i32)
    (set_local $i (i32.sub (local.get $canvasWidth) (i32.const 1)))

    ;; memory[i] = 1 for [0, canvasWidth)
    (loop
      (i32.store8 (local.get $i) (i32.const 1))
      ;; loop if i-- != 0
      (br_if 0
        (local.tee $i (i32.sub (local.get $i) (i32.const 1))))
    )
    (i32.store8 (local.get $i) (i32.const 1))
  )

  ;; (x,y,n) -> x+y mod n
  (func $moduloSum (param $x i32) (param $y i32) (param $n i32) (result i32)
    (i32.rem_u
      (i32.add (local.get $x) (local.get $y))
      (local.get $n)
    )
  )

  ;; update individual row in the system
  (func $updateRow (param $rowWidth i32) (param $rowAddress i32) (param $modulo i32)

    (local $i i32)
    (local $rowIndex i32)
    (local $prevRowIndex i32)
    (local $loopBound i32)
    (set_local $i (i32.const 0))
    (set_local $rowIndex
      (i32.mul (local.get $rowAddress) (local.get $rowWidth)))
    (set_local $prevRowIndex
      (i32.add
        (i32.sub (local.get $rowIndex) (local.get $rowWidth))
        (i32.const 1)
      )
    )
    (set_local $loopBound (i32.sub (local.get $rowWidth) (i32.const 1)))

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

      ;; loop if i < $rowWidth-1
      (br_if 0
        (i32.lt_u (local.get $i) (local.get $loopBound)))
    )
  )

  ;; update state of dynamical system
  (func $updateSystem (param $canvasWidth i32) (param $canvasHeight i32) (param $modulo i32)

    (local $rowAddress i32)
    (local $loopBound i32)
    (set_local $rowAddress (i32.const 0))
    (set_local $loopBound (i32.sub (local.get $canvasHeight) (i32.const 1)))

    (loop
      (set_local $rowAddress (i32.add (local.get $rowAddress) (i32.const 1)))
      (call $updateRow (local.get $canvasWidth) (local.get $rowAddress) (local.get $modulo))
      (br_if 0
        (i32.lt_u (local.get $rowAddress) (local.get $loopBound))
      )
    )
  )

  ;; lookup palette value
  (func $getColour (param $address i32) (param $palleteOffset i32) (result i32)
    (i32.load8_u (i32.add (local.get $palleteOffset) (local.get $address)))
  )

  ;; convert value to rgba, and store at address
  (func $setPixel (param $value i32) (param $address i32) (param $palleteOffset i32)
    (local $r i32)
    (local $g i32)
    (local $b i32)
    (local $a i32)

    ;; load palette colour based on value
    (set_local $r (call $getColour
      (local.get $value) (local.get $palleteOffset)))
    (set_local $g (call $getColour
      (i32.add (local.get $value) (i32.const 1)) (local.get $palleteOffset)))
    (set_local $b (call $getColour
      (i32.add (local.get $value) (i32.const 2)) (local.get $palleteOffset)))

    ;; fixed opacity
    (set_local $a (i32.const 255))

    ;; store colour at specified address
    (i32.store8 (local.get $address) (local.get $r))
    (i32.store8 (i32.add (local.get $address) (i32.const 1)) (local.get $g))
    (i32.store8 (i32.add (local.get $address) (i32.const 2)) (local.get $b))
    (i32.store8 (i32.add (local.get $address) (i32.const 3)) (local.get $a))
  )

  ;; update canvas data
  (func $updateCanvas (param $canvasWidth i32) (param $canvasHeight i32) (param $modulo i32)
    (local $i i32)
    (local $canvasSize i32)
    (local $pixelIndex i32)
    (local $loopBound i32)
    (local $palleteOffset i32)

    (set_local $i (i32.const 0))
    (set_local $canvasSize (i32.mul (local.get $canvasWidth) (local.get $canvasHeight)))
    (set_local $pixelIndex (local.get $canvasSize))
    (set_local $loopBound (i32.sub (local.get $canvasSize) (i32.const 1)))
    (set_local $palleteOffset (i32.mul (i32.const 5) (local.get $canvasSize)))

    (loop
      (call $setPixel
        (i32.load8_u (local.get $i))
        (local.get $pixelIndex)
        (local.get $palleteOffset))
      (set_local $i (i32.add (local.get $i) (i32.const 1)))
      (set_local $pixelIndex (i32.add (local.get $pixelIndex) (i32.const 4)))
      (br_if 0
        (i32.lt_u (local.get $i) (local.get $loopBound)))
    )
  )

  (func (export "update") (param $canvasWidth i32) (param $canvasHeight i32) (param $modulo i32)
    (call $updateSystem (local.get $canvasWidth) (local.get $canvasHeight) (local.get $modulo))
    (call $updateCanvas (local.get $canvasWidth) (local.get $canvasHeight) (local.get $modulo))
  )

)
