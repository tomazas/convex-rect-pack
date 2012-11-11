import lbfgsb.Minimizer;

class ContinuousDiff implements DifferentiableFunction {
  
    Config cfg = null;  
  
    public ContinuousDiff(Config x) { cfg = x; }
    
    public FunctionValues getValues(double[] point) {
      Config temp = new Config(point, cfg.p); 
      double functionValue = func_eval(temp);
      //println(String.format("DFS evaluate - fval: %g", functionValue));
      double[] gradient = func_diff(temp, 0.0001);
      return new FunctionValues(functionValue, gradient);
    }
}

class BfgsListener implements IterationFinishedListener {
    public boolean iterationFinished(double[] point, double functionValue, double[] gradient)  {
      println(String.format("Listener iteration - fval: %g", functionValue));
      return true; // continue algorithm
    }
}

class BfgsSolver {
  
  public void minimize_cont(Config x) {
      try {
        int n = x.p.length*2; // only rect centers, p - fixed
        Minimizer mini = new Minimizer();
        mini.setNoBounds(n);  // solve unbounded
        mini.setIterationFinishedListener(new BfgsListener());
        
       // double[] start = new double[n];
       // for (int i=0; i<n; i++) { start[i] = x.c[i]; }
        
        Result result = mini.run(new ContinuousDiff(x), x.c);
        x.c = result.point;
	System.out.println("The final result: "+result);
      } catch (LBFGSBException ex) {
        println(ex);
      }
  }
}

