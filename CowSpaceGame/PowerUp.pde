import gifAnimation.*;

class PowerUp {
  int x, y, size, speed;
  char type; // 'h' = health, 't' = turrets, 's' = shield
  Gif s1;

  PowerUp(PApplet p, int x, int y) {
    this.x = x;
    this.y = y;
    size = int(random(30, 50));
    speed = int(random(2, 5));

    float r = random(3);
    if (r < 1) {
      type = 'h';
    } else if (r < 2) {
      type = 't';
    } else {
      type = 's';
    }

    s1 = new Gif(p, "powerupstar.gif");
    if (s1 != null) {
      s1.play();
    }
  }

  void display() {
    imageMode(CENTER);
    if (s1 != null) {
      image(s1, x, y, size, size);
    }
  }

  void move() {
    y = y + speed;
  }

  boolean isOffScreen() {
    return (y > height + 50);
  }

  boolean isHit(Cow c) {
    float d = dist(x, y, c.x, c.y);
    return (d < size / 2 + 20);
  }
}
