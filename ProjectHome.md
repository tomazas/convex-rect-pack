## Project implements a heuristic 2D rectangle packing algorithm ##


**Used for:** packing as much rectangles as possible in convex & concave containers

**Based on ideas described in paper:**<br />
_"A heuristic approach for packing rectangles in convex
regions" by Andrea Cassioli, Marco Locatelli_ ([paper](https://code.google.com/p/convex-rect-pack/source/browse/trunk/docs/))

**Implementation details:**
  * Coded with Processing.org Java IDE
  * Runs on Linux OS
  * Uses [liblbfgs](http://www.chokkan.org/software/liblbfgs/) and [Java liblbfgs wrapper](https://github.com/mkobos/lbfgsb_wrapper)
  * Best for x/y axis aligned & convex regions
  * Supports 90 degrees rectangle rotation (horizontal & vertical)
  * Multi-iteration solving
  * Same size rectangles & any size container
  * Example container editor included for generating input data

**Screenshots**

<a href='http://convex-rect-pack.googlecode.com/svn/trunk/img/pic1.png'><img src='http://convex-rect-pack.googlecode.com/svn/trunk/img/pic1.png' width='200' height='150' /></a>
<a href='http://convex-rect-pack.googlecode.com/svn/trunk/img/pic2.png'><img src='http://convex-rect-pack.googlecode.com/svn/trunk/img/pic2.png' width='200' height='150' /></a>
<a href='http://convex-rect-pack.googlecode.com/svn/trunk/img/pic3.png'><img src='http://convex-rect-pack.googlecode.com/svn/trunk/img/pic3.png' width='200' height='150' /></a>