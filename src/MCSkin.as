package {

import flash.display.Shape;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import Shape3D;

//  MCSkin
//  Draw a Minecraft skin centered at (0,0)
// 
public class MCSkin extends Shape3D
{
  public const N:int = 8, M:int = 1;
  public const bounds:Rectangle = new Rectangle(-16, -32*2-16, 32*1, 32*4);
  public const tilebounds:Rectangle = new Rectangle(0, -2, 0, 3);

  // setPhase(r)
  public function setPhase(r:Number):void
  {
    p0 = Math.cos(r);
    q0 = Math.sin(r);
    p1 = p0;
    q1 = -q0;
  }

  // setDirection(vx, vz)
  public function setDirection(vx:int, vz:int):void
  {
    this.vx = vx;
    this.vz = vz;
  }

  public var vx:int = 1, vz:int = 0;
  
  private var p0:Number = 1.0;
  private var q0:Number = 0.0;
  private var p1:Number = 1.0;
  private var q1:Number = 0.0;

  // repaint()
  public function repaint():void
  {
    // Skin format: http://www.minecraftwiki.net/wiki/File:Skinzones.png
    graphics.clear();

    if (vz == 0) {
      // L-arm
      if (0 < vx) {
	quad(new Rectangle(44, 20, 4, 12), // front
	     p3d(+N*p0,-N*6-N*q0,N*3), p3d(0,0,N*2), p3d(N*6*q0,N*6*p0,0));    
	quad(new Rectangle(40, 20, 4, 12), // right
	     p3d(-N*p0,-N*6+N*q0,N*3), p3d(N*2*p0,-N*2*q0,0), p3d(N*6*q0,N*6*p0,0));    
      } else {
	quad(new Rectangle(52, 20, 4, 12), // back
	     p3d(+N*p0,-N*6+N*q0,N*3), p3d(0,0,N*2), p3d(-N*6*q0,N*6*p0,0));    
	quad(new Rectangle(48, 20, 4, 12), // left
	     p3d(-N*p0,-N*6-N*q0,N*3), p3d(N*2*p0,+N*2*q0,0), p3d(-N*6*q0,N*6*p0,0));    
      }
      // L-leg
      if (0 < vx) {
	quad(new Rectangle(4, 20, 4, 12), // front
	     p3d(+N*p1,-N*q1,+N), p3d(0,0,N*2), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(0, 20, 4, 12), // right
	     p3d(-N*p1,+N*q1,+N), p3d(N*2*p1,-N*2*q1,0), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p1,+N*q1,+N), p3d(0,0,N*2), p3d(N*2*p1,-N*2*q1,0));
      } else {
	quad(new Rectangle(12, 20, 4, 12), // back
	     p3d(+N*p1,+N*q1,+N), p3d(0,0,N*2), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(8, 20, 4, 12), // left
	     p3d(-N*p1,-N*q1,+N), p3d(N*2*p1,N*2*q1,0), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p1,-N*q1,+N), p3d(0,0,N*2), p3d(N*2*p1,+N*2*q1,0));
      }
      // R-leg
      if (0 < vx) {
	quad(new Rectangle(4, 20, 4, 12), // front
	     p3d(+N*p0,-N*q0,-N), p3d(0,0,N*2), p3d(N*6*q0,N*6*p0,0));    
	quad(new Rectangle(0, 20, 4, 12), // right
	     p3d(-N*p0,+N*q0,-N), p3d(N*2*p0,-N*2*q0,0), p3d(N*6*q0,N*6*p0,0));
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p0,+N*q0,-N), p3d(0,0,N*2), p3d(N*2*p0,-N*2*q0,0));
      } else {
	quad(new Rectangle(12, 20, 4, 12), // back
	     p3d(+N*p0,+N*q0,-N), p3d(0,0,N*2), p3d(-N*6*q0,N*6*p0,0));    
	quad(new Rectangle(8, 20, 4, 12), // left
	     p3d(-N*p0,-N*q0,-N), p3d(N*2*p0,N*2*q0,0), p3d(-N*6*q0,N*6*p0,0));    
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p0,-N*q0,-N), p3d(0,0,N*2), p3d(N*2*p0,+N*2*q0,0));
      }
      // body
      if (0 < vx) {
	quad(new Rectangle(20, 20, 8, 12), // front
	     p3d(+N,-N*6,-N), p3d(0,0,N*4), p3d(0,N*6,0));
	quad(new Rectangle(16, 20, 4, 12), // right
	     p3d(-N,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));
      } else {
	quad(new Rectangle(32, 20, 8, 12), // back
	     p3d(+N,-N*6,-N), p3d(0,0,N*4), p3d(0,N*6,0));
	quad(new Rectangle(28, 20, 4, 12), // left
	     p3d(-N,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));
      }

      // head
      if (0 < vx) {
	quad(new Rectangle(8, 8, 8, 8), // front
	     p3d(+N*2,-N*10,-N), p3d(0,0,N*4), p3d(0,N*4,0));
	quad(new Rectangle(0, 8, 8, 8), // right
	     p3d(-N*2,-N*10,-N), p3d(N*4,0,0), p3d(0,N*4,0));
	quad(new Rectangle(8, 0, 8, 8), // top
	     p3d(-N*2,-N*10,-N), p3d(0,0,N*4), p3d(N*4,0,0));
      } else {
	quad(new Rectangle(24, 8, 8, 8), // back
	     p3d(+N*2,-N*10,-N), p3d(0,0,N*4), p3d(0,N*4,0));
	quad(new Rectangle(16, 8, 8, 8), // left
	     p3d(-N*2,-N*10,-N), p3d(N*4,0,0), p3d(0,N*4,0));
	quad(new Rectangle(8, 0, 8, 8), // top
	     p3d(+N*2,-N*10,-N), p3d(0,0,N*4), p3d(-N*4,0,0));
      }
      // mask
      if (0 < vx) {
	quad(new Rectangle(40, 8, 8, 8), // front
	     p3d(+N*2+M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
	quad(new Rectangle(32, 8, 8, 8), // right
	     p3d(-N*2-M,-N*10-M,-N-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
	quad(new Rectangle(40, 0, 8, 8), // top
	     p3d(-N*2-M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(N*4+M*2,0,0));
      } else {
	quad(new Rectangle(56, 8, 8, 8), // back
	     p3d(+N*2+M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
	quad(new Rectangle(48, 8, 8, 8), // left
	     p3d(-N*2-M,-N*10-M,-N-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
	quad(new Rectangle(40, 0, 8, 8), // top
	     p3d(+N*2+M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(-N*4-M*2,0,0));
      }
      // R-arm
      if (0 < vx) {
	quad(new Rectangle(44, 20, 4, 12), // front
	     p3d(+N*p1,-N*6-N*q1,-N*3), p3d(0,0,N*2), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(40, 20, 4, 12), // right
	     p3d(-N*p1,-N*6+N*q1,-N*3), p3d(N*2*p1,-N*2*q1,0), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(44, 16, 4, 4), // top
	     p3d(-N*p1,-N*6+N*q1,-N*3), p3d(0,0,N*2), p3d(N*2*p1,-N*2*q1,0));
      } else {
	quad(new Rectangle(52, 20, 4, 12), // back
	     p3d(+N*p1,-N*6+N*q1,-N*3), p3d(0,0,N*2), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(48, 20, 4, 12), // left
	     p3d(-N*p1,-N*6-N*q1,-N*3), p3d(N*2*p1,+N*2*q1,0), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(44, 16, 4, 4), // top
	     p3d(-N*p1,-N*6-N*q1,-N*3), p3d(0,0,N*2), p3d(N*2*p1,N*2*q1,0));
      }
    } else if (0 < vz) {
      // R-leg
      quad(new Rectangle(4, 20, 4, 12), // front
	   p3d(-N*2,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      // L-leg
      quad(new Rectangle(4, 20, 4, 12), // front
	   p3d(0,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(8, 20, 4, 12), // right
	   p3d(+N*2,0,-N), p3d(0,0,N*2), p3d(0,N*6,0));
      // R-arm
      quad(new Rectangle(44, 20, 4, 12), // front
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));
      // body
      quad(new Rectangle(20, 20, 8, 12), // front
	   p3d(-N*2,-N*6,-N), p3d(N*4,0,0), p3d(0,N*6,0));
      // L-arm
      quad(new Rectangle(44, 20, 4, 12), // front
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    	   
      quad(new Rectangle(48, 20, 4, 12), // right
	   p3d(+N*4,-N*6,-N), p3d(0,0,N*2), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));
      // head
      quad(new Rectangle(8, 8, 8, 8), // front
	   p3d(-N*2,-N*10,-N*2), p3d(N*4,0,0), p3d(0,N*4,0));
      quad(new Rectangle(16, 8, 8, 8), // right
	   p3d(+N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(0,N*4,0));
      quad(new Rectangle(8, 0, 8, 8), // top
	   p3d(-N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(N*4,0,0));
      // mask
      quad(new Rectangle(40, 8, 8, 8), // front
	   p3d(-N*2-M,-N*10-M,-N*2-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
      quad(new Rectangle(48, 8, 8, 8), // right
	   p3d(+N*2+M,-N*10-M,-N*2-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
      quad(new Rectangle(40, 0, 8, 8), // top
	   p3d(-N*2-M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(N*4+M*2,0,0));
      
    } else if (vz < 0) {
      // L-leg
      quad(new Rectangle(12, 20, 4, 12), // front
	   p3d(-N*2,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      // R-leg
      quad(new Rectangle(12, 20, 4, 12), // front
	   p3d(0,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(0, 20, 4, 12), // right
	   p3d(+N*2,0,-N), p3d(0,0,N*2), p3d(0,N*6,0));
      // L-arm
      quad(new Rectangle(52, 20, 4, 12), // front
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));
      // body
      quad(new Rectangle(32, 20, 8, 12), // front
	   p3d(-N*2,-N*6,-N), p3d(N*4,0,0), p3d(0,N*6,0));
      // R-arm
      quad(new Rectangle(52, 20, 4, 12), // front
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    	   
      quad(new Rectangle(40, 20, 4, 12), // right
	   p3d(+N*4,-N*6,-N), p3d(0,0,N*2), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));      
      // head
      quad(new Rectangle(24, 8, 8, 8), // front
	   p3d(-N*2,-N*10,-N*2), p3d(N*4,0,0), p3d(0,N*4,0));
      quad(new Rectangle(0, 8, 8, 8), // right
	   p3d(+N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(0,N*4,0));
      quad(new Rectangle(8, 0, 8, 8), // top
	   p3d(-N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(N*4,0,0));
      // mask
      quad(new Rectangle(56, 8, 8, 8), // front
	   p3d(-N*2-M,-N*10-M,-N*2-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
      quad(new Rectangle(32, 8, 8, 8), // right
	   p3d(+N*2+M,-N*10-M,-N*2-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
      quad(new Rectangle(40, 0, 8, 8), // top
	   p3d(-N*2-M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(N*4+M*2,0,0));
    }

    graphics.lineStyle(0, 0xff0000);
    graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
}

} // package
