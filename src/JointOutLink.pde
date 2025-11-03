class JointOutLink {
  PVector position;  // start.  This is also where the implicit joint is located
  float   length;
  Joint  joint;
  
  JointOutLink(float x, float y, float len){
    position = new PVector(x,y);
    length = len;
  }
 
  float calc_angle(PVector v) {
    return 0; //tofix
  }

  void display(float in_angle, PVector next, int clr){
    //float in_angle = 0.0; //TOFIX
    joint.display(position, in_angle, clr);
    stroke(clr);
    strokeWeight(5);
    line(position.x, position.y, next.x, next.y);
  }
}
