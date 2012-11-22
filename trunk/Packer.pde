
class Stat {
  float sum = 0;
  int n = 0;
  
  void reset(){ sum = 0; n = 0; }
  void put(float value) { sum += value; n++;}
  float avrg(){ return (n>0)?(sum/n):0; }
}

final Stat stats = new Stat();
final Container c = new Container();
final int a = 40;
final int b = 20;
final int maxNoImp = 100;
Config state = null;
final int numRects = 30;

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
double refine(Config y) {
  return bfgs.minimize(y);
}

// ------------------------------------------------------
Config perturb(Config x) {
  Config newX = x.make_copy();
  cont2(newX, 0.2 * sqrt(sqr(a)+sqr(b)));
  if (a!=b) comb2(newX, 0.15);
  return newX;
}

// ------------------------------------------------------
int READY = 0, WORKING = 1, STOP = 2;
int packerState = READY;
Runnable halt = null;

// ------------------------------------------------------
void runPacker() {
  new Thread(new Runnable(){
    public void run() {
      packerState = WORKING;
      long t0 = System.nanoTime();
      state = solve(state);
      float seconds = (System.nanoTime() - t0) * 1e-9f;
      stats.put(seconds);
      println("elapsed time: "+seconds + " seconds, average: " 
          + stats.avrg() + " for " + stats.n + " tests");
      packerState = READY;
      halt.run();
    }
  }).start();
}

// ------------------------------------------------------
void stopPacker() {
  packerState = STOP;
  while (packerState != READY) {
    try {
      Thread.sleep(100);
    } catch (Exception e) {}
  }
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
    double newZ = refine(Zk);
    
    if (newZ < Z) {
      println(String.format("Iteration: %d > newZ: %g prevZ: %g - improved", step, newZ, Z));
      Xk = Zk;
      Z = newZ;
      noImp = 0;
      
      // show results
      state = Xk; 
      redraw();
    } else {
      noImp = noImp+1;
      println(String.format("Iteration: %d > newZ: %g prevZ: %g - no improvement, iters = %d", step, newZ, Z, noImp));
    }

    if (Z <= 0.001) {
      println("reached newZ <= 0.001");
      break;
    }
    
    step = step+1;
  } while(noImp <= maxNoImp && packerState != STOP);
  
  println("solve loop exited");
 
  return Xk;
}

void setup(){
  size(640, 480);
  noLoop();
  noFill();
  stroke(255,0,0);
  
  c.load("data.txt");
  double area = c.area();
  println(String.format("area: %g, upper N bound: %d", area, (int)Math.floor(area/(a*b))));
  
  state = ranGen(numRects);
  init_bfgs_bounds(numRects*2);
  
  setup_gui();
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
}

import javax.swing.*;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.Insets;  
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

        public static void newItem(java.awt.Container dest, JComponent comp, boolean newln, boolean autosz,
                             int spX, int spY, float weightX, float weightY){
            GridBagConstraints cons = new GridBagConstraints();
            cons.insets = new Insets(spY, spX, spY, spX);
            if(newln) cons.gridwidth = GridBagConstraints.REMAINDER; // end line
            if(autosz) cons.fill = GridBagConstraints.BOTH; // autosize
            cons.weightx = weightX;
            cons.weighty = weightY;
            dest.add(comp, cons);
        }


void setup_gui() {
    JFrame f = new JFrame("Controls");
    f.setLayout(new GridBagLayout());
    f.setSize(250, 250);
    f.setLocation(200,200);
    f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    newItem(f, new JLabel("Rects:"), false, true, 5, 5, 0.25, 1); 
    newItem(f, new JTextField(""+numRects), true, true, 5, 5, 1, 1);
    newItem(f, new JLabel("a:"), false, true, 5, 5, 0.25, 1); 
    newItem(f, new JTextField(""+a), true, true, 5, 5, 1, 1);
    newItem(f, new JLabel("b:"), false, true, 5, 5, 0.25, 1); 
    newItem(f, new JTextField(""+b), true, true, 5, 5, 1, 1);
    newItem(f, new JLabel("maxIters:"), false, true, 5, 5, 0.25, 1); 
    newItem(f, new JTextField(""+maxNoImp), true, true, 5, 5, 1, 1);
    
    final JButton bgen = new JButton("Generate");
    bgen.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent evt) {
        state = ranGen(numRects);
        redraw();
      }
    });
    newItem(f, bgen, true, true, 5, 5, 1, 1);
    
    final JButton bsolve = new JButton("Solve");
    newItem(f, bsolve, false, true, 5, 5, 1, 1);
        
    final JButton bstop = new JButton("Stop");
    bstop.setEnabled(false);
    bstop.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent evt) {
        stopPacker();
        halt.run();
      }
    });
    newItem(f, bstop, true, true, 5, 5, 1, 1);
    
    halt = new Runnable() {
      public void run() {
        println("halt executed");
        bsolve.setEnabled(true);
        bgen.setEnabled(true);
        bstop.setEnabled(false);
      }
    };
    
    bsolve.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent evt) {
        runPacker();
        bsolve.setEnabled(false);
        bgen.setEnabled(false);
        bstop.setEnabled(true);
      }
    });
    
    f.setVisible(true);
}
