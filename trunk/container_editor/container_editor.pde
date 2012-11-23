
class Pt{
  public int x,y;
  Pt(int xx, int yy){x=xx; y=yy;}
}

ArrayList<Pt> pts = new ArrayList<Pt>();
Pt inside = null;

void setup() {
  size(640,480);
  smooth();
}

void draw() {
  background(255,255,255);
  stroke(0,0,0);
  for(int i=0; i<pts.size()-1; i++) {
    Pt from = pts.get(i);
    Pt to = pts.get(i+1);
    line(from.x, from.y, to.x, to.y);
  }
  noStroke();
  fill(255,0,0);
  for(int i=0; i<pts.size(); i++){
     Pt from = pts.get(i);
     ellipse(from.x, from.y, 5, 5);
  }
  fill(0,0,255);
  ellipse(mouseX, mouseY, 5, 5);
  
  if (inside != null) {
    fill(0,255,0);
    ellipse(inside.x, inside.y, 5, 5);
  }
  
  if (nearFirst()) {
    Pt p = pts.get(0);
    noFill();
    stroke(255,0,0);
    ellipse(p.x, p.y, 10, 10);
  }
}

float sqr(float v){ return v*v; }

boolean generate = true;

boolean nearFirst() {
  if (pts.size() > 0) {
      Pt p = pts.get(0);
      float d = sqrt(sqr(p.x-mouseX) + sqr(p.y-mouseY));
      if (d < 15) {
        return true;
      }
  }
  return false;
}

void mousePressed() {
  int x = mouseX;
  int y = mouseY;
  if (mouseButton == LEFT) {
    if (nearFirst()) {
        Pt p = pts.get(0);
        generate = false;
        pts.add(new Pt(p.x, p.y)); // duplicate first point
        export();
    }
    if (generate) {
      pts.add(new Pt(x, y));
    } 
  } else if(mouseButton == RIGHT) {
    inside = new Pt(x, y);
    export();
  }
}


void export() {
  println("export");
  if (inside == null || pts.size() == 0) return;
  try {
    FileWriter fp = new FileWriter(new File("data.txt"));
    fp.write(""+inside.x+" "+inside.y+"\n");
    for(int i=0; i<pts.size(); i++){
     Pt p = pts.get(i);
     fp.write(""+p.x+" "+p.y+"\n");
    }
    fp.close();
  } catch(Exception e){
    println("failed saving: "+e);
  }
}
