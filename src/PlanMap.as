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
  public function fillPlan(src:Point, bounds:Rectangle,
			   jumpdt:int, falldt:int, 
			   speed:int, gravity:int):void
  {
    var jumpdx:int = Math.floor(jumpdt*speed / map.tilesize);
    var jumpdy:int = -Math.floor(jumpdt*(jumpdt+1)/2 * gravity / map.tilesize);
    var falldx:int = Math.floor(falldt*speed / map.tilesize);
    var falldy:int = Math.ceil(falldt*(falldt+1)/2 * gravity / map.tilesize);
    // jump=(3,-4), fall=(3,5)

    var cost:int, x:int, y:int, dx:int, dy:int, dt:int;
    var bx0:int, bx1:int, by0:int, by1:int;
    var e1:PlanEntry = a[(y1-y0)/2][(x1-x0)/2];
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      if (map.hasTile(e0.x+bounds.left, e0.y+bounds.top, 
		      e0.x+bounds.right, e0.y+bounds.bottom, 
		      Tile.isobstacle)) continue;
      if (!Tile.isstoppable(map.getTile(e0.x, e0.y+bounds.bottom+1))) continue;
      // assert(x0 <= e0.x && e0.x <= x1);
      // assert(y0 <= e0.y && e0.y <= y1);

      // try walking.
      for (dx = -1; dx <= +1; dx += 2) {
	x = e0.x+dx;
	if (x < x0 || x1 < x) continue;
	if (Tile.isstoppable(map.getTile(x, e0.y+bounds.bottom+1))) {
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
	  Tile.isgrabbable(map.getTile(e0.x, e0.y+bounds.bottom))) {
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
	  map.hasTile(e0.x+bounds.left, e0.y+bounds.top+1,
		      e0.x+bounds.right, e0.y+bounds.bottom+1,
		      Tile.isgrabbable)) {
	e1 = a[e0.y-y0+1][e0.x-x0];
	cost = e0.cost+1;
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }

      // try jumping + falling.
      for (var vx:int = -1; vx <= +1; vx += 2) {
	var bx:int = (vx < 0)? bounds.left : bounds.right;
	for (var fdx:int = 0; fdx <= falldx; fdx++) {
	  var fx:int = e0.x+vx*fdx;
	  if (fx < x0 || x1 < fx) continue;
	  var fdt:int = Math.floor(map.tilesize*fdx/speed);
	  var fdy:int = Math.ceil(fdt*(fdt+1)/2 * gravity / map.tilesize);
	  for (; fdy <= falldy; fdy++) {
	    var fy:int = e0.y-fdy;
	    if (fy < y0 || y1 < fy) continue;
	    if (map.hasTile(e0.x, e0.y+bounds.bottom, 
			    fx, fy+bounds.top, 
			    Tile.isstoppable)) continue;
	    for (var jdx:int = 1; jdx <= jumpdx; jdx++) {
	      var jx:int = fx+vx*jdx;
	      if (jx < x0 || x1 < jx) continue;
	      var jy:int = fy-jumpdy;
	      if (jy < y0 || y1 < jy) continue;
	      if (!Tile.isstoppable(map.getTile(jx, 
						jy+bounds.bottom+1))) continue;
	      if (map.hasTile(fx+vx, fy+bounds.top, 
	       		      jx, jy+bounds.bottom, 
	      		      Tile.isstoppable)) continue;
	      //trace("jump: e0="+e0.x+","+e0.y+ ", f="+fx+","+fy+", j="+jx+","+jy);
	      e1 = a[jy-y0][jx-x0];
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

      // // try jumping.
      // for (dx = -jumpdx; dx <= jumpdx; dx++) {
      // 	if (dx == 0) continue;
      // 	x = e0.x+dx;
      // 	if (x < x0 || x1 < x) continue;
      // 	bx0 = (dx < 0)? -1+bounds.left : +1+bounds.right;
      // 	bx1 = (dx < 0)? bounds.left : bounds.right;
      // 	for (dy = 1; dy <= jumpdy; dy++) {
      // 	  y = e0.y+dy;
      // 	  if (y < y0 || y1 < y) continue;
      // 	  if (!Tile.isstoppable(map.getTile(x, y+bounds.bottom+1))) continue;
      // 	  if (map.hasTile(e0.x+bx0, e0.y+bounds.top, 
      // 			  x+bx1, y+bounds.bottom, Tile.isstoppable)) continue;
      // 	  e1 = a[y-y0][x-x0];
      // 	  cost = e0.cost+Math.abs(dx)+Math.abs(dy)+1;
      // 	  if (cost < e1.cost) {
      // 	    e1.action = PlanEntry.JUMP;
      // 	    e1.cost = cost;
      // 	    e1.next = e0;
      // 	    queue.push(e1);
      // 	  }
      // 	}
      // }

      // try falling.
      for (dx = -falldx; dx <= falldx; dx++) {
	x = e0.x+dx;
	if (x < x0 || x1 < x) continue;
	bx0 = (dx==0)? 0 : ((dx < 0)? 1+bounds.right : -1+bounds.left);
	bx1 = (dx==0)? 0 : ((dx < 0)? bounds.right : bounds.left);
	dt = Math.floor(map.tilesize*Math.abs(dx)/speed);
	dy = -Math.ceil(dt*(dt+1)/2 * gravity / map.tilesize);
	for (; -falldy <= dy; dy--) {
	  y = e0.y+dy;
	  if (y < y0 || y1 < y) continue;
	  if (!Tile.isstoppable(map.getTile(x, y+bounds.bottom+1)) &&
	      !map.hasTile(x+bounds.left, y+bounds.top, 
			   x+bounds.right, y+bounds.bottom, Tile.isgrabbable)) continue;
	  //Main.log("d=", dx, dy, "p=", x, y, "range=", e0.x+bx0, e0.y+by0, x+bx1, y+by1);
	  if (map.hasTile(x+bx0, y+bounds.top, 
			  e0.x+bx1, e0.y+bounds.bottom, Tile.isstoppable)) continue;
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
