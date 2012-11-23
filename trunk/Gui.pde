
import javax.swing.*;
import java.awt.GridBagLayout;
import java.awt.GridBagConstraints;
import java.awt.Insets;  
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

interface Param {
  int getValue();
  void setValue(int val);
}

class EditParam implements Param {
  private JTextField tf;
  public EditParam(JTextField tf) {
    this.tf = tf;
  }
  int getValue() {
    try {
      return Integer.parseInt(tf.getText());
    } catch(Exception e) {}
    return 0;
  }
  void setValue(int val) {
    tf.setText(""+val);
  }
}

Param rectsValue = null;
Param itersValue = null;
Param aValue = null;
Param bValue = null;

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
    
    JTextField tf = new JTextField(""+numRects);
    rectsValue = new EditParam(tf);
    newItem(f, tf, true, true, 5, 5, 1, 1);

    newItem(f, new JLabel("a:"), false, true, 5, 5, 0.25, 1);
    
    tf = new JTextField(""+a);
    aValue = new EditParam(tf);
    newItem(f, tf, true, true, 5, 5, 1, 1);
    
    newItem(f, new JLabel("b:"), false, true, 5, 5, 0.25, 1);
    
    tf = new JTextField(""+b);
    bValue = new EditParam(tf);
    newItem(f, tf, true, true, 5, 5, 1, 1);

    final JButton bgen = new JButton("Generate");
    bgen.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent evt) {
        resetPacker();
        redraw();
      }
    });
    newItem(f, bgen, true, true, 5, 5, 1, 1);
    
    newItem(f, new JLabel("maxIters:"), false, true, 5, 5, 0.25, 1); 
    
    tf = new JTextField(""+maxNoImp);
    itersValue = new EditParam(tf);
    newItem(f, tf, true, true, 5, 5, 1, 1);
    
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
        redraw();
      }
    };
    
    bsolve.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent evt) {
        if(!runPacker()) return;
        bsolve.setEnabled(false);
        bgen.setEnabled(false);
        bstop.setEnabled(true);
      }
    });
    
    final JButton bexit = new JButton("Exit");
    bexit.setEnabled(true);
    bexit.addActionListener(new ActionListener() {
      public void actionPerformed(ActionEvent evt) {
        System.exit(0);
      }
    });
    newItem(f, bexit, true, true, 5, 5, 1, 1);
    
    f.setVisible(true);
}
