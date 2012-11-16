
class Segment {
 float x0, y0, x1, y1;
 float A, B, C, nx, ny, d;
  
 public Segment(float[] v, float cx, float cy){
   x0 = v[0]; y0 = v[1]; x1 = v[2]; y1 = v[3];
   
   nx = y1-y0;
   ny = x0-x1;
   float f = sqrt(nx*nx + ny*ny);
   A = nx/f;
   B = ny/f;
   C = -A*x0-B*y0;
   
   if (fdist(cx, cy) > 0) {
     A = -A; B = -B; C = -C;
     println(String.format("swap, now A: %g B: %g C: %g", A, B, C));
   } else {
     println(String.format("no swap, now A: %g B: %g C: %g", A, B, C));
   }
   
   nx = x1-x0;
   ny = y1-y0;
   d = sqrt(sqr(nx) + sqr(ny));
   nx /= d;
   ny /= d;
 }
 
 float fdist(float x, float y) {
   return A*x+B*y+C;
 }
 
 float pdist(float x, float y) {
   float dx = x-x0;
   float dy = y-y0;
   float t = dx*nx + dy*ny;
   if (t < 0) return sqrt(sqr(dx) + sqr(dy));
   else if (t > d) return sqrt(sqr(x-x1) + sqr(y-y1));
   float px = x0 + nx*t;
   float py = y0 + ny*t;
   return sqrt(sqr(x-px) + sqr(y-py));
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
  float xmin = 999999, xmax = -999999, 
      ymin = 999999, ymax = -999999;
  float containerArea = 0;
  float[] X, Y;
  float center_x = 0, center_y = 0;
  
  void load(String filename) {
    segments = new ArrayList<Segment>();
    String lines[] = loadStrings(filename);
    X = new float[lines.length-1];
    Y = new float[lines.length-1];

    for (int i=0; i < lines.length; i++) {
      String[] seg = lines[i].split(" ");
      
      if (i == 0) {
        // first point is an inside point of the container
        center_x = Float.parseFloat(seg[0]);
        center_y = Float.parseFloat(seg[1]);
        println(String.format("inside point: %g %g", center_x, center_y));
        continue;
      }
      
      int index = i-1;
      X[index] = Float.parseFloat(seg[0]);
      Y[index] = Float.parseFloat(seg[1]);
      xmin = min(X[index], xmin);
      xmax = max(X[index], xmax);
      ymin = min(Y[index], ymin);
      ymax = max(Y[index], ymax);
      if (index > 0) {    
        segments.add(new Segment(new float[]{X[index-1], Y[index-1], X[index], Y[index]}, center_x, center_y));
      }
    }
    containerArea = polygonArea(X, Y);
    println(String.format("%d lines loaded, segments: %d, ccontainer_area: %g", lines.length, segments.size(), containerArea));
    println(String.format("bounds(xmin ymin xmax ymax): %g %g %g %g", xmin, ymin, xmax, ymax));
  }
  
  boolean inside(float x, float y) {
    return pointInPolygon(X, Y, x, y);
  }
  
  // evaluate all constraints for given point
  /*float gk(float[] pts) {
    //TODO: reimplement
    float gsum = 0;
    for (int i=0; i<segments.size(); i++) {
      Segment s = segments.get(i);
      for (int k=0; k<8; k+=2) {
          float gval = s.fdist((float)pts[k], (float)pts[k+1]);
          gsum += sqr(maxi(0.0, gval));
      }
    }
    return gsum;
  }*/
  
  /*float gk(float[] pts) {
    float gsum = 0;
    for (int k=0; k<8; k+=2) {
          gsum += c.inside((float)pts[k], (float)pts[k+1]) ? 0 : 1;
    }
    return gsum;
  }*/
  
  float gk(float[] pts) {
    float gsum = 0;
    for (int k=0; k<8; k+=2) {
      float x = (float)pts[k];
      float y = (float)pts[k+1];
      if (c.inside(x,y)) continue; // "inside" is good
      
      // find the minimum distance to be "inside"  
      float pmin = 999999;
      for (int i=0; i<segments.size(); i++) {
        float d = segments.get(i).pdist(x,y);
        pmin = mini(pmin, d);
      }
      gsum += sqr(pmin);//sqr(maxi(0.0, pmin));
    }
    return gsum;
  }
  
  float area() {
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
  
  // implementation: http://www.mathopenref.com/coordpolygonarea2.html
  private float polygonArea(float[] pX, float[] pY) { 
    float sum = 0;
    int j = pX.length-1;

    for (int i=0; i<pX.length; i++) { 
      sum += (pX[j]+pX[i]) * (pY[j]-pY[i]); 
      j = i;  //j is previous vertex to i
    }
    return Math.abs(sum*0.5);
  }

  // implementation: http://alienryderflex.com/polygon/
  boolean pointInPolygon(float[] pX, float[] pY, float x, float y) {

    int      j = pX.length-1;
    boolean  oddNodes = false;
    
    //TODO: the denominator - (pY[j]-pY[i])*(pX[j]-pX[i]) can be precalculated in advance (static container)
    //though it's only used in loading, so not much of a algorithm affector

    for (int i=0; i<pX.length; i++) {
      if ((pY[i] < y && pY[j] >= y || pY[j] < y && pY[i] >= y) &&  (pX[i] <= x || pX[j] <= x)) {
        oddNodes ^= (pX[i]+(y-pY[i])/(pY[j]-pY[i])*(pX[j]-pX[i]) < x); 
      }
      j = i; 
    }

    return oddNodes; 
  }
}
