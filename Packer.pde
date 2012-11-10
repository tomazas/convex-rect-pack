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
  for (int i=0; i<N; i++) {
    int cx, cy;
    do {
      // check if valid
      cx = c.xmin + (int)((c.xmax-c.xmin)*r.nextDouble());
      cy = c.ymin + (int)((c.ymax-c.ymin)*r.nextDouble());
    } while(!c.inside(cx, cy));
    // create the box
    int p = r.nextBoolean() ? 0 : 1;
    conf.rects[i] = new Rbox(cx, cy, p);
  }
  return conf;
}

// 
Config refine(Config y) {
  
  return y;
}

// swap two rectangles p values or change a single one's p value
void comb1(Config x) {
  // partition rectangles by p value
  int[] zeros = new int[x.rects.length];
  int[] ones = new int[x.rects.length];
  int k = 0, j = 0;
  for (int i=0; i<x.rects.length; i++) {
    if (x.rects[i].p == 1) {
      ones[k++] = i;
    } else {
      zeros[j++] = i;
    }
  }
  // pick random indexes to swap
  Random r = new Random();
  int z = (j > 0) ? r.nextInt(j) : (-1);
  int o = (k > 0) ? r.nextInt(k) : (-1);
  
  if (j == 0) { // handle single cases
    x.rects[ones[o]].p = 0;
  } else if (k == 0) {
    x.rects[zeros[z]].p = 1;
  } else {
    // swap with probability 1/3
    int type = r.nextInt(3);
    switch (type) {
      case 0: x.rects[zeros[z]].p = 1; x.rects[ones[o]].p = 0; break; 
      case 1: x.rects[zeros[z]].p = 1; break;
      case 2: x.rects[ones[o]].p = 0; break;
      default: println("error, invalid value: " + type); break;
    }
  }
}

// invert all values with probability "eta", eta should be small
void comb2(Config x, float eta) {
  Random r = new Random();
  for (int i=0; i<x.rects.length; i++) {
    if (r.nextDouble() < eta) {
      x.rects[i].p = 1 - x.rects[i].p;
    }
  }
}

// move a single rectangle randomly 
void cont1(Config x) {
  Random r = new Random();
  int idx = r.nextInt(x.rects.length);
  int alpha_x = c.xmin + (int)((c.xmax-c.xmin)*r.nextDouble());
  x.rects[idx].cx = alpha_x;
}

// move all rectangles randomly with offset from [-d; d] range, 
// good value for d = 0.2 * sqrt(a*a+b*b)
void cont2(Config x, int d) {
  Random r = new Random(); int d2 = 2*d;
  for (int i=0; i<x.rects.length; i++) {
    int beta = r.nextInt(d2) - d;
    int gamma = r.nextInt(d2) - d;
    x.rects[i].cx += beta;
    x.rects[i].cy += gamma;
  }
}

Config perturb(Config x) {
  Config newX = x.copy();
  cont1(newX); // TODO: apply other techniques???
  return newX;
}

float func(Config x) {
  //TODO: compute function
  return 0;
}

Config solve(int N) {
  Config Y0 = ranGen(N);
  Config Xk = refine(Y0);
  Config Xprev = Xk;
  int k = 1;     // current step index
  int noImp = 0; // number of iterations with no improvement
  
  do {
    Config Yk = perturb(Xk);
    Config Zk = refine(Yk);
    if (func(Zk) < func(Xk)) {
      Xprev = Xk;
      Xk = Zk;
      noImp = 0;
    } else {
      Xk = Xprev;
      noImp = noImp+1;
    }
    k = k+1;
  } while(noImp <= maxNoImp);
  
  return Xk;
}

Config cxx = null;

void setup(){
  size(640, 480);
  noFill();
  stroke(255,0,0);
  
  c = new Container();
  c.load("data.txt");
  int area = c.area();
  maxN = floor(area/(a*b));
  println(String.format("area: %d, upper N bound: %d", area, maxN));
  
  cxx = ranGen(30);
}

void draw() {
  background(0xFFFFFF);
  
  c.paint();
  
  stroke(255,127,0);

  if (cxx != null) {
    for (int i=0; i<cxx.rects.length; i++) {
      if (cxx.rects[i].p == 0) {
        rect(cxx.rects[i].cx-a/2, cxx.rects[i].cy-b/2, a, b);
      } else {
        rect(cxx.rects[i].cx-b/2, cxx.rects[i].cy-a/2, b, a);
      }
    }
  }
  
  stroke(255,0,0);
  rect(width-2*a, 2*b, a, b);
}
