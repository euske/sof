package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanMap
// 
public class PlanMap
{
  public var map:TileMap;
  public var dst:Point;
  public var bounds:Rectangle;

  private var _a:Array;

  public function PlanMap(map:TileMap, dst:Point, bounds:Rectangle)
  {
    this.map = map;
    this.dst = dst;
    this.bounds = bounds;
    _a = new Array(bounds.height+1);
    var maxcost:int = (bounds.width+bounds.height+1)*2;
    for (var y:int = bounds.top; y <= bounds.bottom; y++) {
      var b:Array = new Array(bounds.width+1);
      for (var x:int = bounds.left; x <= bounds.right; x++) {
	b[x-bounds.left] = new PlanEntry(x, y, PlanEntry.NONE, maxcost, null);
      }
      _a[y-bounds.top] = b;
    }
  }

  public function toString():String
  {
    return ("<PlanMap ("+bounds.left+","+bounds.top+")-("+
	    bounds.right+","+bounds.bottom+")>");
  }

  // getEntry(x, y)
  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < bounds.left || bounds.right < x ||
	y < bounds.top || bounds.bottom < y) return null;
    return _a[y-bounds.top][x-bounds.left];
  }

  // fillPlan(plan, b)
  public function fillPlan(src:Point, cb:Rectangle,
			   jumpdt:int, falldt:int, 
			   speed:int, gravity:int):void
  {
    var jumpdx:int = Math.floor(jumpdt*speed / map.tilesize);
    var jumpdy:int = -Math.floor(jumpdt*(jumpdt+1)/2 * gravity / map.tilesize);
    var falldx:int = Math.floor(falldt*speed / map.tilesize);
    var falldy:int = Math.ceil(falldt*(falldt+1)/2 * gravity / map.tilesize);
    // jump=(3,-4), fall=(3,5)

    var cost:int;
    var e1:PlanEntry = _a[dst.y-bounds.top][dst.x-bounds.left];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x+cb.left, e0.y+cb.top, 
		      e0.x+cb.right, e0.y+cb.bottom, 
		      Tile.isobstacle) ||
	  !map.isTile(e0.x, e0.y+cb.bottom+1, Tile.isstoppable)) continue;
      // assert(bounds.left <= e0.x && e0.x <= bounds.right);
      // assert(bounds.top <= e0.y && e0.y <= bounds.bottom);

      // try climbing down.
      if (bounds.top <= e0.y-1 &&
	  map.isTile(e0.x, e0.y+cb.bottom, Tile.isgrabbable)) {
	e1 = _a[e0.y-bounds.top-1][e0.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing up.
      if (e0.y+1 <= bounds.bottom &&
	  map.hasTile(e0.x+cb.left, e0.y+cb.top+1,
		      e0.x+cb.right, e0.y+cb.bottom+1,
		      Tile.isgrabbable)) {
	e1 = _a[e0.y-bounds.top+1][e0.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }

      // for left and right.
      for (var vx:int = -1; vx <= +1; vx += 2) {

	// try walking.
	var wx:int = e0.x+vx;
	if (bounds.left <= wx && wx <= bounds.right &&
	    map.isTile(wx, e0.y+cb.bottom+1, Tile.isstoppable)) {
	  e1 = _a[e0.y-bounds.top][wx-bounds.left];
	  cost = e0.cost+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.WALK;
	    e1.cost = cost;
	    e1.next = e0;
	    queue.push(e1);
	  }
	}

	// try falling.
	for (fdx = 1; fdx <= falldx; fdx++) {
	  fx = e0.x+vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) continue;
	  fdt = Math.floor(map.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = e0.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) continue;
	    if (!map.isTile(fx, fy+cb.bottom+1, Tile.isstoppable) ||
		map.hasTile(e0.x, e0.y+cb.bottom,
			    fx-vx, fy+cb.top, 
			    Tile.isstoppable)) continue;
	    e1 = _a[fy-bounds.top][fx-bounds.left];
	    cost = e0.cost+Math.abs(fdx)+Math.abs(fdy)+1;
	    if (cost < e1.cost) {
	      e1.action = PlanEntry.FALL;
	      e1.cost = cost;
	      e1.next = e0;
	      queue.push(e1);
	    }
	  }
	}

	// try jumping + falling.
	var fx:int, fy:int;
	var fdt:int, fdx:int, fdy:int;
	for (fdx = 0; fdx <= falldx; fdx++) {
	  fx = e0.x+vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) continue;
	  fdt = Math.floor(map.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = e0.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) continue;
	    if (map.hasTile(e0.x, e0.y+cb.bottom, 
			    fx, fy+cb.top, 
			    Tile.isstoppable)) continue;
	    for (var jdx:int = 1; jdx <= jumpdx; jdx++) {
	      var jx:int = fx+vx*jdx;
	      if (jx < bounds.left || bounds.right < jx) continue;
	      var jy:int = fy-jumpdy;
	      if (jy < bounds.top || bounds.bottom < jy) continue;
	      if (!map.isTile(jx, jy+cb.bottom+1, Tile.isstoppable) ||
		  map.hasTile(fx+vx, fy+cb.top, 
			      jx, jy+cb.bottom, 
	      		      Tile.isstoppable)) continue;
	      e1 = _a[jy-bounds.top][jx-bounds.left];
	      cost = e0.cost+Math.abs(fdx+jdx)+Math.abs(fdy+jumpdy)+1;
	      if (cost < e1.cost) {
		e1.action = PlanEntry.JUMP;
		e1.cost = cost;
		e1.next = e0;
		queue.push(e1);
	      }
	    }
	  }
	}
      }
      //queue.sortOn("prio", Array.DESCENDING);
    }
    return;
  }
}

} // package
