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

  ;; update individual row in the system
  (func $updateRow
    (param $x0 i32) (param $x1 i32) (param $x2 i32) (param $x3 i32)
    (param $x4 i32) (param $x5 i32) (param $x6 i32) (param $x7 i32)
    (param $rowWidth i32) (param $rowAddress i32)

    (local $i i32)
    (local $rowIndex i32)
    (local $prevRowIndex i32)
    (local $loopBound i32)
    (set_local $rowIndex (i32.mul (local.get $rowAddress) (local.get $rowWidth)))
    (set_local $prevRowIndex (i32.sub (local.get $rowIndex) (local.get $rowWidth)))
    (set_local $loopBound (i32.sub (local.get $rowWidth) (i32.const 2)))

    (loop
      ;; mem[rowIndex] = rule(mem[prevRowIndex-1],mem[prevRowIndex],mem[prevRowIndex+1])
      (i32.store8
        (i32.add (local.get $rowIndex) (i32.const 1))
        (call $automataMap
          (local.get $x0) (local.get $x1) (local.get $x2) (local.get $x3)
          (local.get $x4) (local.get $x5) (local.get $x6) (local.get $x7)
          (i32.load8_u (local.get $prevRowIndex))
          (i32.load8_u (i32.add (local.get $prevRowIndex) (i32.const 1)))
          (i32.load8_u (i32.add (local.get $prevRowIndex) (i32.const 2)))
        )
      )

      ;; increment indices
      (set_local $i (i32.add (local.get $i) (i32.const 1)))
      (set_local $rowIndex (i32.add (local.get $rowIndex) (i32.const 1)))
      (set_local $prevRowIndex (i32.add (local.get $prevRowIndex) (i32.const 1)))

      ;; loop if i < $rowWidth-2
      (br_if 0
        (i32.lt_u (local.get $i) (local.get $loopBound)))
    )
  )

  ;; update state of dynamical system
  (func $updateSystem
    (param $x0 i32) (param $x1 i32) (param $x2 i32) (param $x3 i32)
    (param $x4 i32) (param $x5 i32) (param $x6 i32) (param $x7 i32)
    (param $canvasWidth i32) (param $canvasHeight i32)

    (local $rowAddress i32)
    (local $loopBound i32)
    (set_local $loopBound (i32.sub (local.get $canvasHeight) (i32.const 1)))

    (loop
      (set_local $rowAddress (i32.add (local.get $rowAddress) (i32.const 1)))
      (call $updateRow
        (local.get $x0) (local.get $x1) (local.get $x2) (local.get $x3)
        (local.get $x4) (local.get $x5) (local.get $x6) (local.get $x7)
        (local.get $canvasWidth) (local.get $rowAddress))
      (br_if 0
        (i32.lt_u (local.get $rowAddress) (local.get $loopBound))
      )
    )
  )

  ;; convert value to rgba, and store at address
  (func $setPixel (param $value i32) (param $address i32) (param $palleteOffset i32)
    (local $r i32)
    (local $g i32)
    (local $b i32)
    (local $a i32)

    ;; load palette colour based on value
    ;; ffffff if value eq 0, else 000000
    (if (i32.eq (local.get $value) (i32.const 0))
      (then
        (set_local $r (i32.const 255))
        (set_local $g (i32.const 255))
        (set_local $b (i32.const 255))))

    ;; fixed opacity
    (set_local $a (i32.const 255))

    ;; store colour at specified address
    (i32.store8 (local.get $address) (local.get $r))
    (i32.store8 (i32.add (local.get $address) (i32.const 1)) (local.get $g))
    (i32.store8 (i32.add (local.get $address) (i32.const 2)) (local.get $b))
    (i32.store8 (i32.add (local.get $address) (i32.const 3)) (local.get $a))
  )

  ;; update canvas data
  (func $updateCanvas (param $canvasWidth i32) (param $canvasHeight i32)
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

  (func $bin (param $n i32) (param $power i32) (result i32)
    (if (result i32)
      (i32.le_u (local.get $power) (local.get $n))
      (then
        (i32.sub (local.get $n) (local.get $power))
      )
      (else
        (local.get $n)
      )
    )
  )

)
