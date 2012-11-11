
double sqr(double x) {
  return x*x;
}

double maxi(double a, double b) {
  return (a>b)?a:b;
}

double abs(double x) {
  return (x<0)?(-x):x;
}

double fx_ij(double ci_x, double p_i, double cj_x, double p_j) {
  double dx = sqr(ci_x - cj_x);
  double dp = sqr(a - (a-b)*(p_i + p_j)/2);
  return sqr(maxi(0.0, dx-dp));
}

double fy_ij(double ci_y, double p_i, double cj_y, double p_j) {
  double dy = sqr(ci_y - cj_y);
  double dp = sqr(b + (a-b)*(p_i + p_j)/2);
  return sqr(maxi(0.0, dy-dp));
}

// ------------------------------------------------------
double h_i(double cx, double cy, int p) {
  
  double half_a = a/2;
  double half_b = b/2;
  int p_inv = 1-p;
  double b_inv = half_b*p_inv;
  double a_inv = half_a*p_inv;
  double bp = half_b*p;
  double ap = half_a*p;
  
   double[] pts = new double[] {
      cx - a_inv - bp, cy - b_inv - ap,
      cx + a_inv + bp, cy - b_inv - ap,
      cx - a_inv - bp, cy + b_inv + ap,
      cx + a_inv + bp, cy + b_inv + ap
    };
   
    return c.gk(pts);
}

// ------------------------------------------------------
// computes Fn for minimization from current rectangle configuration
double func_eval(Config x) {
  double fsum = 0;
  for(int i=0, k=0; i<x.p.length; i++, k+=2) {
    double ci_x = x.c[k];
    double ci_y = x.c[k+1];
    double p_i  = x.p[i];
    
    for(int j=i+1, z=k+2; j<x.p.length; j++, z+=2) {
      double f1 = fx_ij(ci_x, p_i, x.c[z], x.p[j]);
      double f2 = fy_ij(ci_y, p_i, x.c[z+1], x.p[j]);
      fsum += f1 * f2;
    }
  }
  //println(String.format("fsum: %g", fsum));
  double hsum = 0;
  for(int i=0, k=0; i<x.p.length; i++, k+=2) {
    hsum += h_i(x.c[k], x.c[k+1], x.p[i]);
  }
  //println(String.format("hsum: %g", hsum));
  return fsum + hsum;
}

double[] func_diff(Config x, double h) {
  int n = x.p.length*2;
  double double_step = 2*h;
  double[] gradient = new double[n];
 
  for (int i=0; i<n; i++) {
    double old = x.c[i];
    
     // simple central point differential
    x.c[i] = old+h;
    double f_next = func_eval(x);
    x.c[i] = old-h;
    double f_prev = func_eval(x);
    x.c[i] = old;
    
    gradient[i] = (f_next - f_prev)/double_step; 
  }
  return gradient;
}
