class Alien {
  // Member Variables
  int x, y, size, health, hitPoints, speed;
  color c1, c2;
  Gif a1;
  boolean isBoss;
  int xSpeed;
  int lastShotTime;
  int shootInterval;

  // Constructor
  Alien(PApplet p, int x, int y) {
    this(p, x, y, false);
  }

  Alien(PApplet p, int x, int y, boolean isBoss) {
    this.x = x;
    this.y = y;
    this.isBoss = isBoss;

    if (isBoss) {
      size = 130;
      health = 500;
      hitPoints = 500;
      speed = 1;
      xSpeed = 2;
      a1 = new Gif(p, "alienboss.gif");
      a1.play();
      shootInterval = 1200;
      lastShotTime = millis();
    } else {
      size = int(random(20, 100));
      health = 100;
      hitPoints = 100;
      speed = int(random(1, 8));
      xSpeed = 0;
      c1 = color(#A7ADA8);
      c2 = color(#A7ADFF);
      a1 = new Gif(p, "alien.gif");
      a1.play();
    }
  }

  // Member Methods
  void display() {
    if (!isBoss) {
      if (health > 50) {
        tint(c2);
      } else {
        tint(c1);
      }
    }
    imageMode(CENTER);
    image(a1, x, y, size, size);

    if (!isBoss) {
      noTint();
    } else {
      rectMode(CORNER);
      fill(100, 0, 0);
      rect(x - 50, y - size/2 - 15, 100, 8);
      fill(255, 0, 0);
      float hpWidth = map(constrain(health, 0, hitPoints), 0, hitPoints, 0, 100);
      rect(x - 50, y - size/2 - 15, hpWidth, 8);
    }
  }

  void move() {
    if (isBoss) {
      x += xSpeed;
      if (x - size/2 < 10 || x + size/2 > width - 10) {
        xSpeed = -xSpeed;
      }
      if (y < 120) {
        y += speed;
      }
    } else {
      y = y + speed;
    }
  }

  boolean isOffScreen() {
    return (y > height + 50);
  }

  boolean isHit(Cow c) {
    float d = dist(x, y, c.x, c.y);
    if (d < size) {
      return true;
    } else {
      return false;
    }
  }

  boolean shouldShoot() {
    if (isBoss && millis() - lastShotTime > shootInterval) {
      lastShotTime = millis();
      return true;
    }
    return false;
  }
}
