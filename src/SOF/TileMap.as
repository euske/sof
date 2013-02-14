package SOF {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import SOF.Tile;
import SOF.PlanEntry;
import SOF.PlanMap;

//  TileMap
//
public class TileMap extends Bitmap
{
  public var map:BitmapData;
  public var tiles:BitmapData;
  public var tilesize:int;
  public const NOTFOUND:int = -999;

  private var prevrect:Rectangle;

  // TileMap(map, tiles, tilesize, width, height)
  public function TileMap(map:BitmapData, 
			  tiles:BitmapData,
			  tilesize:int)
  {
    this.map = map;
    this.tiles = tiles;
    this.tilesize = tilesize;
    this.prevrect = new Rectangle(-1,-1,0,0);
  }

  // mapwidth
  public function get mapwidth():int
  {
    return map.width;
  }
  // mapheight
  public function get mapheight():int
  {
    return map.height;
  }

  // repaint(window)
  public function repaint(window:Rectangle):void
  {
    var x0:int = Math.floor(window.x/tilesize);
    var y0:int = Math.floor(window.y/tilesize);
    var mw:int = Math.floor(window.width/tilesize)+1;
    var mh:int = Math.floor(window.height/tilesize)+1;
    if (prevrect.x != x0 || prevrect.y != y0 ||
	prevrect.width != mw || prevrect.height != mh) {
      renderTiles(x0, y0, mw, mh);
      prevrect.x = x0;
      prevrect.y = y0;
      prevrect.width = mw;
      prevrect.height = mh;
    }
    this.x = (x0*tilesize)-window.x;
    this.y = (y0*tilesize)-window.y;
  }

  // renderTiles(x, y)
  protected function renderTiles(x0:int, y0:int, mw:int, mh:int):void
  {
    if (bitmapData == null) {
      bitmapData = new BitmapData(mw*tilesize, 
				  mh*tilesize, 
				  true, 0x00000000);
    }
    for (var dy:int = 0; dy < mh; dy++) {
      for (var dx:int = 0; dx < mw; dx++) {
	var i:int = getTile(x0+dx, y0+dy);
	var src:Rectangle = new Rectangle(i*tilesize, 0, tilesize, tilesize);
	var dst:Point = new Point(dx*tilesize, dy*tilesize);
	bitmapData.copyPixels(tiles, src, dst);
      }
    }
  }

  // getTile(x, y)
  private function getTile(x:int, y:int):int
  {
    if (x < 0 || map.width <= x || 
	y < 0 || map.height <= y) {
      return -1;
    }
    var c:uint = map.getPixel(x, y);
    return Tile.pixelToTileId(c);
  }

  // getTileRect(x, y)
  public function getTileRect(x:int, y:int):Rectangle
  {
    return new Rectangle(x*tilesize, y*tilesize, tilesize, tilesize);
  }

  // scanTileX(r)
  public function scanTileX(r:Rectangle, f:Function):int
  {
    var y0:int = Math.floor(r.y/tilesize);
    var y1:int = Math.floor((r.y+r.height-1)/tilesize);
    var x0:int, x1:int;
    var x:int, y:int;
    if (r.width < 0) {
      x0 = Math.floor((r.x-1)/tilesize);
      x1 = Math.floor((r.x+r.width)/tilesize);
      for (x = x0; x1 <= x; x--) {
	for (y = y0; y <= y1; y++) {
	  if (f(getTile(x, y))) {
	    return (x+1)*tilesize;
	  }
	}
      }
    } else if (0 < r.width) {
      x0 = Math.floor(r.x/tilesize);
      x1 = Math.floor((r.x+r.width-1)/tilesize);
      for (x = x0; x <= x1; x++) {
	for (y = y0; y <= y1; y++) {
	  if (f(getTile(x, y))) {
	    return x*tilesize;
	  }
	}
      }
    }
    return NOTFOUND;
  }

  // scanTileY(r)
  public function scanTileY(r:Rectangle, f:Function):int
  {
    var x0:int = Math.floor(r.x/tilesize);
    var x1:int = Math.floor((r.x+r.width-1)/tilesize);
    var y0:int, y1:int;
    var x:int, y:int;
    if (r.height < 0) {
      y0 = Math.floor((r.y-1)/tilesize);
      y1 = Math.floor((r.y+r.height)/tilesize);
      for (y = y0; y1 <= y; y--) {
	for (x = x0; x <= x1; x++) {
	  if (f(getTile(x, y))) {
	    return (y+1)*tilesize;
	  }
	}
      }
    } else if (0 < r.height) {
      y0 = Math.floor(r.y/tilesize);
      y1 = Math.floor((r.y+r.height-1)/tilesize);
      for (y = y0; y <= y1; y++) {
	for (x = x0; x <= x1; x++) {
	  if (f(getTile(x, y))) {
	    return y*tilesize;
	  }
	}
      }
    }
    return NOTFOUND;
  }

  private function hasTile(x0:int, x1:int, y0:int, y1:int, f:Function):Boolean
  {
    for (var y:int = y0; y <= y1; y++) {
      for (var x:int = x0; x <= x1; x++) {
	if (f(getTile(x, y))) return true;
      }
    }
    return false;
  }

  // fillPlan(plan, b)
  public function fillPlan(plan:PlanMap, b:Rectangle):void
  {
    var p:Point = plan.getTileCoords(plan.center);
    var r0:Rectangle = plan.getTileRect(p.x, p.y);
    var dx0:int = Math.floor((r0.width/2+b.x)/tilesize);
    var dy0:int = Math.floor((r0.height/2+b.y)/tilesize);
    var dx1:int = Math.floor((r0.width/2+b.x+b.width-1)/tilesize);
    var dy1:int = Math.floor((r0.height/2+b.y+b.height-1)/tilesize);
    var e1:PlanEntry = plan.getEntry(p.x, p.y);
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      var cost:int = e0.cost+1;
      if (hasTile(e0.x+dx0, e0.x+dx1, e0.y+dy0, e0.y+dy1, Tile.isobstacle)) continue;

      // try walking right.
      if (plan.x0 < e0.x && Tile.isstoppable(getTile(e0.x-1, e0.y+dy1+1))) {
	e1 = plan.getEntry(e0.x-1, e0.y);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try walking left.
      if (e0.x < plan.x1 && Tile.isstoppable(getTile(e0.x+1, e0.y+dy1+1))) {
	e1 = plan.getEntry(e0.x+1, e0.y);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try falling.
      if (plan.y0 < e0.y && !Tile.isstoppable(getTile(e0.x, e0.y+dy1))) {
	e1 = plan.getEntry(e0.x, e0.y-1);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.FALL;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing down.
      if (plan.y0 < e0.y && Tile.isgrabbable(getTile(e0.x, e0.y+dy1))) {
	e1 = plan.getEntry(e0.x, e0.y-1);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing up.
      if (e0.y < plan.y1 && 
	  hasTile(e0.x+dx0, e0.x+dx1, e0.y+dy0+1, e0.y+dy1+1, Tile.isgrabbable)) {
	e1 = plan.getEntry(e0.x, e0.y+1);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
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

}
