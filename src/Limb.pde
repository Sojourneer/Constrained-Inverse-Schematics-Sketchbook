/*ToDo:
  ☑  readout of joint values
  ☑  show cones of joint limits
  * Refactor so that each link has: start position, length, end position, joint at end.
      Joint at the end represents the actual construction, and makes the joint limits relative to the link orientation, not to its predecessor. 
    Note: Impossible to share the points at the joints, since FABRIK relaxes the coincidence constraint during forward operation.
    So the end position (and joint location) is implicit.
  * Add joint limit constraining.
*/

/*
Notes on 6DOF Third Hand:
1. Solve rotation around Z for base separately.
2. Solve orientation Roll and Yaw separately.  TBD the 3D center point.
   Apply any adjustment to required end effector position
3. Apply Fabrik(F,B) pair 

  * decide how to control velocity:
    - generate small steps with velocity on a planned line to the final destination (possible?)  
      and just constantly run the update function
    - So this is integrated with planning and velocity control
  * Add feasibility failure feedback to planner
*/
class Limb{
    // The joints are implicit at the start of each link, which is link.position
    ArrayList<JointOutLink> segments = new ArrayList<JointOutLink>();
    ArrayList<Joint> joints = new ArrayList<Joint>();
    
    int numEffectors;
    PVector target;
    PVector root;
    
    Limb(PVector r, ArrayList<Float>link_lengths){
      root = r;
      numEffectors = link_lengths.size();
      println("Number of link lengths: " + numEffectors);
      float sum = 0;
      for(int i=0; i < numEffectors; i++) {
        println("link " + i + " L=" + link_lengths.get(i));
        JointOutLink link = new JointOutLink(width/2, height-sum, link_lengths.get(i));
        link.joint = new Joint(-90,90);
        segments.add(link);
        sum += link_lengths.get(i);
      }
      segments.add(new JointOutLink(width/2, height-sum, 123));
      println("Number of links: " + segments.size());
    }
    
    
    void fabrikF() {
      JointOutLink next = segments.get(segments.size()-1);
      next.position = target.copy();
      for(int i = segments.size()-2; i >= 0; i--){
        JointOutLink current = segments.get(i);
        PVector direction = PVector.sub(next.position, current.position);
        direction.setMag(current.length);
        current.position = PVector.sub(next.position, direction);
        next = current;
      }
    }
    
    void fabrikB(){
      JointOutLink previous = segments.get(0);
      previous.position = root;  // put it back
      for(int i = 1; i < segments.size(); i++){
        JointOutLink current = segments.get(i);
        PVector direction = PVector.sub(current.position, previous.position);
        direction.setMag(previous.length);
        current.position = PVector.add(previous.position, direction);
        previous = current;
      }
    }
    
    void display() {
      Integer[] sc = {#800000, #008000, #000080, #808080};
      
      PFont myFont; // Declare a PFont object
      myFont = createFont("Arial", 12); // Create the font (e.g., Arial, size 32)
      textFont(myFont);
      float in_angle = -90;
      for(int i=0; i < segments.size()-1; i++){
        //println("i: " + i);

        JointOutLink c = segments.get(i);
        JointOutLink n = segments.get(i+1);
        c.display(in_angle, n.position, sc[i]);
        fill(0);
        text(""+c.joint._deg_value, c.position.x+20, c.position.y);
        in_angle = degrees(PVector.sub(n.position, c.position).heading()); //FIXME
      }
      
      // Now the one without a joint
      JointOutLink endEffector = segments.get(segments.size()-1);
      color(0);
      strokeWeight(5);
      circle(endEffector.position.x, endEffector.position.y, 15);
    }
    
    void update(){
      fabrikF();
      fabrikB();
      
      /* Calculate the joint angles
         This means calculate the vectors for each link, and calculate the angle it makes with the previous link.
         FOr the first joint, we imagine a vector going straight up (decreasing in the coordinate system of processing.org)
      */
      PVector v_prev = new PVector(0,-1); // "below" the base
      //PVector v1;
      for(int i=0; i < segments.size()-1; i++){
         JointOutLink s1 = segments.get(i);    // start of the link[i]
         JointOutLink s2 = segments.get(i+1);  // end of the link[i]
         //PVector v_prev = s1.position.copy().sub(v0);            // v1[i=0] is vector from "below" the base to the base point
         PVector v_curr = PVector.sub(s2.position,s1.position);
         
         println("v_prev deg " + v_prev.heading());
         println("v_curr deg " + v_curr.heading());
            
         s1.joint._deg_value = degrees(PVector.angleBetween(v_curr,v_prev));

         if(v_curr.heading() < v_prev.heading()) s1.joint._deg_value *= -1;  // works from -90 to 180, 0 being inline
         //if(v_curr.heading() * v_prev.heading() > 0) s1.joint._deg_value *= -1;

             //s1.joint._deg_value += 180;
             
         // This is doesn't reflect the direction.  But heading() on the v_prev, v_curr does. So we could multiply out if the headings are different sign. 
         println("joint " + i + " " + s1.joint._deg_value);
         
         v_prev = v_curr;
      }
    }

}
