
class Rbox {
  public Rbox(int a, int b, int c) {
    cx = a; cy = b; p = c;
  }
  public Rbox copy() {
    return new Rbox(cx, cy, p);
  }
  int cx, cy, p; // p = 0 (horizontal), p = 1 (vertical)
}

class Segment {
 public Segment(int[] v){
   x0 = v[0]; y0 = v[1];
   x1 = v[2]; y1 = v[3];
 }
 
 int x0, y0, x1, y1;
}

class Config {
  public Config(int N){
    rects = new Rbox[N];
  }
  public Config copy() {
    Config c = new Config(rects.length);
    for (int i=0; i<rects.length; i++) {
      c.rects[i] = rects[i].copy(); 
    }
    return c;
  }
  Rbox[] rects = null;
}

class Container {
  
  List<Segment> segments = null;
  int xmin = 999999, xmax = -999999, 
      ymin = 999999, ymax = -999999;

  void load(String filename) {
    segments = new ArrayList<Segment>();
    String lines[] = loadStrings(filename);
    int vals[] = new int[4];
    for (int i=0; i < lines.length; i++) {
      String[] seg = lines[i].split(" ");
      for(int j=0; j<4; j++) {
        vals[j] = Integer.parseInt(seg[j]);
        if (j % 2 == 0) {
          xmin = min(vals[j], xmin);
          xmax = max(vals[j], xmax);
        } else {
          ymin = min(vals[j], ymin);
          ymax = max(vals[j], ymax);
        }
      }
      segments.add(new Segment(vals));
    }
    println(lines.length + " lines loaded, segments: " + segments.size());
    println(String.format("bounds(xmin ymin xmax ymax): %d %d %d %d", xmin, ymin, xmax, ymax));
  }
  
  boolean inside(int x, int y) {
    //TODO: implement
    return true;
  }
  
  int area() {
    //TODO: implement
    return 200*300;
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
}
