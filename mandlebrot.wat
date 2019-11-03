;; mandlebrot set
(module

  ;; 64Kb per page
  ;; CANVAS_WIDTH = w
  ;; CANVAS_HEIGHT = h
  ;; [0, 4*w*h)  -> canvas data, 4 byte per value

  (import "" "log" (func $log (param i32) (result f64)))

  (memory (export "mem") 20)

  (func $iter (param $cx f64) (param $cy f64) (param $maxIter i32) (result i32)
    (local $x f64)
    (local $y f64)
    (local $xx f64)
    (local $yy f64)
    (local $xy f64)
    (local $i i32)
    (set_local $i (local.get $maxIter))

    (loop
      (set_local $xy (f64.mul (local.get $x) (local.get $y)))
      (set_local $xx (f64.mul (local.get $x) (local.get $x)))
      (set_local $yy (f64.mul (local.get $y) (local.get $y)))
      (set_local $x (f64.sub (f64.add (local.get $xx) (local.get $cx)) (local.get $yy)))
      (set_local $y (f64.add (f64.add (local.get $xy) (local.get $xy)) (local.get $cy)))
      (set_local $i (i32.sub (local.get $i) (i32.const 1)))

      ;; loop while (i>0) && (xx+yy <= 4)
      (br_if 0 (i32.and
        (i32.ne (local.get $i) (i32.const 0))
        (f64.le (f64.add (local.get $xx) (local.get $yy)) (f64.const 4))))
    )

    ;; return maxIter - i
    (i32.sub (local.get $maxIter) (local.get $i))
  )

  (func $setPixel (param $case i32) (param $address i32) (param $c f64)
    (local $r i32)
    (local $g i32)
    (local $b i32)
    (local $a i32)

    ;; fixed opacity
    (set_local $a (i32.const 255))

    ;; set rgb values
    (if
      (i32.eq (local.get $case) (i32.const 1))
      (then
        (set_local $r
          (i32.trunc_f64_u (f64.mul
            (f64.const 255)
            (local.get $c))))
      )
      (else
        (if
          (i32.eq (local.get $case) (i32.const 2))
          (then
            (set_local $r (i32.const 255))
            (set_local $g
              (i32.trunc_f64_u (f64.mul
                (f64.const 255)
                (f64.sub (local.get $c) (f64.const 1)))))
          )
          (else
            (if
              (i32.eq (local.get $case) (i32.const 3))
              (then
                (set_local $r (i32.const 255))
                (set_local $g (i32.const 255))
                (set_local $b
                  (i32.trunc_f64_u (f64.mul
                    (f64.const 255)
                    (f64.sub (local.get $c) (f64.const 2)))))
              )
            )
          )
        )
      )
    )

    ;; store rgba at memory[address]
    (i32.store8
      (local.get $address)
      (local.get $r))
    (i32.store8
      (i32.add (local.get $address) (i32.const 1))
      (local.get $g))
    (i32.store8
      (i32.add (local.get $address) (i32.const 2))
      (local.get $b))
    (i32.store8
      (i32.add (local.get $address) (i32.const 3))
      (local.get $a))

  )

  (func (export "update") (param $xmin f64) (param $xmax f64) (param $ymin f64) (param $ymax f64)
                          (param $width f64) (param $height f64) (param $iterations i32)

    (local $i i32)
    (local $ix f64)
    (local $iy f64)
    (local $x f64)
    (local $y f64)
    (local $c f64)
    (local $pixel i32) ;; address to write colour data
    (local $w f64) ;; width - 1
    (local $h f64) ;; height - 1
    (local $r f64) ;; xmax - xmin
    (local $t f64) ;; ymax - ymin
    (local $s i32) ;; iterations - 1

    (set_local $w (f64.sub (local.get $width) (f64.const 1)))
    (set_local $h (f64.sub (local.get $height) (f64.const 1)))
    (set_local $r (f64.sub (local.get $xmax) (local.get $xmin)))
    (set_local $t (f64.sub (local.get $ymax) (local.get $ymin)))
    (set_local $s (i32.sub (local.get $iterations) (i32.const 1)))

    (loop
      ;; ++ix
      (set_local $ix (f64.add (local.get $ix) (f64.const 1)))

      (loop
        (set_local $iy (f64.add (local.get $iy) (f64.const 1)))

        (set_local $x (f64.add
          (local.get $xmin)
          (f64.div
            (f64.mul (local.get $r) (local.get $ix))
            (local.get $w))))

        (set_local $y (f64.add
          (local.get $ymin)
          (f64.div
            (f64.mul (local.get $t) (local.get $iy))
            (local.get $h))))

        (set_local $i (call $iter
          (local.get $x) (local.get $y) (local.get $iterations)))

        (set_local $pixel
          (i32.mul
            (i32.const 4)
            (i32.trunc_f64_u (f64.add
              (local.get $ix)
              (f64.mul (local.get $width) (local.get $iy))))))

        (if
          (i32.gt_u (local.get $i) (local.get $iterations))
          (then
            ;; colour black
            (call $setPixel
              (i32.const 0) (local.get $pixel) (local.get $c))
          )
          (else
            (set_local $c (f64.mul
              (f64.const 3) (f64.div
                (call $log (local.get $i))
                (call $log (local.get $s)))))
            (if
              (f64.lt (local.get $c) (f64.const 1))
              (then
                (call $setPixel
                  (i32.const 1) (local.get $pixel) (local.get $c))
              )
              (else
                (if
                  (f64.lt (local.get $c) (f64.const 2))
                  (then
                    (call $setPixel
                      (i32.const 2) (local.get $pixel) (local.get $c))
                  )
                  (else
                    (call $setPixel
                      (i32.const 3) (local.get $pixel) (local.get $c))
                  )
                )
              )
            )
          )
        )

        ;; loop while 0 <= ++iy < height
        (br_if 0
          (f64.lt (local.get $iy) (local.get $height)))

      )

      (set_local $iy (f64.const 0))

      ;; loop while 0 <= ++ix < width
      (br_if 0
        (f64.lt (local.get $ix) (local.get $width)))

    )
  )

)
