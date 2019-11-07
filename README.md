# wy

A visual exploration of various dynamical systems written using the WebAssembly text format.

At the present moment, four systems have been implemented:
1. [Lorenz attractor](https://en.wikipedia.org/wiki/Lorenz_system)
2. [Mandlebrot Set](https://en.wikipedia.org/wiki/Mandelbrot_set)
3. [Elementary Cellular Automata](https://en.wikipedia.org/wiki/Elementary_cellular_automaton)
4. A discrete system which, given some positive integer n and a row vector, maps each coordinate to a sum of the preceeding coordinates modulo n

### Examples
##### Rule 30
![Rule 30](https://raw.githubusercontent.com/r-ba/wy/master/examples/rule_30.png)
--

##### Lorenz attractor
![Lorenz attractor](https://raw.githubusercontent.com/r-ba/wy/master/examples/lorenz.png)
--

##### Mandelbrot Set
![Mandlebrot set](https://raw.githubusercontent.com/r-ba/wy/master/examples/mandlebrot.png)
--

##### Sigma (mod 561)
![Sigma](https://raw.githubusercontent.com/r-ba/wy/master/examples/sigma_561.png)
