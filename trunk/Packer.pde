
class Stat {
  float sum = 0;
  int n = 0;
  
  void reset(){ sum = 0; n = 0; }
  void put(float value) { sum += value; n++;}
  float avrg(){ return (n>0)?(sum/n):0; }
}

final Stat stats = new Stat();
final Container c = new Container();
int a = 40;
int b = 20;
int maxNoImp = 100;
int numRects = 30;
Config state = null;

// ------------------------------------------------------
// generate randomly placed boxes inside the container area
Config ranGen(int total) {
  Config conf = new Config(total);
  Random r = new Random();
  int num_horiz = r.nextInt(total);
  for (int i=0, k=0; i<total; i++, k+=2) {
    float cx, cy;
    do {
      // check if point inside area
      cx = c.xmin + (float)r.nextDouble() * (c.xmax-c.xmin);
      cy = c.ymin + (float)r.nextDouble() * (c.ymax-c.ymin);
    } while(!c.inside(cx, cy));
    // create the box
    conf.p[i] = (i < num_horiz) ? 0 : 1;
    conf.c[k] = cx;
    conf.c[k+1] = cy;
  }
  return conf;
}

// ------------------------------------------------------
BfgsSolver bfgs = new BfgsSolver();

// runs an optimization algorithm BFGS to minimize area function
double refine(Config y) {
  float Z = (float)bfgs.minimize(y);
  for(int i=0; i<y.p.length; i++) {
    y.p[i] = 1-y.p[i];
    float newZ = func_eval(y);
    if (newZ < Z) {
      Z = newZ;
    } else {
      y.p[i] = 1-y.p[i]; // restore old
    }
  }
  return Z;
}

// ------------------------------------------------------
Config perturb(Config x) {
  Config newX = x.make_copy();
  cont2(newX, 0.2 * sqrt(sqr(a)+sqr(b)));
  if (a!=b) comb2(newX, 0.15);
  return newX;
}

// ------------------------------------------------------
int READY = 0, WORKING = 1, STOP = 2;
int packerState = READY;
Runnable halt = null;

// ------------------------------------------------------
boolean runPacker() {
  maxNoImp = itersValue.getValue();
  if (maxNoImp <= 0) {
    JOptionPane.showMessageDialog(null, "maxIters > 0", 
        "Alert", JOptionPane.ERROR_MESSAGE); 
    return false;
  }
  int maxRects = (int)floor(c.area()/(a*b));
  if (numRects > maxRects) {
    JOptionPane.showMessageDialog(null, numRects + " rectangles don't fit in container area.\n"+
        "Container area: " + c.area() + ", maximum: " + maxRects, 
        "Alert", JOptionPane.ERROR_MESSAGE);
  }
  new Thread(new Runnable(){
    public void run() {
      packerState = WORKING;
      long t0 = System.nanoTime();
      state = solve(state);
      float seconds = (System.nanoTime() - t0) * 1e-9f;
      stats.put(seconds);
      println("elapsed time: "+seconds + " seconds, average: " 
          + stats.avrg() + " for " + stats.n + " tests");
      packerState = READY;
      halt.run();
    }
  }).start();
  return true;
}

// ------------------------------------------------------
void stopPacker() {
  packerState = STOP;
  while (packerState != READY) {
    try {
      Thread.sleep(100);
    } catch (Exception e) {}
  }
}

// ------------------------------------------------------
void resetPacker() {
  int tempNumRects = rectsValue.getValue();
  if (tempNumRects <= 0) {
    JOptionPane.showMessageDialog(null, "numRects > 0", 
        "Alert", JOptionPane.ERROR_MESSAGE); 
    return;
  }
  int tempA = aValue.getValue();
  if (tempA <= 0) {
    JOptionPane.showMessageDialog(null, "a > 0", 
        "Alert", JOptionPane.ERROR_MESSAGE); 
    return;
  }
  int tempB = bValue.getValue();
  if (tempB <= 0) {
    JOptionPane.showMessageDialog(null, "b > 0", 
        "Alert", JOptionPane.ERROR_MESSAGE); 
    return;
  }
  numRects = tempNumRects;
  a = tempA;
  b = tempB;
  state = ranGen(numRects);
  init_bfgs_bounds(numRects*2);
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
    Config Zk = perturb(Xk);
    double newZ = refine(Zk);
    
    if (newZ < Z) {
      println(String.format("Iteration: %d > newZ: %g prevZ: %g - improved", step, newZ, Z));
      Xk = Zk;
      Z = newZ;
      noImp = 0;
      
      // show results
      state = Xk; 
      redraw();
    } else {
      noImp = noImp+1;
      println(String.format("Iteration: %d > newZ: %g prevZ: %g - no improvement, iters = %d", step, newZ, Z, noImp));
    }

    if (Z <= 0.001) {
      println("reached newZ <= 0.001");
      break;
    }
    
    step = step+1;
  } while(noImp <= maxNoImp && packerState != STOP);
  
  println("solve loop exited");
 
  return Xk;
}

void setup() {
  size(640, 480);
  noLoop();
  noFill();
  stroke(255,0,0);
  
  c.load("data.txt");
  int maxRects = (int)floor(c.area()/(a*b));
  println(String.format("container area: %g, maxRects: %d",c.area(), maxRects));
  numRects = maxRects;
  
  setup_gui();
  resetPacker();
}

void draw() {
  background(0xFFFFFF);
  c.paint();
  
  float half_a = a/2;
  float half_b = b/2;
  
  int numInside = 0;
  
  if (state != null) {
    for (int i=0, k=0; i<state.p.length; i++, k+=2) {
      stroke(255,127,0);
      
      int cx = (int)state.c[k];
      int cy = (int)state.c[k+1];
      int p = state.p[i];
      int p_inv = 1-p;
      float b_inv = half_b*p_inv;
      float a_inv = half_a*p_inv;
      float bp = half_b*p;
      float ap = half_a*p;
  
      float[] pts = new float[] {
        cx - a_inv - bp, cy - b_inv - ap,
        cx + a_inv + bp, cy - b_inv - ap,
        cx - a_inv - bp, cy + b_inv + ap,
        cx + a_inv + bp, cy + b_inv + ap
      };
      
      boolean in = true;
      for(int j=0; j<4; j++) {
        in &= c.inside(pts[j*2], pts[j*2+1]);
      }
      
      // draw inside rects in yellow
      if (in) {
        fill(255,255,0,128);
        numInside++;
      } else {
        noFill();
      }
    
      if (state.p[i] == 0) {
        rect(cx-a/2, cy-b/2, a, b);
      } else {
        rect(cx-b/2, cy-a/2, b, a);
      }
      stroke(255,0,0);
      ellipse((int)state.c[k], (int)state.c[k+1], 2, 2);
    }
  }
  
  println("rects packed: "+numInside);
}
