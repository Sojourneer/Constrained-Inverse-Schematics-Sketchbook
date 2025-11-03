Limb l;

void setup() {
    size(600,600);
    ArrayList<Float> links = new ArrayList<Float>();
    links.add(104.0);
    links.add(123.0);
    links.add(110.0);
    l = new Limb(new PVector(width/2, height), links);
    for(int i=0; i < links.size(); i++) {
        Joint j = l.segments.get(i).joint;
        j._aMin = -85;
        j._aMax = 85;
    }
}

void draw(){
  background(240);
  l.target = new PVector(mouseX, mouseY);
  l.update();
  l.display();
}
