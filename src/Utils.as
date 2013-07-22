package {

import flash.geom.Point;
import flash.geom.Rectangle;


//  Utility Functions
// 
public class Utils
{
  public static function collideRectX(p:Point, r:Rectangle, v:Point):Point
  {
    var dx:int, dy:int;
    if (p.x <= r.left && r.left < p.x+v.x) {
      dx = r.left - p.x;
      dy = v.y*dx / v.x;
      if (r.top <= p.y+dy && p.y+dy <= r.bottom) {
	return new Point(dx, dy);
      }
    } else if (r.right <= p.x && p.x+v.x < r.right) {
      dx = r.right - p.x;
      dy = v.y*dx / v.x;
      if (r.top <= p.y+dy && p.y+dy <= r.bottom) {
	return new Point(dx, dy);
      }
    }
    return v;
  }

  public static function collideRectY(p:Point, r:Rectangle, v:Point):Point
  {
    var dx:int, dy:int;
    if (p.y <= r.top && r.top < p.y+v.y) {
      dy = r.top - p.y;
      dx = v.x*dy / v.y;
      if (r.left <= p.x+dx && p.x+dx <= r.right) {
	return new Point(dx, dy);
      }
    } else if (r.bottom <= p.y && p.y+v.y < r.bottom) {
      dy = r.bottom - p.y;
      dx = v.x*dy / v.y;
      if (r.left <= p.x+dx && p.x+dx <= r.right) {
	return new Point(dx, dy);
      }
    }
    return v;
  }

  public static function collideRect(r0:Rectangle, r1:Rectangle, v:Point):Point
  {
    if (v.x < 0) {
      v = collideRectX(new Point(r0.left, r0.top), r1, v);
      v = collideRectX(new Point(r0.left, r0.bottom), r1, v);
    } else {
      v = collideRectX(new Point(r0.right, r0.top), r1, v);
      v = collideRectX(new Point(r0.right, r0.bottom), r1, v);
    }
    if (v.y < 0) {
      v = collideRectY(new Point(r0.left, r0.top), r1, v);
      v = collideRectY(new Point(r0.right, r0.top), r1, v);      
    } else {
      v = collideRectY(new Point(r0.left, r0.bottom), r1, v);
      v = collideRectY(new Point(r0.right, r0.bottom), r1, v);
    }
    return v;
  }
}

} // package
