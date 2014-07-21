/**
 *  9 to 5
 *
 *  by Adityo Pratomo
 *
 *  Using Leap Motion Screen Tap Gesture to draw on screen
 */

import fisica.*;

import com.leapmotion.leap.Gesture.State;
import com.leapmotion.leap.Gesture.Type;
import com.leapmotion.leap.Hand;
import com.leapmotion.leap.Finger;
import com.leapmotion.leap.ScreenTapGesture;
import com.onformative.leap.LeapMotionP5;

LeapMotionP5 leap;

FWorld world;
FBox pala;
FPoly p;
FPoly poly;

Timer timer;

PFont f;
int cont;
int ballCount;
int initBallCount = 50;
int newBallCount;
int backgroundColor;
int palaX;
int bodyCount;

void setup() {
  size(1280, 800);
  smooth();

  Fisica.init(this);

  world = new FWorld();
  //world.setEdges();
  world.setEdges (0, 0, width, height, 255);
  world.remove(world.bottom);

  // catcher
  pala = new FBox(150, 60);
  pala.setPosition(width/2, height - 40);
  pala.setStatic(true);
  pala.setFill(72, 150, 150);
  pala.setRestitution(0);
  pala.setNoStroke();
  world.add(pala);

  f = createFont("Avenir-Light", 24);
  textFont(f);
  textAlign(CENTER, CENTER);

  newBallCount = initBallCount;
  backgroundColor = 150;
  ballCount = 0;

  bodyCount = 9;

  palaX = width/2;

  leap = new LeapMotionP5(this);
  leap.enableGesture(Type.TYPE_SCREEN_TAP);

  timer = new Timer(50);
}

void draw() {
  background(250, backgroundColor, backgroundColor);

  // p.setPosition(mouseX, mouseY);
  if (backgroundColor > 75) {

    if (backgroundColor == 150) {
      textSize (72);
      text ("9 AM", width/2, height/2);
    }

    else if (backgroundColor == 135) {
      textSize (72);
      text ("11 AM", width/2, height/2);
    }

    else if (backgroundColor == 120) {
      textSize (72);
      text ("1 PM", width/2, height/2);
    }

    else if (backgroundColor == 105) {
      textSize (72);
      text ("3 PM", width/2, height/2);
    }

    else if (backgroundColor == 90) {
      textSize (72);
      text ("4 PM", width/2, height/2);
    }

    // only simulates while the game's on
    world.draw();
    world.step();
    if (frameCount % 40 == 0) {
      FCircle b = new FCircle(random(10, 25));
      b.setPosition(random(0+10, width-10), 50);
      b.setVelocity(0, 200);
      b.setRestitution(0);
      b.setNoStroke();
      //b.setFill(250, 179, 120);
      b.setFill(0, 230, 230);
      world.add(b);
      ballCount++;
    }

    if (ballCount == newBallCount + 1) {
      ballCount = 0;
      backgroundColor -= 15;
      newBallCount = cont;
      //println("ganti");
      //palaX = int(random(0, width));
    }

    poly = new FPoly();
    poly.setNoStroke();
    poly.setFill(139, 227, 139);
    poly.setStatic(true);
    poly.setDensity(10);
    poly.setRestitution(0.5);

    //draw Polygon method 1
    for (com.leapmotion.leap.Frame frame : leap.getFrames(1)) {
      for (Hand hand :  leap.getHandList()) {
        PVector handPos = leap.getPosition(hand);
        float handPitch = leap.getPitch(hand);
        float handRoll = leap.getRoll(hand);
        for (Finger finger : leap.getFingerList()) {
          PVector fingerPos = leap.getTip(finger);
          ellipse(fingerPos.x, fingerPos.y, 10, 10);
          if (leap.getFingerList().size() == 1 || leap.getFingerList().size() == 2) {
            poly.vertex(-90, -20);
            poly.vertex( 90, -20);
            poly.vertex( 90, 40);
            poly.vertex( 40, 60);
          }
          else if (leap.getFingerList().size() == 4 || leap.getFingerList().size() == 3) {
            poly.vertex(-90, -20);
            poly.vertex( 160, -100);
            poly.vertex( 160, -20);
          }
          else if (leap.getFingerList().size() == 5) {
            poly.vertex(-90, -20);
            poly.vertex( 40, -100);
            poly.vertex( 160, -20);
          }
          poly.setPosition(handPos.x, handPos.y);
          poly.setRotation(radians(map(handRoll, 0, 14, 90, 0)));
          //println (handPitch);
        }
      }
      //draw Polygon method 2 
      /*
    for (Finger finger : leap.getFingerList()) {
       PVector fingerPos = leap.getTip(finger);
       ellipse(fingerPos.x, fingerPos.y, 10, 10);
       poly.vertex(fingerPos.x, fingerPos.y);
       } */
    }
  }

  pala.setPosition(palaX, height - 10);

  fill (255);
  textSize (24);
  text("clients: ", 50, 40);
  text(cont, 100, 40);
  text("blocks: ", width-80, 40);
  text(bodyCount, width-30, 40);

  if (poly != null) {
    poly.draw(this);
  }

  fill (255);
  noStroke();
  rect (0, 0, (newBallCount-ballCount)*width/newBallCount, 10);

  if (backgroundColor == 75) {
    world.remove(poly);
    fill(0, 60);
    rect (0, 0, width, height);
    fill (255);
    textSize (72);
    text ("5 PM", width/2, height/2);
    textSize (24);
    text ("That's the end of the day", width/2, height/2 + 60);
    text ("You've won "+ cont + " clients today", width/2, height/2 + 100);
  }
}

void contactStarted(FContact c) {
  FBody ball = null;
  if (c.getBody1() == pala) {
    ball = c.getBody2();
  } 
  else if (c.getBody2() == pala) {
    ball = c.getBody1();
  }

  if (ball == null) {
    return;
  }

  ball.setFill(30, 190, 200);
  world.remove(ball);
  cont++;
}

void mousePressed() {
  if (bodyCount != 0) {
    if (world.getBody(mouseX, mouseY) != null) {
      return;
    }
  }
}

void mouseDragged() {
  if (poly!=null) {
    poly.vertex(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (poly!=null) {
    world.add(poly);
    bodyCount --;
    poly = null;
  }
}

void keyPressed() {
  try {
    saveFrame("screenshot.png");
  } 
  catch (Exception e) {
  }
}

public void screenTapGestureRecognized(ScreenTapGesture gesture) {
  if (gesture.state() == State.STATE_STOP) {
    if (timer.isFinished()) {
      world.add(poly);
      bodyCount --;
      poly = null;
      timer.start();
    }
  } 
  else if (gesture.state() == State.STATE_START) {
    timer.start();
  } 
  else if (gesture.state() == State.STATE_UPDATE) {
  }
}

