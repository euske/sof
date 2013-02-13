package SOF {

import flash.geom.Point;
import flash.geom.Rectangle;
import SOF.PlanEntry;

//  PlanMap
// 
public class PlanMap
{
  public var blocksize:int;
  public var center:Point;
  public var x0:int, y0:int, x1:int, y1:int;
  private var a:Array;

  public function PlanMap(blocksize:int, center:Point, width:int, height:int)
  {
    this.blocksize = blocksize;
    this.center = center;
    this.x0 = Math.floor((center.x-width)/blocksize);
    this.y0 = Math.floor((center.y-height)/blocksize);
    this.x1 = Math.floor((center.x+width+blocksize-1)/blocksize);
    this.y1 = Math.floor((center.y+height+blocksize-1)/blocksize);
    this.a = new Array(y1-y0+1);
    var w:int = (x1-x0+1);
    var m:int = (width+height+1)*2;
    for (var y:int = y0; y <= y1; y++) {
      var b:Array = new Array(w);
      for (var x:int = x0; x <= x1; x++) {
	b[x-x0] = new PlanEntry(x, y, 0, m, null);
      }
      a[y-y0] = b;
    }
  }

  public function getBlockCoords(p:Point):Point
  {
    return new Point(Math.floor(p.x/blocksize), 
		     Math.floor(p.y/blocksize));
  }

  public function getBlockRect(x:int, y:int):Rectangle
  {
    return new Rectangle(x*blocksize, y*blocksize, blocksize, blocksize);
  }

  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < x0 || x1 < x || y < y0 || y1 < y) return null;
    return a[y-y0][x-x0];
  }
}

}
