package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanMap
// 
public class PlanMap
{
  public var map:TileMap;
  public var dst:Point;
  public var x0:int, y0:int, x1:int, y1:int;

  private var a:Array;

  public function PlanMap(map:TileMap, width:int, height:int, dst:Point)
  {
    this.map = map;
    this.dst = dst;
    x0 = dst.x-width;
    x1 = dst.x+width;
    y0 = dst.y-height;
    y1 = dst.y+height;
    a = new Array(y1-y0+1);
    var cost:int = (width+height+1)*2;
    for (var y:int = y0; y <= y1; y++) {
      var b:Array = new Array(x1-x0+1);
      for (var x:int = x0; x <= x1; x++) {
	b[x-x0] = new PlanEntry(x, y, PlanEntry.NONE, cost, null);
      }
      a[y-y0] = b;
    }
  }

  public function toString():String
  {
    return ("<PlanMap ("+x0+","+y0+")-("+x1+","+y1+")>");
  }

  // getEntry(x, y)
  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < x0 || x1 < x || y < y0 || y1 < y) return null;
    return a[y-y0][x-x0];
  }

  // fillPlan(plan, b)
  public function fillPlan(dx0:int, dx1:int, dy0:int, dy1:int,
			   jumpdx:int, jumpdy:int):void
  {
    var x:int, y:int, dx:int, dy:int, cost:int;
    var e1:PlanEntry = a[(y1-y0)/2][(x1-x0)/2];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x+dx0, e0.y+dy0, e0.x+dx1, e0.y+dy1, Tile.isobstacle)) continue;

      // try walking.
      for (dx = -1; dx <= +1; dx += 2) {
	x = e0.x+dx;
	if (x < x0 || x1 < x) continue;
	if (Tile.isstoppable(map.getTile(x, e0.y+dy1+1))) {
	  e1 = a[e0.y-y0][x-x0];
	  cost = e0.cost+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.WALK;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(e1);
	  }
	}
      }

      // try climbing down.
      if (y0 <= e0.y-1 &&
	  Tile.isgrabbable(map.getTile(e0.x, e0.y+dy1))) {
	e1 = a[e0.y-y0-1][e0.x-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing up.
      if (e0.y+1 <= y1 &&
	  map.hasTile(e0.x+dx0, e0.y+dy0+1, e0.x+dx1, e0.y+dy1+1, Tile.isgrabbable)) {
	e1 = a[e0.y-y0+1][e0.x-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }

      // try jumping.
      for (dy = 1; dy <= jumpdy; dy++) {
	y = e0.y+dy;
	if (y < y0 || y1 < y) continue;
	for (dx = -jumpdx; dx <= jumpdx; dx++) {
	  if (dx == 0) continue;
	  x = e0.x+dx;
	  if (x < x0 || x1 < x) continue;
	  var bx0:int = (dx < 0)? -1+dx0 : +1+dx1;
	  var bx1:int = (dx < 0)? dx0 : dx1;
	  if (Tile.isstoppable(map.getTile(x, y+dy1+1)) && 
	      !map.hasTile(e0.x+bx0, e0.y+dy0, 
			   e0.x+bx1+dx, e0.y+dy1+dy, Tile.isstoppable)) {
	    e1 = a[y-y0][x-x0];
	    cost = e0.cost+Math.abs(dx)+dy+1;
	    if (cost < e1.cost) {
	      e1.action = PlanEntry.JUMP;
	      e1.cost = cost;
	      e1.next = e0;
	      queue.push(e1);
	    }
	  }
	}
      }

      // try falling.
      if (y0 <= e0.y-1 &&
	  !Tile.isgrabbable(map.getTile(e0.x, e0.y+dy1))) {
	e1 = a[e0.y-y0-1][e0.x-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.FALL;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }

      //queue.sortOn("cost", Array.DESCENDING);
    }
    return;
  }
}

} // package
