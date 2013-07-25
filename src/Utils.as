package {

import flash.geom.Point;
import flash.geom.Rectangle;


//  Utility Functions
// 
public class Utils
{
  public static function collideHLine(x0:int, x1:int, y:int, r:Rectangle, v:Point):Point
  {
    var dx:int, dy:int;
    if (y <= r.top && r.top < y+v.y) {
      dy = r.top - y;
      dx = Math.floor(v.x*dy / v.y);
      if (!(x1+dx <= r.left || r.right <= x0+dx)) {
	return new Point(dx, dy);
      }
    } else if (y <= r.bottom && r.bottom < y+v.y) {
      dy = r.bottom - y;
      dx = Math.floor(v.x*dy / v.y);
      if (!(x1+dx <= r.left || r.right <= x0+dx)) {
	return new Point(dx, dy);
      }
    }
    return v;
  }

  public static function collideVLine(y0:int, y1:int, x:int, r:Rectangle, v:Point):Point
  {
    var dx:int, dy:int;
    if (x <= r.left && r.left < x+v.x) {
      dx = r.left - x;
      dy = Math.floor(v.y*dx / v.x);
      if (!(y1+dy <= r.top || r.bottom <= y0+dy)) {
	return new Point(dx, dy);
      }
    } else if (x <= r.right && r.right < x+v.x) {
      dx = r.right - x;
      dy = Math.floor(v.y*dx / v.x);
      if (!(y1+dy <= r.top || r.bottom <= y0+dy)) {
	return new Point(dx, dy);
      }
    }
    return v;
  }

  public static function collideRect(r0:Rectangle, r1:Rectangle, v:Point):Point
  {
    if (v.x < 0) {
      v = collideVLine(r0.top, r0.bottom, r0.left, r1, v);
    } else {
      v = collideVLine(r0.top, r0.bottom, r0.right, r1, v);
    }
    if (v.y < 0) {
      v = collideHLine(r0.left, r0.right, r0.top, r1, v);
    } else {
      v = collideHLine(r0.left, r0.right, r0.bottom, r1, v);
    }
    return v;
  }
}

} // package
