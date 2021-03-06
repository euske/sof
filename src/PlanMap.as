package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanMap
// 
public class PlanMap
{
  public var map:TileMap;
  public var src:Point;
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
	var p:Point = new Point(x, y);
	b[x-bounds.left] = new PlanEntry(p, PlanEntry.NONE, maxcost, null);
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
  public function fillPlan(src:Point, cb:Rectangle, n:int,
			   jumpdt:int, falldt:int, 
			   speed:int, gravity:int):int
  {
    // jumpd=(3,-4), falld=(3,5)
    var jumpdx:int = Math.floor(jumpdt*speed / map.tilesize);
    var jumpdy:int = -Math.floor(jumpdt*(jumpdt+1)/2 * gravity / map.tilesize);
    var falldx:int = Math.floor(falldt*speed / map.tilesize);
    var falldy:int = Math.ceil(falldt*(falldt+1)/2 * gravity / map.tilesize);

    if (src != null && 
	!map.isTile(src.x, src.y+cb.bottom+1, Tile.isstoppable)) return 0;
    this.src = src;
    
    var e1:PlanEntry = _a[dst.y-bounds.top][dst.x-bounds.left];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < n && 0 < queue.length) {
      var cost:int;
      var e0:PlanEntry = queue.pop();
      var p:Point = e0.p;
      if (src != null && src.equals(p)) break;
      if (map.hasTile(p.x+cb.left, p.y+cb.top, 
		      p.x+cb.right, p.y+cb.bottom, 
		      Tile.isobstacle) ||
	  !map.isTile(p.x, p.y+cb.bottom+1, Tile.isstoppable)) continue;
      // assert(bounds.left <= p.x && p.x <= bounds.right);
      // assert(bounds.top <= p.y && p.y <= bounds.bottom);

      // try climbing down.
      if (bounds.top <= p.y-1 &&
	  map.isTile(p.x, p.y+cb.bottom, Tile.isgrabbable)) {
	e1 = _a[p.y-bounds.top-1][p.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  if (src != null) {
	    e1.prio = Math.abs(src.x-e1.p.x)+Math.abs(src.y-e1.p.y);
	  }
	  queue.push(e1);
	}
      }
      // try climbing up.
      if (p.y+1 <= bounds.bottom &&
	  map.hasTile(p.x+cb.left, p.y+cb.top+1,
		      p.x+cb.right, p.y+cb.bottom+1,
		      Tile.isgrabbable)) {
	e1 = _a[p.y-bounds.top+1][p.x-bounds.left];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  if (src != null) {
	    e1.prio = Math.abs(src.x-e1.p.x)+Math.abs(src.y-e1.p.y);
	  }
	  queue.push(e1);
	}
      }

      // for left and right.
      for (var vx:int = -1; vx <= +1; vx += 2) {
	var bx:int = (vx < 0)? cb.right : cb.left;

	// try walking.
	var wx:int = p.x+vx;
	if (bounds.left <= wx && wx <= bounds.right &&
	    map.isTile(wx, p.y+cb.bottom+1, Tile.isstoppable)) {
	  e1 = _a[p.y-bounds.top][wx-bounds.left];
	  cost = e0.cost+1;
	  if (cost < e1.cost) {
	    e1.action = PlanEntry.WALK;
	    e1.cost = cost;
	    e1.next = e0;
	    if (src != null) {
	      e1.prio = Math.abs(src.x-e1.p.x)+Math.abs(src.y-e1.p.y);
	    }
	    queue.push(e1);
	  }
	}

	// try falling.
	for (fdx = 1; fdx <= falldx; fdx++) {
	  fx = p.x+vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) continue;
	  fdt = Math.floor(map.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = p.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) continue;
	    if (!map.isTile(fx, fy+cb.bottom+1, Tile.isstoppable) ||
		map.hasTile(p.x+bx, p.y+cb.bottom,
			    fx-vx, fy+cb.top-1, 
			    Tile.isstoppable)) continue;
	    e1 = _a[fy-bounds.top][fx-bounds.left];
	    cost = e0.cost+Math.abs(fdx)+Math.abs(fdy)+1;
	    if (cost < e1.cost) {
	      e1.action = PlanEntry.FALL;
	      e1.cost = cost;
	      e1.next = e0;
	      if (src != null) {
		e1.prio = Math.abs(src.x-e1.p.x)+Math.abs(src.y-e1.p.y);
	      }
	      queue.push(e1);
	    }
	  }
	}

	// try jumping + falling.
	var fx:int, fy:int;
	var fdt:int, fdx:int, fdy:int;
	for (fdx = 0; fdx <= falldx; fdx++) {
	  fx = p.x+vx*fdx;
	  if (fx < bounds.left || bounds.right < fx) continue;
	  fdt = Math.floor(map.tilesize*fdx/speed);
	  fdy = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    fy = p.y-fdy;
	    if (fy < bounds.top || bounds.bottom < fy) continue;
	    if (map.hasTile(p.x+bx, p.y+cb.bottom, 
			    fx, fy+cb.top-1, 
			    Tile.isstoppable)) continue;
	    for (var jdx:int = 1; jdx <= jumpdx; jdx++) {
	      var jx:int = fx+vx*jdx;
	      if (jx < bounds.left || bounds.right < jx) continue;
	      var jy:int = fy-jumpdy;
	      if (jy < bounds.top || bounds.bottom < jy) continue;
	      if (!map.isTile(jx, jy+cb.bottom+1, Tile.isstoppable) ||
		  map.hasTile(fx+vx, fy+cb.top-1, 
			      jx, jy+cb.bottom, 
	      		      Tile.isstoppable)) continue;
	      e1 = _a[jy-bounds.top][jx-bounds.left];
	      cost = e0.cost+Math.abs(fdx+jdx)+Math.abs(fdy+jumpdy)+1;
	      if (cost < e1.cost) {
		e1.action = PlanEntry.JUMP;
		e1.cost = cost;
		e1.next = e0;
		if (src != null) {
		  e1.prio = Math.abs(src.x-e1.p.x)+Math.abs(src.y-e1.p.y);
		}
		queue.push(e1);
	      }
	    }
	  }
	}
      }
      if (src != null) {
	// A* search.
	queue.sortOn("prio", Array.NUMERIC | Array.DESCENDING);
      }
      n--;
    }

    return n;
  }
}

} // package
