
Container c = null;
int a = 40;
int b = 20;
int maxN = 0;
final int maxNoImp = 100;

// ------------------------------------------------------
// generate randomly placed boxes inside the non-convex area
Config ranGen(int N) {
  Config conf = new Config(N);
  Random r = new Random();
  for (int i=0, k=0; i<N; i++, k+=2) {
    int cx, cy;
    do {
      // check if valid
      cx = c.xmin + r.nextInt(c.xmax-c.xmin);
      cy = c.ymin + r.nextInt(c.ymax-c.ymin);
    } while(!c.inside(cx, cy));
    // create the box
    conf.p[i] = r.nextBoolean() ? 0 : 1;
    conf.c[k] = cx;
    conf.c[k+1] = cy;
  }
  return conf;
}

// ------------------------------------------------------
// runs an optimization algorithm BFGS to minimize area function
void refine(Config y) {
  (new BfgsSolver()).minimize_cont(y);
}

// ------------------------------------------------------
Config perturb(Config x) {
  Config newX = x.copy();
  cont2(newX, 0.2 * sqrt(a*a+b*b));
  //cont1(newX); // TODO: apply other techniques???
  return newX;
}

// ------------------------------------------------------
Config solve(Config Xk) {
  println("solve invoked");
  
  refine(Xk);
  Config Xprev = Xk;
  int k = 1;     // current step index
  int noImp = 0; // number of iterations with no improvement
  
  do {
    println("solve iteration: " + k);
    Config Zk = perturb(Xk);
    println("perturb done");
    refine(Zk);
    println("refine done");
    
    double newZ = func_eval(Zk);
    double prevZ = func_eval(Xk);
    println(String.format("newZ: %g prevZ: %g", newZ, prevZ));
    
    if (newZ < prevZ) {
      Xprev = Xk;
      Xk = Zk;
      noImp = 0;
      println("improved");
    } else {
      Xk = Xprev;
      noImp = noImp+1;
      println("no improvement");
    }

    if (prevZ <= 0.001) {
       println("reached prevZ <= 0.001");
       break;
    }
    
    k = k+1;
  } while(noImp <= maxNoImp);
  
  println("solve loop exited");
  
  return Xk;
}

Config state = null;

void setup(){
  size(640, 480);
  noFill();
  stroke(255,0,0);
  
  c = new Container();
  c.load("data.txt");
  int area = c.area();
  maxN = floor(area/(a*b));
  println(String.format("area: %d, upper N bound: %d", area, maxN));
  
  state = ranGen(75);
  //state = solve(state);
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
  
  // container bounding box
  stroke(255,0,0);
  rect(width-2*a, 2*b, a, b);
}

void mousePressed() {
  state = solve(state);
}
