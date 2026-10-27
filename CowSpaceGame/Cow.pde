class Cow {
  // Member Variable
  int x, y, health;
  Gif c1;

  // Constructor
  Cow(PApplet p) {
    x = width/2;
    y = height/2;
    health = 100;
    c1 = new Gif(p, "spacecow.gif");
    c1.play();
  }
  // Member Methods
  void display() {
    imageMode(CENTER);
    image(c1, x, y);
  }

  void move(int tempX, int tempY) {
    x = tempX;
    y = tempY;
  }
}
