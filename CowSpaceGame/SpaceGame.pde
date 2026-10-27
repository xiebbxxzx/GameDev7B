// Joyce Xie | 17 Sept 2026 | SpaceGame
import gifAnimation.*;
import processing.sound.*;

SoundFile lasersound, bgmusic, levelup;
Cow c1;
int score, alienCount, aliensOffScreen, cowHealth;
int damageDealt = 0;
int damageTaken = 0;
int shotsFired = 0;
int shotsHit = 0;
int aliensKilled = 0;
int turretStartTime = 0;
int turretDuration = 5000;
int shieldStartTime = 0;
int shieldDuration = 5000;
int healthNotifStartTime = -2000;
int healthNotifDuration = 2000;
int level = 1;
boolean bossWarning = false;
int warningStartTime = 0;
boolean bossSpawned = false;
boolean play;
boolean twoTurret = false;
boolean isShielded = false;

Timer alit;
Timer powt;

ArrayList<Alien> aliens = new ArrayList<Alien>();
ArrayList<Milk> milks = new ArrayList<Milk>();
ArrayList<PowerUp> powUps = new ArrayList<PowerUp>();
ArrayList<AlienProjectile> enemyProjectiles = new ArrayList<AlienProjectile>();

void setup() {
  size(600, 800);
  bgmusic = new SoundFile(this, "bgmusic.mp3");
  bgmusic.loop();
  bgmusic.amp(0.3);
  c1 = new Cow(this);
  alit = new Timer(2000);
  alit.start();
  powt = new Timer(3000);
  powt.start();
  score = 0;
  alienCount = 0;
  aliensOffScreen = 0;
  play = false;
  lasersound = new SoundFile(this, "lasersound1.mp3");
  levelup = new SoundFile(this, "levelup.mp3");
}

void draw() {
  noCursor();

  if (play == false) {
    startScreen();
  } else {
    background(0);

    // Player control
    c1.display();
    c1.move(mouseX, mouseY);

    // Toned-down blue shield aura
    if (isShielded) {
      fill(0, 150, 255, 40);
      stroke(0, 180, 255, 120);
      strokeWeight(2);
      ellipse(c1.x, c1.y, 75, 75);
      noStroke();
      noFill();
    }

    // Add aliens
    if (alit.isFinished()) {
      alit.start();
      aliens.add(new Alien(this, int(random(width)), -60));
      alienCount++;
    }

    if (bossWarning) {
      fill(255, 0, 0);
      textAlign(CENTER, CENTER);
      textSize(36);
      text("BOSS INCOMING!", width / 2, height / 2 - 50);

      if (millis() - warningStartTime > 2500) {
        bossWarning = false;
        bossSpawned = true;
        aliens.add(new Alien(this, width / 2, -70, true));
        alienCount++;
      }
    }

    // Add power ups
    if (powt.isFinished()) {
      powt.start();
      powUps.add(new PowerUp(this, int(random(width)), -60));
    }

    // Display and move aliens
    for (int i = aliens.size() - 1; i >= 0; i--) {
      Alien a = aliens.get(i);
      a.display();
      a.move();

      if (a.shouldShoot()) {
        enemyProjectiles.add(new AlienProjectile(a.x, a.y + a.size / 2));
      }

      if (a.isHit(c1)) {
        aliens.remove(i);
        if (!isShielded) {
          c1.health -= 10;
          damageTaken += 10;
        }
      } else if (a.isOffScreen()) {
        aliens.remove(i);
        aliensOffScreen++;
      }
    }

    for (int i = enemyProjectiles.size() - 1; i >= 0; i--) {
      AlienProjectile ep = enemyProjectiles.get(i);
      ep.display();
      ep.move();

      if (ep.isHit(c1)) {
        enemyProjectiles.remove(i);
        if (!isShielded) {
          c1.health -= 15;
          damageTaken += 15;
        }
      } else if (ep.isOffScreen()) {
        enemyProjectiles.remove(i);
      }
    }

    // Display and move milk
    for (int i = milks.size() - 1; i >= 0; i--) {
      Milk m = milks.get(i);
      m.display();
      m.move();

      boolean milkHit = false;

      for (int j = aliens.size() - 1; j >= 0; j--) {
        Alien a = aliens.get(j);
        if (m.isHit(a)) {
          milks.remove(i);
          a.health -= 50;
          damageDealt += 50;
          shotsHit++;
          if (a.health <= 0) {
            aliens.remove(j);
            aliensKilled++;
            if (a.isBoss) {
              score += 500;
              level = 2;
              alit = new Timer(800);
              alit.start();
            } else {
              score += 100;
              if (aliensKilled >= 10 && !bossSpawned && !bossWarning && level == 1) {
                bossWarning = true;
                warningStartTime = millis();
              }
            }
          }
          milkHit = true;
          break;
        }
      }

      if (!milkHit && m.isOffScreen()) {
        milks.remove(i);
      }
    }

    // Timer check for turrets
    if (twoTurret && (millis() - turretStartTime > turretDuration)) {
      twoTurret = false;
    }

    // Timer check for shield
    if (isShielded && (millis() - shieldStartTime > shieldDuration)) {
      isShielded = false;
    }

    // Display and move powerups
    for (int i = powUps.size() - 1; i >= 0; i--) {
      PowerUp p = powUps.get(i);
      p.display();
      p.move();

      if (p.isHit(c1)) {
        levelup.play();
        levelup.amp(0.5);

        if (p.type == 'h') {
          c1.health += 10;
          if (c1.health > 100) {
            c1.health = 100;
          }
          healthNotifStartTime = millis();
        } else if (p.type == 't') {
          twoTurret = true;
          turretStartTime = millis();
        } else if (p.type == 's') {
          isShielded = true;
          shieldStartTime = millis();
        }

        powUps.remove(i);
      } else if (p.isOffScreen()) {
        powUps.remove(i);
      }
    }

    // Draw status bar
    infoPanel();

    if (c1.health < 1 || aliensOffScreen > 1) {
      gameOver();
    }
  }
}

void mousePressed() {
  if (c1.health < 1 || aliensOffScreen > 1) {
    if (mouseX > width/2 - 80 && mouseX < width/2 + 80 && mouseY > 475 && mouseY < 525) {
      resetGame();
    }
  } else if (play) {
    int offset = 23;

    milks.add(new Milk(c1.x - offset, c1.y - 30));
    shotsFired++;
    lasersound.play();
    lasersound.amp(0.5);

    if (twoTurret) {
      milks.add(new Milk(c1.x + offset, c1.y - 30));
      shotsFired++;
      lasersound.play();
      lasersound.amp(0.5);
    }
  }
}

void resetGame() {
  score = 0;
  alienCount = 0;
  aliensOffScreen = 0;
  damageDealt = 0;
  damageTaken = 0;
  shotsFired = 0;
  shotsHit = 0;
  aliensKilled = 0;
  level = 1;
  bossWarning = false;
  bossSpawned = false;
  twoTurret = false;
  isShielded = false;
  healthNotifStartTime = -2000;
  c1 = new Cow(this);
  aliens.clear();
  milks.clear();
  powUps.clear();
  enemyProjectiles.clear();
  alit = new Timer(2000);
  alit.start();
  powt.start();
  play = true;
  loop();
}

void infoPanel() {
  fill(0, 180);
  rectMode(CORNER);
  rect(0, 0, width, 30);
  
  fill(200);
  textSize(12);
  textAlign(LEFT, CENTER);
  text("Score: " + score, 10, 15);
  text("Health: " + c1.health, 85, 15);
  text("Lvl: " + level, 160, 15);
  text("Aliens: " + alienCount, 210, 15);
  text("Passed: " + aliensOffScreen, 280, 15);

  int startX = 350;

  // Temporary +10 HP Notification
  if (millis() - healthNotifStartTime < healthNotifDuration) {
    fill(0, 255, 100);
    text("+10 HP!", startX, 15);
    startX += 60;
  }

  // Active status indicators
  if (isShielded) {
    int shieldLeft = ceil((shieldDuration - (millis() - shieldStartTime)) / 1000.0);
    fill(0, 200, 255);
    text("SHIELD (" + shieldLeft + "s)", startX, 15);
    startX += 95;
  }
  if (twoTurret) {
    int turretLeft = ceil((turretDuration - (millis() - turretStartTime)) / 1000.0);
    fill(0, 255, 0);
    text("2-TURRET (" + turretLeft + "s)", startX, 15);
  }
}

void startScreen() {
  background(0);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(30);
  text("Left click to start game", width/2, height/2);
  if (mousePressed) {
    play = true;
  }
}

void gameOver() {
  background(0);
  fill(255);
  textAlign(CENTER);

  float accuracy = 0;
  if (shotsFired > 0) {
    accuracy = ((float)shotsHit / shotsFired) * 100;
  }

  textSize(36);
  text("GAME OVER", width / 2, 180);

  textSize(20);
  int startY = 250;
  int spacing = 35;
  text("Final Score: " + score, width / 2, startY);
  text("Aliens killed: " + aliensKilled, width / 2, startY + spacing);
  text("Damage dealt: " + damageDealt, width / 2, startY + spacing * 2);
  text("Damage taken: " + damageTaken, width / 2, startY + spacing * 3);
  text("Shots fired: " + shotsFired, width / 2, startY + spacing * 4);
  text("Shooting efficiency: " + nf(accuracy, 0, 1) + "%", width / 2, startY + spacing * 5);

  cursor();
  fill(0, 150, 255);
  rectMode(CENTER);
  rect(width / 2, 500, 160, 50, 10);
  fill(255);
  textSize(22);
  text("Restart", width / 2, 507);

  noLoop();
}
