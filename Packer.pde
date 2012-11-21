
class Stat {
  float sum = 0;
  int n = 0;
  
  void reset(){ sum = 0; n = 0; }
  void put(float value) { sum += value; n++;}
  float avrg(){ return (n>0)?(sum/n):0; }
}

final Stat stats = new Stat();
final Container c = new Container();
final int a = 20;
final int b = 20;
final int maxNoImp = 100;
Config state = null;
final int numRects = 50;


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
void refine(Config y) {
  bfgs.minimize(y);
}

// ------------------------------------------------------
Config perturb(Config x) {
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
  double area = c.area();
  println(String.format("area: %g, upper N bound: %d", area, (int)Math.floor(area/(a*b))));
  
  state = ranGen(numRects);
  init_bfgs_bounds(state.c.length);
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

void mouseMoved() {
  //Segment s = new Segment(new float[]{100,100,300,100}, 200,200);
 // println(s.pdist(mouseX, mouseY));
}
