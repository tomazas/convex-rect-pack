
class Stat {
  float sum = 0;
  int n = 0;
  
  void reset(){ sum = 0; n = 0; }
  void put(float value) { sum += value; n++;}
  float avrg(){ return (n>0)?(sum/n):0; }
}

final Stat stats = new Stat();
final Container c = new Container();
final int a = 40;
final int b = 20;
final int maxNoImp = 100;
Config state = null;
final int numRects = 50;


// ------------------------------------------------------
// generate randomly placed boxes inside the non-convex area
Config ranGen(int total) {
  Config conf = new Config(total);
  Random r = new Random();
  int num_horiz = r.nextInt(total);
  for (int i=0, k=0; i<total; i++, k+=2) {
    int cx, cy;
    do {
      // check if point inside area
      cx = c.xmin + r.nextInt(c.xmax-c.xmin);
      cy = c.ymin + r.nextInt(c.ymax-c.ymin);
    } while(!c.inside(cx, cy));
    // create the box
    conf.p[i] = (i < num_horiz) ? 0 : 1;
    conf.c[k] = cx;
    conf.c[k+1] = cy;
  }
  return conf;
}

// ------------------------------------------------------
// runs an optimization algorithm BFGS to minimize area function
void refine(Config y) {
  
  (new BfgsSolver()).minimize(y);
  
  // try to swap every rect orientation & check if it's giving a better result
 /* Config temp = y;
  Config old_temp = null;
  double Z = func_eval(temp);
  boolean improved = true;
  
 // while (improved) {
 //   improved = false;
    
    for (int i=0; i<temp.p.length; i++) {
      old_temp = temp.make_copy();
      temp.p[i] = 1-temp.p[i];

      (new BfgsSolver()).minimize(temp);
      double newZ = func_eval(temp);
      
      if (newZ < Z) {
        //println(String.format("refine z: %g < %g - GOOD", newZ, oldZ));
        Z = newZ;
        improved = true;
      } else {
        // println(String.format("refine z: %g < %g - BAD", newZ, oldZ));
        temp = old_temp; // reset
      }
    }
 // }
  
  y.c = temp.c;
  y.p = temp.p;*/
}

/*
// ------------------------------------------------------
// runs an optimization algorithm BFGS to minimize area function
void refine(Config y) {
  
  (new BfgsSolver()).minimize(y);
  
  // try to swap every rect orientation & check if it's better
  double oldZ = func_eval(y);
  boolean improved = true;
  
  while(improved) {
    improved = false;  
    
    for (int i=0; i<y.p.length; i++) {
      int old_p = y.p[i];
      y.p[i] = 1-old_p;
      
      double newZ = func_eval(y);
      if (newZ < oldZ) {
        oldZ = newZ;
        improved = true;
      } else {
        y.p[i] = old_p;
      }
    }
  }
}
*/

// ------------------------------------------------------
Config perturb(Config x) {
  // TODO: use other techniques
  Config newX = x.make_copy();
  cont1(newX);//cont2(newX, 0.2 * sqrt(a*a+b*b));
  comb2(newX, 0.15);
  return newX;
}

// ------------------------------------------------------
Config solve(Config Xk) {
  println("solve invoked");
  refine(Xk);
  
  int step = 1;  // current step index
  int noImp = 0; // number of iterations with no improvement
  Config Xprev = null;
  double Z = func_eval(Xk);
  
  do {
    Xprev = Xk;
   
    Config Zk = perturb(Xk);
    refine(Zk);
    
    double newZ = func_eval(Zk);
    if (newZ < Z) {
      println(String.format("Iteration: %d > newZ: %g prevZ: %g - improved", step, newZ, Z));
      Xk = Zk;
      Z = newZ;
      noImp = 0;
    } else {
      noImp = noImp+1;
      println(String.format("Iteration: %d > newZ: %g prevZ: %g - no improvement, iters = %d", step, newZ, Z, noImp));
    }

    if (Z <= 0.001) {
      println("reached newZ <= 0.001");
      break;
    }
    
    step = step+1;
  } while(noImp <= maxNoImp);
  
  println("solve loop exited");
  
  return Xk;
}

void setup(){
  size(640, 480);
  noFill();
  stroke(255,0,0);
  
  c.load("data.txt");
  int area = c.area();
  println(String.format("area: %d, upper N bound: %d", area, floor(area/(a*b))));
  
  state = ranGen(numRects);
}

void draw() {
  background(0xFFFFFF);
  c.paint();
  
  if (state != null) {
    for (int i=0, k=0; i<state.p.length; i++, k+=2) {
      stroke(255,127,0);
      if (state.p[i] == 0) {
        rect((int)state.c[k]-a/2, (int)state.c[k+1]-b/2, a, b);
      } else {
        rect((int)state.c[k]-b/2, (int)state.c[k+1]-a/2, b, a);
      }
      stroke(255,0,0);
      ellipse((int)state.c[k], (int)state.c[k+1], 2, 2);
    }
  }
  
  // draw container bounding box
  stroke(255,0,0);
  rect(width-2*a, 2*b, a, b);
}

void mousePressed() {
  // add interactivity
  if (mouseButton == RIGHT) {
    long t0 = System.nanoTime();
    state = solve(state);
    float seconds = (System.nanoTime() - t0) * 1e-9f;
    stats.put(seconds);
    println("elapsed time: "+seconds + " seconds, average: " + stats.avrg() + " for " + stats.n + " tests");
  } else if (mouseButton == LEFT) {
    state = ranGen(numRects);
  }
}
