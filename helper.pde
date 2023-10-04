void applyGravity( Circle ball) {
    ball.vel.add(new Vec2(0, 9.81));
}

void moveBall( Circle ball, float dt) {
    ball.pos.add(ball.vel.times(dt));
}
void handleBallWallCollision( Circle ball) {
    
    if (ball.pos.x < ball.r + 10){
        ball.pos.x = ball.r + 10;
        ball.vel.x *= -cor;
    }
    if (ball.pos.x > width - ball.r - 10){
        ball.pos.x = width - ball.r - 10;
        ball.vel.x *= -cor;
    }
    if (ball.pos.y < ball.r + 10){
        ball.pos.y = ball.r + 10;
        ball.vel.y *= -cor;
    }
    if (ball.pos.y > height - ball.r - 10){
        ball.lost = true;
        ballsLost++;

        if (ballsLost == totalBalls){

            win.play();
        }
    }
}


void handleBallBallCollision(Circle ball1, Circle ball2) {
    // Ball-Ball Collision
    Vec2 delta = ball1.pos.minus(ball2.pos);
    float dist = delta.length();
    if (dist < ball1.r + ball2.r) {
        // Move balls out of collision
        float overlap = 0.5f * (dist - ball1.r - ball2.r);
        ball1.pos.subtract(delta.normalized().times(overlap));
        ball2.pos.add(delta.normalized().times(overlap));

        // Collision response
        Vec2 dir = delta.normalized();
        float v1 = dot(ball1.vel, dir);
        float v2 = dot(ball2.vel, dir);
        float m1 = ball1.mass;
        float m2 = ball2.mass;
        float nv1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * cor) / (m1 + m2);
        float nv2 = (m1 * v1 + m2 * v2 + m1 * (v2 - v1) * cor) / (m1 + m2); // Changed the minus to plus here
        ball1.vel = ball1.vel.plus(dir.times(nv1 - v1));
        ball2.vel = ball2.vel.plus(dir.times(nv2 - v2));
    }
}
 // Ball-Circle Collision
int handleBallCircleCollision(Circle ball, Circle[] circles) {
    for (int j = 0; j < circles.length; j++) {
        Circle circle = circles[j];
        Vec2 delta = ball.pos.minus(circle.pos);
        float dist = delta.length();
        if (dist < ball.r + circle.r) {
            // Move out of collision
            float overlap = 0.5f * (dist - ball.r - circle.r);
            ball.pos.subtract(delta.normalized().times(overlap));
            
            // Collision response
            Vec2 dir = delta.normalized();
            float v1 = dot(ball.vel, dir);
            float v2 = 0.0f; // Assuming circle doesn't move
            float m1 = ball.mass;
            float m2 = circle.mass;
            float nv1 = (m1 * v1 - m1 * v1 * cor) / (m1 + m2); // Simplified since v2 is 0
            ball.vel = ball.vel.plus(dir.times(nv1 - v1));

            return j; // return index of the collided circle
        }
    }
    return -1; // no collision
}

// Ball-Line Collision
void handleBallLineCollision(Circle ball, Line line) {
    Vec2 delta = ball.pos.minus(ball.closestPoint(line));
    float dist = delta.length();
    if (ball.isColliding(line)) {
        // Move out of collision
        float overlap = (dist - ball.r);
        ball.pos.subtract(delta.normalized().times(overlap));

        // Collision
        Vec2 dir = delta.normalized();
        float v1 = dot(ball.vel, dir);
        float v2 = 0.0f; // The obstacle never has a velocity
        float m1 = ball.mass;
        float m2 = 100000.0f; // The mass shouldn't matter?
        float nv1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * cor) / (m1 + m2);
        ball.vel = ball.vel.plus(dir.times(nv1 - v1));
    }
}

void handleBallBoxCollision(Circle ball, Box box) {
    Vec2 delta = ball.pos.minus(box.pos);
    float dist = delta.length();
    if (ball.isColliding(box)) {
        interfaces.play();
        // Move out of collision
        float overlap = (dist - ball.r - (box.pos.distanceTo(ball.closestPoint(box))));
        ball.pos.subtract(delta.normalized().times(overlap));
        score += 100;

        // Collision
        Vec2 dir = delta.normalized();
        float v1 = dot(ball.vel, dir);
        float v2 = 0.0f; // The obstacle never has a velocity
        float m1 = ball.mass;
        float m2 = 100000.0f; // The mass shouldn't matter?
        float nv1 = (m1 * v1 + m2 * v2 - m2 * (v1 - v2) * cor) / (m1 + m2);
        ball.vel = ball.vel.plus(dir.times(nv1 - v1));
    }
}


void handleBallFlipperCollision(Circle ball, Flipper flipper) {
    Vec2 delta = ball.pos.minus(ball.closestPoint(flipper));
    float dist = delta.length();
    if (ball.isColliding(flipper)){
        float overlap = (dist - ball.r);
        ball.pos = delta.normalized().times(ball.r).plus(ball.closestPoint(flipper));

        // Collision
        Vec2 dir = delta.normalized();
        float v1 = dot(ball.vel, dir);
        // Flipper velocity
        Vec2 radius = flipper.l1.minus(ball.closestPoint(flipper));
        Vec2 surfaceVel = new Vec2(-1*radius.y, radius.x).times(flipper.angularSpeed);
        float v2 = dot(surfaceVel, dir);

        // Reflective response with influence of the flipper's movement
        Vec2 relativeVel = ball.vel.minus(surfaceVel);
        Vec2 reflection = relativeVel.minus(dir.times(2 * dot(relativeVel, dir)));

        // Assign new velocity to ball
        ball.vel = reflection;

        // increase ball speed after collision (e.g., energy transfer)
        ball.vel = reflection.times(1.1);
    }
}



void displayGameStats(float box2X, float box2Y, float box2Width) {
    // Game info container color: Electric blue
    fill(45, 130, 245);
    stroke(85, 170, 255);
    rect(box2X, box2Y, box2Width, 450, 28);

    // Text properties for the game info container
    float padding = 20;
    float textGap = 10;
    float titleSize = 45;
    float scoreSize = 30;
    float titlePadding = 20;

    // Text color: Soft white
    fill(235, 245, 255);
    textSize(titleSize);
    textAlign(LEFT, TOP);
    text("PINBALL 5611", box2X + 20, box2Y + 20);
    padding += titleSize + titlePadding;
    textSize(scoreSize);

    if (ballsLost < totalBalls) {
        text("SCORE: ", box2X + 20, box2Y + padding + 20);
        text(str(score), box2X + 20 + textWidth("SCORE: ") + textGap, box2Y + padding + 20);
    } else {
        textAlign(CENTER, TOP);
        text("FINAL SCORE: " + str(score), box2X + box2Width/2, box2Y + padding + titleSize + titlePadding);
    }
}



void drawBorders() {
    // Borders: White
    stroke(55, 55, 55);
    strokeWeight(5);

    rect(400, 100, 500, 800, 28);

    // draw borders
    strokeWeight(5);
    stroke(0,0,0);
    Line[] walls = {
        new Line(rectX + 10, rectY + 10, rectX + 10, rectY + rectHeight - 100), 
        new Line (rectX + 10, rectY + rectHeight - 100, rectX + 10 + 150,  rectY + rectHeight - 50 ), // fliper left
        new Line(rectX + 10, rectY + 10, rectX + rectWidth - 10, rectY + 10), 
        new Line(rectX + rectWidth - 10, rectY + 10, rectX + rectWidth - 10, rectY + rectHeight - 10), // the outer line on the shoting side
        new Line(rectX + rectWidth - 50, rectY + 60, rectX + rectWidth - 50, rectY + rectHeight - 10), // the inner line on the shoting side
        new Line(rectX + rectWidth - 50, rectY + rectHeight - 100 ,rectX + rectWidth - 10 - 150 ,  rectY + rectHeight - 50) // the one attached to the flipers right
    };

     
	// draw the walls
    for (int i = 0; i < walls.length; i++) {
        line(walls[i].l1.x, walls[i].l1.y, walls[i].l2.x, walls[i].l2.y);
    }

}



void drawCircles() {
    noStroke();
    for (int i = 0; i < CircleShapes.length; i++) {
        Circle c = CircleShapes[i];
        fill(i == currentObjectiveIndex ? color(165 + (objectivesHit * 30), 242, 120 - (objectivesHit * 40)) : color(65, 74, 76));
        ellipse(c.pos.x, c.pos.y, c.r * 2, c.r * 2);
    }
}

void drawLines() {
    stroke(0, 0, 0);
    for (int i = 0; i < totalNumberLines; i++) {
        line(LineShapes[i].l1.x, LineShapes[i].l1.y, LineShapes[i].l2.x, LineShapes[i].l2.y);
    }
}

void drawBalls() {
    fill(190, 20, 255);
    stroke(210, 40, 255);
    for (int i = 0; i < totalBalls; i++) {
        ellipse(balls[i].pos.x, balls[i].pos.y, balls[i].r * 2, balls[i].r * 2);
    }
}

void drawBoxes() {
    fill(20, 210, 230);
    rectMode(CENTER);
    for (int i = 0; i < totalNumberBoxes; i++) {
        rect(BoxShapes[i].pos.x, BoxShapes[i].pos.y, BoxShapes[i].w, BoxShapes[i].h);
    }
    rectMode(CORNER);
}
