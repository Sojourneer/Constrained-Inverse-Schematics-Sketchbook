class Joint{
  //String name;
  float  _deg_value;
  float  _aMin;
  float  _aMax;
  
  Joint(/*String j_name, */float a_min, float a_max){
    //name = j_name;
    _aMin = a_min;
    _aMax = a_max;
    _deg_value = 0.0;
  }
  
  // Display the joint and its limit cone
  void display(PVector position, float in_angle, int clr){
    strokeWeight(5);
    stroke(clr);
    circle(position.x, position.y, 20);
    
    float c_aMin = in_angle + _aMin;
    float c_aMax = in_angle + _aMax;
    println("angle limits: " + c_aMin + ", " + c_aMax);
    
    PVector v;

    PVector pMin = position.copy();
    v = PVector.fromAngle(radians(c_aMin));
    v.mult(100);
    pMin.add(v);
    println("min: " + pMin);
    
    PVector pMax = position.copy();
    v = PVector.fromAngle(radians(c_aMax));
    v.mult(100);
    pMax.add(v);

    strokeWeight(1);
    //stroke(#800000);
    line(position.x, position.y, pMin.x, pMin.y); 
    line(position.x, position.y, pMax.x, pMax.y); 
  }
}
