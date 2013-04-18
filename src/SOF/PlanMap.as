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
  public var x0:int, y0:int, x1:int, y1:int;
  private var a:Array;

  public function PlanMap(width:int, height:int, cx:int, cy:int)
  {
    x0 = cx-width;
    x1 = cx+width;
    y0 = cy-height;
    y1 = cy+height;
    a = new Array(y1-y0+1);
    var m:int = (width+height+1)*2;
    for (var y:int = y0; y <= y1; y++) {
      var b:Array = new Array(x1-x0+1);
      for (var x:int = x0; x <= x1; x++) {
	b[x-x0] = new PlanEntry(x, y, 0, m, null);
      }
      a[y-y0] = b;
    }
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
  public function fillPlan(map:TileMap, w:int, h:int):void
  {
    w -= 1;
    h -= 1;
    var e1:PlanEntry = a[(y1-y0)/2][(x1-x0)/2];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x-w, e0.x+w, e0.y-h, e0.y, Tile.isobstacle)) continue;

      var cost:int;
      // try walking right.
      if (x0 <= e0.x-1 && Tile.isstoppable(map.getTile(e0.x-1, e0.y+1))) {
	e1 = a[e0.y-y0][e0.x-1-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try walking left.
      if (e0.x+1 <= x1 && Tile.isstoppable(map.getTile(e0.x+1, e0.y+1))) {
	e1 = a[e0.y-y0][e0.x+1-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try falling.
      if (y0 <= e0.y-1 && !Tile.isstoppable(map.getTile(e0.x, e0.y))) {
	e1 = a[e0.y-1-y0][e0.x-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.FALL;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing down.
      if (y0 <= e0.y-1 && Tile.isgrabbable(map.getTile(e0.x, e0.y))) {
	e1 = a[e0.y-1-y0][e0.x-x0];
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
	  map.hasTile(e0.x-w, e0.x-w, e0.y-h+1, e0.y+1, Tile.isgrabbable)) {
	e1 = a[e0.y+1-y0][e0.x-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try jumping.
      for (var i:int = 0; i < JUMPLOC.length; i++) {
	var d:Point = JUMPLOC[i];
	var x:int = e0.x+d.x;
	var y:int = e0.y+d.y;
	if (x0 <= x && x <= x1 && y0 <= y && y <= y1 && 
	    Tile.isstoppable(map.getTile(x, x+1)) &&
	    !map.hasTile(x-w, x+w, y-h, y, Tile.isstoppable)) {
	  e1 = a[y-y0][x-x0];
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
