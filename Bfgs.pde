import lbfgsb.Minimizer;

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

class BfgsSolver {
  
  public void minimize(Config x) {
      try {
        int n = x.c.length; // only rect centers, p - fixed
        Minimizer mini = new Minimizer();
        //mini.setNoBounds(n);  // solve unbounded
        
        //TODO: init bounds array after loading container info
        List<Bound> bounds = new ArrayList<Bound>();
        Bound bx = new Bound((double)c.xmin, (double)c.xmax);
        Bound by = new Bound((double)c.ymin, (double)c.ymax);
        for(int i=0; i<n; i++) {
          if (i%2==0) {
            bounds.add(bx);
          } else {
            bounds.add(by);
          }
        }
        mini.setBounds(bounds);
        
        mini.setIterationFinishedListener(new BfgsListener());
        
       // double[] start = new double[n];
       // for (int i=0; i<n; i++) { start[i] = x.c[i]; }
        
        Result result = mini.run(new ContinuousDiff(x), x.c);
        x.c = result.point;
	//System.out.println("The final result: "+result);
      } catch (LBFGSBException ex) {
        println(ex);
      }
  }
}

