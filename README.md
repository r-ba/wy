# wat

A visual exploration of various dynamical systems written using the WebAssembly text format.

At the present moment, three different systems have been implemented:
1. The world-renowned [Mandlebrot Set](https://en.wikipedia.org/wiki/Mandelbrot_set)
2. All 256 [Elementary Cellular Automata](https://en.wikipedia.org/wiki/Elementary_cellular_automaton) rules
3. A lesser known mapping "sigma" which, given some positive integer n and a k-tuple (x1, ..., xk), maps coordinate-wise each xi to the sum of xj for all j <= i mod n.

### Example images
##### Rule 30
![Rule 30](https://raw.githubusercontent.com/r-ba/wat/master/examples/rule_30.png)
--

##### Mandelbrot Set
![Mandlebrot Set](https://raw.githubusercontent.com/r-ba/wat/master/examples/mandlebrot.png)
--

##### Sigma (modulo 561)
![Sigma](https://raw.githubusercontent.com/r-ba/wat/master/examples/sigma_561.png)
