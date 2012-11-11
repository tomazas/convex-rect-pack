
// ------------------------------------------------------
// swap two rectangles p values or change a single one's p value
void comb1(Config x) {
  // partition rectangles by p value
  int[] zeros = new int[x.p.length];
  int[] ones = new int[x.p.length];
  int k = 0, j = 0;
  for (int i=0; i<x.p.length; i++) {
    if (x.p[i] == 1) {
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
    x.p[ones[o]] = 0;
  } else if (k == 0) {
    x.p[zeros[z]] = 1;
  } else {
    // swap with probability 1/3
    int type = r.nextInt(3);
    switch (type) {
      case 0: x.p[zeros[z]] = 1; x.p[ones[o]] = 0; break; 
      case 1: x.p[zeros[z]] = 1; break;
      case 2: x.p[ones[o]] = 0; break;
      default: println("error, invalid value: " + type); break;
    }
  }
}

// ------------------------------------------------------
// invert all values with probability "eta", eta should be small (e.g. 0.05)
void comb2(Config x, float eta) {
  Random r = new Random();
  for (int i=0; i<x.p.length; i++) {
    if (r.nextDouble() < eta) {
      x.p[i] = 1 - x.p[i];
    }
  }
}

// ------------------------------------------------------
// move a single rectangle randomly 
void cont1(Config x) {
  Random r = new Random();
  int idx = r.nextInt(x.p.length);
  double alpha_x = c.xmin + r.nextInt(c.xmax-c.xmin);
  x.c[idx*2] = alpha_x; // change cx
}

// ------------------------------------------------------
// move all rectangles randomly with offset from [-d; d] range, 
// good value for d = 0.2 * sqrt(a*a+b*b)
void cont2(Config x, double d) {
  Random r = new Random(); 
  double d2 = 2*d;
  for (int i=0; i<x.p.length; i++) {
    double beta = r.nextDouble()*d2 - d;
    double gamma = r.nextDouble()*d2 - d;
    x.c[i*2] += beta;     // cx
    x.c[i*2+1] += gamma;  // cy
  }
}

