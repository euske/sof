package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanMap
// 
public class PlanMap
{
  public var map:TileMap;
  public var center:Point;
  public var x0:int, y0:int, x1:int, y1:int;

  private var a:Array;

  public function PlanMap(map:TileMap, width:int, height:int, center:Point)
  {
    this.map = map;
    this.center = center;
    x0 = center.x-width;
    x1 = center.x+width;
    y0 = center.y-height;
    y1 = center.y+height;
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

  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < x0 || x1 < x || y < y0 || y1 < y) return null;
    return a[y-y0][x-x0];
  }

  // fillPlan(plan, b)
  public function fillPlan(dx0:int, dy0:int, dx1:int, dy1:int,
			   jumpdx:int, jumpdy:int):void
  {
    var w:int = dx1-dx0+1;
    var h:int = dy1-dy0+1;
    var e1:PlanEntry = a[(y1-y0)/2][(x1-x0)/2];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x+dx0, e0.y+dy0, w, h, Tile.isobstacle)) continue;

      var cost:int;
      // try walking right.
      if (x0 <= e0.x-1 && 
	  Tile.isstoppable(map.getTile(e0.x-1, e0.y+dy1+1))) {
	e1 = a[e0.y-y0][e0.x-x0-1];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try walking left.
      if (e0.x+1 <= x1 && 
	  Tile.isstoppable(map.getTile(e0.x+1, e0.y+dy1+1))) {
	e1 = a[e0.y-y0][e0.x-x0+1];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
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
	  map.hasTile(e0.x+dx0, e0.y+dy0+1, w, h, Tile.isgrabbable)) {
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
      for (var dy:int = 1; dy <= jumpdy; dy++) {
	var y:int = e0.y+dy;
	for (var dx:int = 1; dx <= jumpdx; dx++) {
	  var x:int = e0.x+dx;
	  if (x0 <= x && x <= x1 && y0 <= y && y <= y1 && 
	      Tile.isstoppable(map.getTile(x, y+dy1+1)) && 
	      map.hasTile(x+dx0-dx, y+dy0-dy, w+dx, h+dy, Tile.isstoppable)) {
	    e1 = a[y-y0][x-x0];
	    cost = e0.cost+Math.abs(dx)+Math.abs(dy)+1;
	    if (cost < e1.cost) {
	      e1.action = PlanEntry.JUMP;
	      e1.cost = cost;
	      e1.next = e0;
	      queue.push(e1);
	    }
	  }
	  x = e0.x-dx;
	  if (x0 <= x && x <= x1 && y0 <= y && y <= y1 && 
	      Tile.isstoppable(map.getTile(x, y+dy1+1)) && 
	      map.hasTile(x+dx0, y+dy0-dy, w+dx, h+dy, Tile.isstoppable)) {
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
