class AlienProjectile {
  int x, y, w, h, speed;

  AlienProjectile(int x, int y) {
    this.x = x;
    this.y = y;
    w = 8;
    h = 20;
    speed = 6;
  }

  void display() {
    fill(255, 50, 50);
    noStroke();
    rectMode(CENTER);
    rect(x, y, w, h, 4);
  }

  void move() {
    y += speed;
  }

  boolean isOffScreen() {
    return (y > height + 20);
  }

  boolean isHit(Cow c) {
    float d = dist(x, y, c.x, c.y);
    return (d < 30);
  }
}
