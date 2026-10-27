class Milk {
  // Member Variables
  int x, y, w, h, speed;
  PImage milk;

  //Constructor
  Milk(int x, int y) {
    this.x = x;
    this.y = y;
    w = 20;
    h = 20;
    speed = 5;
    milk = loadImage("milk.png");
  }
  // Member Methods
  void display() {
    fill(0, 255, 255);
    imageMode(CENTER);
    image(milk, x, y);
  }

  void move() {
    y = y - speed;
  }

  boolean isOffScreen() {
    if (y<-15) {
      return true;
    } else {
      return false;
    }
  }

  boolean isHit(Alien a) {
    float d = dist(x, y, a.x, a.y);
    if (d<40) {
      return true;
    } else {
      return false;
    }
  }
}
