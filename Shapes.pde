public class Box {
    public Vec2 pos;
    public float h, w;

    public Box(float x, float y, float w, float h) {
        pos = new Vec2(x, y);
        this.w = w;
        this.h = h;
    }

    public boolean isColliding(Vec2 point) {
        return point.x >= this.pos.x - this.w/2 && point.x <= this.pos.x + this.w/2 
            && point.y >= this.pos.y - this.h/2 && point.y <= this.pos.y + this.h/2;
    }
}


public class Circle {
    public Vec2 pos;
    public float r;
    public float mass;
    public Vec2 vel;
    public boolean lost = false;

    public Circle(Vec2 pos, float r, float mass, Vec2 vel) {
        this.pos = pos;
        this.r = r;
        this.mass = mass;
        this.vel = vel;
    }

    public boolean isColliding(Circle other) {
        return this.pos.distanceTo(other.pos) < this.r + other.r;
    }

    public boolean isColliding(Line line) {
        Vec2 closestPoint = this.closestPoint(line);
        return this.pos.distanceTo(closestPoint) < this.r;
    }

  public Vec2 closestPoint(Line line) {
      Vec2 diff = line.l2.minus(line.l1);
      float lenSquared = diff.length() * diff.length();
  
      if (lenSquared == 0) return line.l1; // The line is a point.
  
      float t = Math.max(0, Math.min(1, this.pos.minus(line.l1).dot(diff) / lenSquared));
      Vec2 projection = line.l1.plus(diff.times(t));
  
      return projection;
  }

    public boolean isColliding(Box box) {
        if (box.isColliding(this.pos)) return true;

        Line[] boxLines = {
            new Line(box.pos.x - box.w/2, box.pos.y + box.h/2, box.pos.x + box.w/2, box.pos.y + box.h/2),
            new Line(box.pos.x - box.w/2, box.pos.y - box.h/2, box.pos.x + box.w/2, box.pos.y - box.h/2),
            new Line(box.pos.x - box.w/2, box.pos.y + box.h/2, box.pos.x - box.w/2, box.pos.y - box.h/2),
            new Line(box.pos.x + box.w/2, box.pos.y + box.h/2, box.pos.x + box.w/2, box.pos.y - box.h/2)
        };

        for (Line line : boxLines) {
            if (this.isColliding(line)) return true;
        }

        return false;
    }

    public Vec2 closestPoint(Box box) {
        return new Vec2(
            constrain(this.pos.x, box.pos.x - box.w/2, box.pos.x + box.w/2),
            constrain(this.pos.y, box.pos.y - box.h/2, box.pos.y + box.h/2)
        );
    }
}

public class Line {
    public Vec2 l1, l2;
    
    public Line(float x1, float y1, float x2, float y2) {
        this.l1 = new Vec2(x1, y1);
        this.l2 = new Vec2(x2, y2);
    }
    
    public boolean sameSide(Line other) {
        float cp1 = cross(this.l2.minus(this.l1), other.l1.minus(this.l1));
        float cp2 = cross(this.l2.minus(this.l1), other.l2.minus(this.l1));
        return cp1 * cp2 >= 0;
    }

    public boolean isColliding(Vec2 point) {
        return Math.abs(this.l1.distanceTo(point) + this.l2.distanceTo(point) - this.l1.distanceTo(this.l2)) < 0.1;
    }

    public boolean isColliding(Line other) {
        return !this.sameSide(other) && !other.sameSide(this);
    }

    public boolean isColliding(Box box) {
        Line[] boxLines = {
            new Line(box.pos.x - box.w/2, box.pos.y + box.h/2, box.pos.x + box.w/2, box.pos.y + box.h/2),
            new Line(box.pos.x - box.w/2, box.pos.y - box.h/2, box.pos.x + box.w/2, box.pos.y - box.h/2),
            new Line(box.pos.x - box.w/2, box.pos.y + box.h/2, box.pos.x - box.w/2, box.pos.y - box.h/2),
            new Line(box.pos.x + box.w/2, box.pos.y + box.h/2, box.pos.x + box.w/2, box.pos.y - box.h/2)
        };

        for (Line line : boxLines) {
            if (this.isColliding(line)) return true;
        }

        return box.isColliding(l1) || box.isColliding(l2);
    }
}



public class Flipper extends Line {
    public float angularSpeed;

    public Flipper(float x1, float y1, float x2, float y2) {
        super(x1, y1, x2, y2);
        this.angularSpeed = 0;
    }
}

//public class Flipper extends Line {
//    public float angularSpeed;
//    public Vec2 startPos, endPos;

//    public Flipper(float x1, float y1, float x2, float y2) {
//        super(x1, y1, x2, y2);
//        this.angularSpeed = 0;
//        this.startPos = l1; // Linking the inherited l1 to the startPos
//        this.endPos = l2;   // Linking the inherited l2 to the endPos
//    }
//    public void set(float x1, float y1, float x2, float y2) {
//        this.l1 = new Vec2(x1, y1);
//        this.l2 = new Vec2(x2, y2);
//        this.startPos = l1;
//        this.endPos = l2;
//    }
//}
