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
  public function fillPlan(src:Point,
			   bleft:int, bright:int, 
			   btop:int, bbottom:int,
			   jumpdt:int, falldt:int, 
			   speed:int, gravity:int):void
  {
    var jumpdx:int = Math.floor(jumpdt*speed / map.tilesize);
    var jumpdy:int = Math.floor(jumpdt*(jumpdt+1)/2 * gravity / map.tilesize);
    var falldx:int = Math.floor(falldt*speed / map.tilesize);
    var falldy:int = Math.ceil(falldt*(falldt+1)/2 * gravity / map.tilesize);
    var cost:int, x:int, y:int, dx:int, dy:int, dt:int;
    var bx0:int, bx1:int, by0:int, by1:int;
    var e1:PlanEntry = a[(y1-y0)/2][(x1-x0)/2];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x+bleft, e0.y+btop, e0.x+bright, e0.y+bbottom, Tile.isobstacle)) continue;
      if (!Tile.isstoppable(map.getTile(e0.x, e0.y+bbottom+1))) continue;
      // assert(x0 <= e0.x && e0.x <= x1);
      // assert(y0 <= e0.y && e0.y <= y1);

      // try walking.
      for (dx = -1; dx <= +1; dx += 2) {
	x = e0.x+dx;
	if (x < x0 || x1 < x) continue;
	if (Tile.isstoppable(map.getTile(x, e0.y+bbottom+1))) {
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
	  Tile.isgrabbable(map.getTile(e0.x, e0.y+bbottom))) {
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
	  map.hasTile(e0.x+bleft, e0.y+btop+1, e0.x+bright, e0.y+bbottom+1, Tile.isgrabbable)) {
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
      for (dx = -jumpdx; dx <= jumpdx; dx++) {
	if (dx == 0) continue;
	x = e0.x+dx;
	if (x < x0 || x1 < x) continue;
	bx0 = (dx < 0)? -1+bleft : +1+bright;
	bx1 = (dx < 0)? bleft : bright;
	for (dy = 1; dy <= jumpdy; dy++) {
	  y = e0.y+dy;
	  if (y < y0 || y1 < y) continue;
	  if (!Tile.isstoppable(map.getTile(x, y+bbottom+1))) continue;
	  if (map.hasTile(e0.x+bx0, e0.y+btop, x+bx1, y+bbottom, Tile.isstoppable)) continue;
	  e1 = a[y-y0][x-x0];
	  cost = e0.cost+Math.abs(dx)+Math.abs(dy)+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.JUMP;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(e1);
	  }
	}
      }

      // try falling.
      for (dx = -falldx; dx <= falldx; dx++) {
	x = e0.x+dx;
	if (x < x0 || x1 < x) continue;
	bx0 = (dx==0)? 0 : ((dx < 0)? 1+bright : -1+bleft);
	bx1 = (dx==0)? 0 : ((dx < 0)? bright : bleft);
	dt = Math.floor(map.tilesize*Math.abs(dx)/speed);
	dy = -Math.ceil(dt*(dt+1)/2 * gravity / map.tilesize);
	for (; -falldy <= dy; dy--) {
	  y = e0.y+dy;
	  if (y < y0 || y1 < y) continue;
	  if (!Tile.isstoppable(map.getTile(x, y+bbottom+1)) &&
	      !map.hasTile(x+bleft, y+btop, x+bright, y+bbottom, Tile.isgrabbable)) continue;
	  //Main.log("d=", dx, dy, "p=", x, y, "range=", e0.x+bx0, e0.y+by0, x+bx1, y+by1);
	  if (map.hasTile(x+bx0, y+btop, e0.x+bx1, e0.y+bbottom, Tile.isstoppable)) continue;
	  e1 = a[y-y0][x-x0];
	  cost = e0.cost+Math.abs(dx)+Math.abs(dy)+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.FALL;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(e1);
	  }
	}
      }

      //queue.sortOn("prio", Array.DESCENDING);
    }
    return;
  }
}

} // package
