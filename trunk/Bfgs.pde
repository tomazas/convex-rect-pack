//import lbfgsb.Minimizer;

class ContinuousDiff implements DifferentiableFunction {
  
    Config cfg = null;  
  
    public ContinuousDiff(Config x) { cfg = x; }
    
    public FunctionValues getValues(double[] point) {
      Config temp = new Config(point, cfg.p); 
      double functionValue = func_eval(temp);
      //println(String.format("DFS evaluate - fval: %g", functionValue));
      double[] gradient = func_diff(temp, 0.001);//func_diff_2(temp, 0.001);
      return new FunctionValues(functionValue, gradient);
    }
}

class BfgsListener implements IterationFinishedListener {
    public boolean iterationFinished(double[] point, double functionValue, double[] gradient)  {
      //println(String.format("Listener iteration - fval: %g", functionValue));
      return true; // continue algorithm
    }
}

static List<Bound> bounds = null;

  public void init_bfgs_bounds(int n) {
      bounds = new ArrayList<Bound>();
      Bound bx = new Bound((double)c.xmin, (double)c.xmax);
      Bound by = new Bound((double)c.ymin, (double)c.ymax);
      for(int i=0; i<n; i++) {
        if (i%2==0) {
          bounds.add(bx);
        } else {
          bounds.add(by);
        }
      }
  }

class BfgsSolver {
 
  public void minimize(Config x) {
      {//try {
        //int n = x.c.length; // only rect centers, p - fixed
        Minimizer mini = new Minimizer();
        //mini.setNoBounds(n);  // solve unbounded
        mini.setBounds(bounds);        
        mini.setIterationFinishedListener(new BfgsListener());
         Result result = null;   
        try {     
        result = mini.run(new ContinuousDiff(x), x.c);
        } catch (Exception e) {
          e.printStackTrace();
        }
        x.c = result.point;
      }// catch (LBFGSBException ex) {
       // println(ex);
     // }
  }
}

