### Project implements a heuristic 2D rectangle packing algorithm###

`Used for:` packing as much rectangles as possible in convex & concave containers

#### Based on ideas described in paper: ####

`"A heuristic approach for packing rectangles in convex regions" by Andrea Cassioli, Marco Locatelli (paper)`

### Implementation details: ###

  * Coded with Processing.org IDE (Java)
  * Runs on Linux OS
  * Uses `liblbfgs` optimizer and Java `liblbfgs` wrapper
  * Best for packing x/y axis aligned elements
  * Supports 90 degrees element/rectangle rotation (horizontal & vertical)
  * Multi-iteration solving
  * Fixed size rectangles & any size container
  * Example container editor included for generating input data

### Screenshots###

Packing inside triangle

![Alt text](/img/pic1.png "Packing inside a triangle container")

Packing inside custom shape #1

![Alt text](/img/pic2.png "Packing inside custom shape 1")

Packing inside custom shape #2

![Alt text](/img/pic3.png "Packing inside custom shape 2")
