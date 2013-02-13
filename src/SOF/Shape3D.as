package SOF {

import flash.display.Shape;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;

//  Shape3D
// 
public class Shape3D extends Shape
{
  // VX:
  public const VX:Number = 0.4;
  // VZ:
  public const VZ:Number = 0.2;

  private var skin:BitmapData;

  // Shape3D(image)
  public function Shape3D(image:BitmapData)
  {
    skin = image;
  }

  // p3d(x,y,z)
  protected function p3d(x:int, y:int, z:int):Point
  {
    // +Z: toward the screen, -Z: toward the user.
    return new Point(x+z*VX, y-z*VZ);
  }

  // quad(r, p, a, b)
  protected function quad(r:Rectangle, p:Point, a:Point, b:Point):void
  {
    var m:Matrix = new Matrix(a.x/r.width, a.y/r.width, 
			      b.x/r.height, b.y/r.height, 
			      p.x-(r.x*a.x/r.width+r.y*b.x/r.height),
			      p.y-(r.x*a.y/r.width+r.y*b.y/r.height));
    graphics.beginBitmapFill(skin, m, false);
    graphics.moveTo(p.x, p.y);
    graphics.lineTo(p.x+a.x, p.y+a.y);
    graphics.lineTo(p.x+a.x+b.x, p.y+a.y+b.y);
    graphics.lineTo(p.x+b.x, p.y+b.y);
    graphics.lineTo(p.x, p.y);
    graphics.endFill();
  }
}

}
