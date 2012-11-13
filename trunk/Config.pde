
class Segment {
 int x0, y0, x1, y1;
 double A, B, C;
  
 public Segment(int[] v, int cx, int cy){
   x0 = v[0]; y0 = v[1]; x1 = v[2]; y1 = v[3];
   
   int nx = y1-y0;
   int ny = x0-x1;
   double f = sqrt(nx*nx + ny*ny);
   A = nx/f;
   B = ny/f;
   C = -A*x0-B*y0;
   
   if (fdist(cx, cy) > 0) {
     A = -A; B = -B; C = -C;
     println(String.format("swap, now A: %g B: %g C: %g", A, B, C));
   } else {
     println(String.format("no swap, now A: %g B: %g C: %g", A, B, C));
   }
 }
 
 double fdist(double x, double y) {
   return A*x+B*y+C;
 }
}

class Config {
  double[] c = null;
  int[] p = null;
  
  public Config(int N){
    c = new double[2*N];
    p = new int[N];
  }
  public Config(double[] values, int[] orient) {
    c = values; p = orient;
  }
  public Config make_copy() {
    Config cp = new Config(p.length);
    for (int i=0, k=0; i<p.length; i++, k+=2) {
      cp.c[k]   = c[k];   // cx
      cp.c[k+1] = c[k+1]; // cy
      cp.p[i]   = p[i];
    }
    return cp;
  }
}

class Container {
  
  List<Segment> segments = null;
  int xmin = 999999, xmax = -999999, 
      ymin = 999999, ymax = -999999;
  double containerArea = 0;
  
  void load(String filename) {
    segments = new ArrayList<Segment>();
    String lines[] = loadStrings(filename);
    int X[] = new int[lines.length-1];
    int Y[] = new int[lines.length-1];
    int center_x = 0, center_y = 0;
    
    for (int i=0; i < lines.length; i++) {
      String[] seg = lines[i].split(" ");
      
      if (i == 0) {
        // first point is an inside point of the container
        center_x = Integer.parseInt(seg[0]);
        center_y = Integer.parseInt(seg[1]);
        println(String.format("inside point: %d %d", center_x, center_y));
        continue;
      }
      
      int index = i-1;
      X[index] = Integer.parseInt(seg[0]);
      Y[index] = Integer.parseInt(seg[1]);
      xmin = min(X[index], xmin);
      xmax = max(X[index], xmax);
      ymin = min(Y[index], ymin);
      ymax = max(Y[index], ymax);
      if (index > 0) {    
        segments.add(new Segment(new int[]{X[index-1], Y[index-1], X[index], Y[index]}, center_x, center_y));
      }
    }
    containerArea = polygonArea(X, Y, X.length);
    println(String.format("%d lines loaded, segments: %d, ccontainer_area: %g", lines.length, segments.size(), containerArea));
    println(String.format("bounds(xmin ymin xmax ymax): %d %d %d %d", xmin, ymin, xmax, ymax));
  }
  
  boolean inside(double x, double y) {
    //TODO: reimplement
    for (int i=0; i<segments.size(); i++) {
      if (segments.get(i).fdist(x,y) > 0) {
        return false;
      }
    }
    return true;
  }
  
  // evaluate all constraints for given point
  double gk(double[] pts) {
    //TODO: reimplement
    double gsum = 0;
    for (int i=0; i<segments.size(); i++) {
      Segment s = segments.get(i);
      for (int k=0; k<8; k+=2) {
          double gval = s.fdist(pts[k], pts[k+1]);
          gsum += sqr(maxi(0.0, gval));
      }
    }
    return gsum;
  }
  
  double area() {
    return containerArea;
  }
  
  void paint() {
    noFill();
    stroke(0,0,255);
    for(int i=0; i<segments.size();i++) {
      Segment s = segments.get(i);
      line(s.x0, s.y0, s.x1, s.y1);
    }
    stroke(0,255,0);
    rect(xmin-5, ymin-5, xmax-xmin+10, ymax-ymin+10);
  }
  
  private double polygonArea(int[] X, int[] Y, int numPoints) { 
    double sum = 0;
    int j = numPoints-1;

    for (int i=0; i<numPoints; i++) { 
      sum += (X[j]+X[i]) * (Y[j]-Y[i]); 
      j = i;  //j is previous vertex to i
    }
    return Math.abs(sum*0.5);
  }
}
