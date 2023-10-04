
// Game settings
int totalBalls = 3, currentBallIndex  = 0, score = 0, ballsLost = 0;


// Game objects and parameters
Circle[] balls = new Circle[totalBalls];
int totalNumberCircle, totalNumberLines, totalNumberBoxes, currentObjectiveIndex, objectivesHit;
Circle[] CircleShapes;
Line[] LineShapes;
Box[] BoxShapes;


float cor = 0.8f; // Coefficient of Restitution

Flipper leftFlipper, rightFipper;
float leftFlipper_rotation = 0.0, rightFipper_rotation = 0.0;

import processing.sound.*;

// Sound objects
Sound volumeControl;
SoundFile interfaces, brink, click, win;




void resetBalls(){
    currentBallIndex = 0;
    score = 0;
    ballsLost = 0;
    currentObjectiveIndex = int(random(0, totalNumberCircle));
    objectivesHit = 0;
    
    float cupWidth = 150;  // As defined earlier
    float gap = 5.1f;      // Gap between balls. Adjust as desired.
    
    float initialX = 250 - cupWidth / 2 + 15 + gap;  // 15 is half the ball's diameter
    float currentX = initialX;
    float currentY = 480 - 15 - gap;  // Adjust based on cup's bottom Y, ball radius, and gap
    int ballsInCurrentRow = 1;
    int ballsInNextRow = 0;
    
    for (int i = 0; i < totalBalls; i++) {
        Vec2 pos = new Vec2(currentX, currentY);
        Vec2 vel = new Vec2(0, 0);
        int rad = 15;
        float mass = ((3.141592653 * (rad * rad))/rad) * ((3.141592653 * (rad * rad))/rad);
        balls[i] = new Circle(pos, rad, mass, vel);
        
        currentX += (rad * 2) + gap;  // Increment x position by diameter and the gap
        ballsInNextRow++;
        
        // If the next ball is outside the cup width, move to the next row
        if (currentX > (250 + cupWidth / 2 - rad - gap)) {
            ballsInCurrentRow++;
            ballsInNextRow = 0;
            currentY -= (rad * 2) + gap;  // Decrement y position by diameter and the gap
            currentX = initialX - (ballsInCurrentRow - 1) * (rad + gap/2);  // Adjust starting position for staggering effect
        }
    }
}


void launchBalls(){
    if (currentBallIndex < totalBalls){
        Vec2 pos = new Vec2(870, 870);
        Vec2 vel = new Vec2(0, random(-1700, -1400));
        int rad = 15;
        float mass = (2);
        balls[currentBallIndex] = new Circle(pos, rad, mass, vel);
        currentBallIndex++;
    }
}

void updatePhysics(float dt) {
    for (int i = 0; i < totalBalls; i++) {
        if (balls[i].lost) continue;

        applyGravity(balls[i]);
        moveBall(balls[i], dt);
        handleBallWallCollision(balls[i]);

        for (int j = i + 1; j < totalBalls; j++) {
            handleBallBallCollision(balls[i], balls[j]);
        }

for (int j = 0; j < balls.length; j++) {
    int collidedIndex = handleBallCircleCollision(balls[j], CircleShapes);

    // Handle sound effects and scoring based on collided circle
    if (collidedIndex != -1) {
        if (collidedIndex == currentObjectiveIndex ) {
            if (objectivesHit < 3) {
                brink.play();
                objectivesHit++;
                score += 25;
            } else {
                interfaces.play();
                objectivesHit = 0;
                score += 250;
            }
            while (collidedIndex == currentObjectiveIndex) {
                currentObjectiveIndex = int(random(0, totalNumberCircle));
            }
        } else {
            click.play();
            score += 50;
        }
    }
}

        for (int j = 0; j < totalNumberLines; j++) {
           handleBallLineCollision(balls[i], LineShapes[j]);
        }

        for (int j = 0; j < totalNumberBoxes; j++) {
            handleBallBoxCollision(balls[i], BoxShapes[j]);
        }

        handleBallFlipperCollision(balls[i], leftFlipper);
        handleBallFlipperCollision(balls[i], rightFipper);
    }
}
boolean leftPressed, rightPressed, upPressed, downPressed, shiftPressed;
void keyPressed(){
  if (keyCode == LEFT) leftPressed = true;
  if (keyCode == RIGHT) rightPressed = true;
  if (keyCode == UP) upPressed = true; 
  if (keyCode == DOWN) downPressed = true;
  if (keyCode == SHIFT) shiftPressed = true;
}

void keyReleased(){
  // reset if 'r' if pressed
  if (key == 'r'){
    resetBalls();
  }
  if (keyCode == LEFT) leftPressed = false;
  if (keyCode == RIGHT) rightPressed = false;
  if (keyCode == UP) launchBalls(); 
  if (keyCode == DOWN) downPressed = false;
  if (keyCode == SHIFT) shiftPressed = false;
}

  float rectX = 400;
    float rectY = 100;
    float rectWidth = 500;
    float rectHeight = 800;

void setup() {
    // Initialize game display
    size(1000, 1000);
    smooth();  
    noStroke();
    resetBalls();
    
    // Initialize volume control for the game
    volumeControl = new Sound(this);
    volumeControl.volume(0.1);

    // Initialize flippers
    leftFlipper = new Flipper(rectX + 160, rectY + rectHeight - 50, rectX + 220, rectY + rectHeight - 70);
    rightFipper = new Flipper(rectX + rectWidth - 160, rectY + rectHeight - 50, rectX + 280, rectY + rectHeight - 70);

    // Load game configurations from file
    String[] lines = loadStrings("postions.txt");
    totalNumberCircle = 8;
    totalNumberLines = 10;
    totalNumberBoxes = 2;


    // Load sound effects
    interfaces = new SoundFile(this, "sounds/interface.mp3");
    click = new SoundFile(this, "sounds/button-29.wav");
    brink = new SoundFile(this, "sounds/Brink.wav");
    win = new SoundFile(this, "sounds/game.mp3");

    // Initialize circle obstacles
    CircleShapes = new Circle[totalNumberCircle + 1];
    float centerX = 650.0f; 
    float centerY = 400.0f; 
    float r = 100.0f; 
    float smallCircleRadius = 10.0f;

    for (int i = 0; i < totalNumberCircle; i++) {
        float theta = 2.0f * (float) Math.PI * i / (float) totalNumberCircle;
        float x = centerX + r * (float) Math.cos(theta);
        float y = centerY + r * (float) Math.sin(theta);
        CircleShapes[i] = new Circle(new Vec2(x, y), smallCircleRadius, 10000.0, new Vec2(0, 0));
    }
    CircleShapes[totalNumberCircle] = new Circle(new Vec2(centerX, centerY), smallCircleRadius, 10000.0, new Vec2(0, 0));


    // Initialize box obstacles
    BoxShapes = new Box[totalNumberBoxes];
    for (int i = totalNumberLines; i < totalNumberLines + totalNumberBoxes; i++) {
        String[] data = lines[i].split(" ");
        BoxShapes[i - totalNumberLines] = new Box(float(data[1]), float(data[2]), float(data[3]), float(data[4]));
    }

    
    // Initialize line obstacles
    LineShapes = new Line[totalNumberLines];
    for (int i = 0; i < totalNumberLines; i++) {
        String[] data = lines[i].split(" ");
        LineShapes[i] = new Line(float(data[1]), float(data[2]), float(data[3]), float(data[4]));
    }


}


void draw() {
    // --- Set Basic Canvas Properties ---
    // A darker, muted background color for contrast
    background(45, 55, 65);
    fill(60, 130, 190);  // Cool blue tone
    stroke(220, 220, 220);  // Off-white stroke for a subtle contrast

    // --- Define Game Stats Container (Second Container) ---
    float box2X = 50;
    float box2Y = 100;
    float box2Width = 300;
    float box2Height = 450;
    rect(box2X, box2Y, box2Width, box2Height, 28);

    // Display Game Stats Inside the Container
    displayGameStats(box2X, box2Y, box2Width);

    // --- Define Game Board (First Container) ---
    fill(30, 40, 50);  // Darker tone for the game board
    rect(400, 100, 500, 800, 28);

    // --- Draw Game Elements ---
    drawBorders();

    drawCircles();
    drawLines();
    drawBalls();
  
    drawBoxes();
    
    
    final float MAX_ROTATE = (80 * PI) / 180;
    final float THICK_STROKE = 5;
    final float NORMAL_STROKE = 1;
    //draw the flippers
    Vec2 l2Bak = new Vec2((rectWidth/2)-30, rectHeight-25);
    Vec2 l1Bak = new Vec2((rectWidth/2)+60, rectHeight-25);

    
    if (leftPressed) {
      leftFlipper.angularSpeed = 8;
      leftFlipper_rotation += leftFlipper.angularSpeed * (1/frameRate);
      //leftFlipper_rotation += ((45*PI)/180)/5; // every dt add this much rotation
      leftFlipper_rotation = min(leftFlipper_rotation, (80*PI)/180);
      Vec2 nL2 = new Vec2((cos(leftFlipper_rotation)*(leftFlipper.l2.x - leftFlipper.l1.x)) + 
                            (sin(leftFlipper_rotation) * (leftFlipper.l2.y - leftFlipper.l1.y)) + leftFlipper.l1.x, 
                            (-1 * sin(leftFlipper_rotation)*(leftFlipper.l2.x - leftFlipper.l1.x)) +
                             (cos(leftFlipper_rotation) * (leftFlipper.l2.y - leftFlipper.l1.y)) + leftFlipper.l1.y);
      l2Bak = leftFlipper.l2;
      leftFlipper.l2 = nL2;
      strokeWeight(5);
      
      line(leftFlipper.l1.x, leftFlipper.l1.y, leftFlipper.l2.x, leftFlipper.l2.y);

      strokeWeight(1);
 
    } else {
   
      leftFlipper = new Flipper(rectX + 10 + 150,  rectY + rectHeight - 50 , rectX + 220,  rectY + rectHeight - 10);
      leftFlipper_rotation = 0.0;
      strokeWeight(5);
      line(leftFlipper.l1.x, leftFlipper.l1.y, leftFlipper.l2.x, leftFlipper.l2.y);
      strokeWeight(1);
    }

    if (rightPressed) {
      rightFipper.angularSpeed = 8;
      rightFipper_rotation += rightFipper.angularSpeed * (1/frameRate);
      rightFipper_rotation = min(rightFipper_rotation, (80*PI)/180);
      Vec2 nL1 = new Vec2((cos(rightFipper_rotation)*(rightFipper.l1.x - rightFipper.l2.x)) + (-1 * sin(rightFipper_rotation) * (rightFipper.l1.y - rightFipper.l2.y)) + rightFipper.l2.x, (sin(rightFipper_rotation)*(rightFipper.l1.x - rightFipper.l2.x)) + (cos(rightFipper_rotation) * (rightFipper.l1.y - rightFipper.l2.y)) + rightFipper.l2.y);
      l1Bak = rightFipper.l1;
      rightFipper.l1 = nL1;
      strokeWeight(5);
      line(rightFipper.l1.x, rightFipper.l1.y, rightFipper.l2.x, rightFipper.l2.y);
      strokeWeight(1);
    } else {
     rightFipper = new Flipper(rectX + 280,  rectY + rectHeight - 10, rectX + rectWidth - 10 - 150 ,  rectY + rectHeight - 50);    
      rightFipper_rotation = 0.0;    
      rightFipper_rotation = 0.0;
      strokeWeight(5);
      line(rightFipper.l1.x, rightFipper.l1.y, rightFipper.l2.x, rightFipper.l2.y);
      strokeWeight(1);
    }

    updatePhysics(1/(frameRate*1.5));
  
        fill(89, 203, 232);
        //stroke(89, 203, 232);
        for (int i = 0; i < totalNumberBoxes; i++){
              rectMode(CENTER);
          rect(BoxShapes[i].pos.x, BoxShapes[i].pos.y, BoxShapes[i].w, BoxShapes[i].h);
        }

    if (leftPressed) {
      leftFlipper.l2 = l2Bak;
    }
    if (rightPressed) {
      rightFipper.l1 = l1Bak;
    }

rectMode(CORNER);
}
