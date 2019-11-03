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

)
