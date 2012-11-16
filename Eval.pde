
float sqr(float x) {
  return x*x;
}

float maxi(float a, float b) {
  return (a>b)?a:b;
}

float mini(float a, float b) {
  return (a>b)?b:a;
}

/*double abs(double x) {
  return (x<0)?(-x):x;
}*/

float fx_ij(float ci_x, float p_i, float cj_x, float p_j) {
  float dx = sqr(ci_x - cj_x);
  float dp = sqr(a - (a-b)*(p_i + p_j)/2);
  float delta = dx-dp;
  if (delta < 0) return sqr(delta);
  return 0;
  //return sqr(maxi(0, delta));
}

float fy_ij(float ci_y, float p_i, float cj_y, float p_j) {
  float dy = sqr(ci_y - cj_y);
  float dp = sqr(b + (a-b)*(p_i + p_j)/2);
  float delta = dy-dp;
  if (delta < 0) return sqr(delta);
  return 0;
  //return sqr(maxi(0, delta));
}

// ------------------------------------------------------
float h_i(float cx, float cy, int p) {
  
  float half_a = a/2;
  float half_b = b/2;
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
   
    return c.gk(pts);
}

// ------------------------------------------------------
// computes Fn for minimization from current rectangle configuration
float func_eval(Config x) {
  float fsum = 0;
  for(int i=0, k=0; i<x.p.length; i++, k+=2) {
    float ci_x = (float)x.c[k];
    float ci_y = (float)x.c[k+1];
    float p_i  = (float)x.p[i];
    
    for(int j=i+1, z=k+2; j<x.p.length; j++, z+=2) {
      float f1 = fx_ij(ci_x, p_i, (float)x.c[z], (float)x.p[j]);
      float f2 = fy_ij(ci_y, p_i, (float)x.c[z+1], (float)x.p[j]);
      fsum += f1 * f2;
      //println(String.format("i=%d j=%d f1=%g f2=%g fsum: %g", i, j, f1, f2, fsum));
    }
  }
  //println(String.format("fsum: %g", fsum));
  float hsum = 0;
  for(int i=0, k=0; i<x.p.length; i++, k+=2) {
    hsum += h_i((float)x.c[k], (float)x.c[k+1], x.p[i]);
  }
  //println(String.format("hsum: %g", hsum));
  return fsum + hsum;
}

// numerical function differentiation using central point method, error O((h^4)/30)
double[] func_diff_2(Config x, double h) {
  int n = x.p.length*2;
  double twelve_h = 12*h;
  double[] gradient = new double[n];
 
  for (int i=0; i<n; i++) {
    double old = x.c[i];
    
     // central point differential with 4 sample points
    x.c[i] = old+h;
    double f_next = func_eval(x);
    x.c[i] = old+2*h;
    double f_next2 = func_eval(x);
    
    x.c[i] = old-h;
    double f_prev = func_eval(x);
    x.c[i] = old-2*h;
    double f_prev2 = func_eval(x);
    
    x.c[i] = old;
    gradient[i] = (-f_next2 + 8*f_next - 8*f_prev - f_prev2)/twelve_h; 
  }
  return gradient;
}

// numerical function differentiation using central point method, error O((h^2)/6)
double[] func_diff(Config x, double h) {
  int n = x.p.length*2;
  double double_step = 2*h;
  double[] gradient = new double[n];
 
  for (int i=0; i<n; i++) {
    double old = x.c[i];
    
     // simple central point differential with 2 sample points
    x.c[i] = old+h;
    double f_next = func_eval(x);
    x.c[i] = old-h;
    double f_prev = func_eval(x);
    x.c[i] = old;
    
    gradient[i] = (f_next - f_prev)/double_step; 
  }
  return gradient;
}


