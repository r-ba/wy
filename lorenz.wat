;; lorenz attractor
(module

  ;; 64Kb per page
  ;; i = max_iterations
  ;; [0, 3*i)  -> system initial conditions, 3 byte per value (x,y,z)
  ;; [3*i, 6*i)  -> updated system data, 3 byte per value (x,y,z)

  (import "" "sin" (func $sin (param f64) (result f64)))
  (import "" "cos" (func $cos (param f64) (result f64)))
  (import "" "load" (func $load (param i32) (param i32) (result f64)))
  (import "" "store" (func $store (param i32) (param i32) (param f64)))
  (import "" "push" (func $push (param f64) (param f64)))
  (import "" "reset" (func $reset))

  ;;(memory (export "mem") 2)

  (func $setup
    (local $i i32)
    (local $max_iterations i32)
    (local $r f64)
    (local $s f64)
    (local $t f64)
    (local $x0 f64)
    (local $y0 f64)
    (local $z0 f64)
    (local $x1 f64)
    (local $y1 f64)
    (local $z1 f64)
    (local $interval f64)
    (local $zoom f64)

    (set_local $r (f64.const 5))
    (set_local $s (f64.const 15))
    (set_local $t (f64.const 1))
    (set_local $x0 (f64.const 0.1))
    (set_local $y0 (f64.const 0.1))
    (set_local $z0 (f64.const 0.1))
    (set_local $x1 (f64.const 0.1))
    (set_local $y1 (f64.const 0.1))
    (set_local $z1 (f64.const 0.1))
    (set_local $interval (f64.const 0.02))
    (set_local $zoom (f64.const 15))
    (set_local $max_iterations (i32.const 20000))

    (loop
      ;; x1 = x0 + (y0 - x0) * r * interval
      (set_local $x1 (f64.add
        (local.get $x0)
        (f64.mul
          (f64.sub (local.get $y0) (local.get $x0))
          (f64.mul (local.get $r) (local.get $interval)))))

      ;; y1 = y0 + (x0 * (s - z0) - y0) * interval
      (set_local $y1 (f64.add
        (local.get $y0)
        (f64.mul
          (f64.sub
            (f64.mul
              (local.get $x0)
              (f64.sub
                (local.get $s)
                (local.get $z0)))
            (local.get $y0))
          (local.get $interval))))

      ;; z1 = z0 + ((x0 * y0) - (t * z0))*interval
      (set_local $z1 (f64.add
        (local.get $z0)
        (f64.mul
          (f64.sub
            (f64.mul
              (local.get $x0)
              (local.get $y0))
            (f64.mul
              (local.get $t)
              (local.get $z0)))
          (local.get $interval))))

      (call $store
        (local.get $i)
        (i32.const 0)
        (f64.mul (local.get $x1) (local.get $zoom)))
      (call $store
        (local.get $i)
        (i32.const 1)
        (f64.mul (local.get $y1) (local.get $zoom)))
      (call $store
        (local.get $i)
        (i32.const 2)
        (f64.mul (f64.sub (local.get $z1) (local.get $s)) (local.get $zoom)))

      ;; setup for next iteration, x0 = x1, y0 = y1, z0 = z1, i++
      (set_local $x0 (local.get $x1))
      (set_local $y0 (local.get $y1))
      (set_local $z0 (local.get $z1))
      (set_local $i (i32.add (local.get $i) (i32.const 3)))

      ;; loop if i < max_iterations
      (br_if 0
        (i32.lt_u (local.get $i) (local.get $max_iterations)))
    )
  )

  ;; run setup at start
  (start $setup)

  (func (export "update") (param $frame f64)
    (local $i i32)
    (local $j i32)
    (local $max_iterations i32)
    (local $theta f64)
    (local $sine f64)
    (local $cosine f64)
    (local $x f64)
    (local $y f64)

    (set_local $max_iterations (i32.const 20000))
    (set_local $theta (f64.mul (f64.const 0.015) (local.get $frame)))
    (set_local $sine (call $sin (local.get $theta)))
    (set_local $cosine (call $cos (local.get $theta)))

    (call $reset)

    (loop
      (set_local $x (f64.add
        (f64.mul
          (call $load (local.get $i) (i32.const 0))
          (local.get $cosine))
        (f64.mul
          (call $load (local.get $i) (i32.const 2))
          (local.get $sine))))
      (set_local $y (call $load (local.get $i) (i32.const 1)))

      (call $push (local.get $x) (local.get $y))

      (set_local $i (i32.add (local.get $i) (i32.const 3)))
      (set_local $j (i32.add (local.get $j) (i32.const 2)))

      ;; loop if i < max_iterations
      (br_if 0
        (i32.lt_u (local.get $i) (local.get $max_iterations)))
    )
  )
)
