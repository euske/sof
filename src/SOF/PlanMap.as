package SOF {

import flash.geom.Point;
import flash.geom.Rectangle;
import SOF.PlanEntry;
import SOF.Tile;
import SOF.TileMap;

//  PlanMap
// 
public class PlanMap
{
  public var tilesize:int;
  public var center:Point;
  public var x0:int, y0:int, x1:int, y1:int;
  private var a:Array;

  public function PlanMap(tilesize:int, center:Point, width:int, height:int)
  {
    this.tilesize = tilesize;
    this.center = center;
    this.x0 = Math.floor((center.x-width)/tilesize);
    this.y0 = Math.floor((center.y-height)/tilesize);
    this.x1 = Math.floor((center.x+width+tilesize-1)/tilesize);
    this.y1 = Math.floor((center.y+height+tilesize-1)/tilesize);
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

  public function getTileCoords(p:Point):Point
  {
    return new Point(Math.floor(p.x/tilesize), Math.floor(p.y/tilesize));
  }

  public function getTileRect(x:int, y:int):Rectangle
  {
    return new Rectangle(x*tilesize, y*tilesize, tilesize, tilesize);
  }

  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < x0 || x1 < x || y < y0 || y1 < y) return null;
    return a[y-y0][x-x0];
  }

  // fillPlan(plan, b)
  public const JUMPLOC:Array = [ new Point(-1,+4), new Point(-1,+3), 
				 new Point(-1,+2), new Point(-2,+1), 
				 new Point(-1,+1), new Point(-2, 0), 
				 new Point(+1,+4), new Point(+1,+3), 
				 new Point(+1,+2), new Point(+2,+1), 
				 new Point(+1,+1), new Point(+2, 0), 
				 ];
  public function fillPlan(map:TileMap, b:Rectangle):void
  {
    var p:Point = getTileCoords(center);
    var r0:Rectangle = getTileRect(p.x, p.y);
    var dx0:int = Math.floor((r0.width/2+b.x)/tilesize);
    var dy0:int = Math.floor((r0.height/2+b.y)/tilesize);
    var dx1:int = Math.floor((r0.width/2+b.x+b.width-1)/tilesize);
    var dy1:int = Math.floor((r0.height/2+b.y+b.height-1)/tilesize);
    var e1:PlanEntry = getEntry(p.x, p.y);
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x+dx0, e0.x+dx1, e0.y+dy0, e0.y+dy1, Tile.isobstacle)) continue;

      var cost:int, i:int, d:Point;
      // try walking right.
      if (this.x0 <= e0.x-1 && Tile.isstoppable(map.getTile(e0.x-1, e0.y+dy1+1))) {
	e1 = getEntry(e0.x-1, e0.y);
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try walking left.
      if (e0.x+1 <= this.x1 && Tile.isstoppable(map.getTile(e0.x+1, e0.y+dy1+1))) {
	e1 = getEntry(e0.x+1, e0.y);
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try falling.
      if (this.y0 <= e0.y-1 && !Tile.isstoppable(map.getTile(e0.x, e0.y+dy1))) {
	e1 = getEntry(e0.x, e0.y-1);
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.FALL;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing down.
      if (this.y0 <= e0.y-1 && Tile.isgrabbable(map.getTile(e0.x, e0.y+dy1))) {
	e1 = getEntry(e0.x, e0.y-1);
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing up.
      if (e0.y+1 <= this.y1 && 
	  map.hasTile(e0.x+dx0, e0.x+dx1, e0.y+dy0+1, e0.y+dy1+1, Tile.isgrabbable)) {
	e1 = getEntry(e0.x, e0.y+1);
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try jumping.
      for (i = 0; i < JUMPLOC.length; i++) {
	d = JUMPLOC[i];
	if (this.x0 <= e0.x+d.x && e0.x+d.x <= this.x1 && e0.y+d.y <= this.y1 && 
	    Tile.isstoppable(map.getTile(e0.x+d.x, e0.y+dy1+d.y+1)) &&
	    !map.hasTile(e0.x+dx0+d.x, e0.x+dx1, e0.y+dy0, e0.y+dy1+d.y, Tile.isstoppable)) {
	  e1 = getEntry(e0.x+d.x, e0.y+d.y);
	  cost = e0.cost+Math.abs(d.x)+Math.abs(d.y)+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.JUMP;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(e1);
	  }
	}
      }
      //queue.sortOn("cost", Array.DESCENDING);
    }
    return;
  }
}

}
