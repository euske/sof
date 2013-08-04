package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

//  TileMap
//
public class TileMap extends Bitmap
{
  public var map:BitmapData;
  public var tiles:BitmapData;
  public var tilesize:int;

  private var _tilevalue:Dictionary;
  private var _prevrect:Rectangle;

  // TileMap(map, tiles, tilesize, width, height)
  public function TileMap(map:BitmapData, 
			  tiles:BitmapData,
			  tilesize:int)
  {
    this.map = map;
    this.tiles = tiles;
    this.tilesize = tilesize;
    _prevrect = new Rectangle(-1,-1,0,0);
    _tilevalue = new Dictionary();
    for (var i:int = 0; i < map.width; i++) {
      var c:uint = map.getPixel(i, 0);
      if (_tilevalue[c] === undefined) {
	_tilevalue[c] = i;
      }
    }
  }

  // mapwidth
  public function get mapwidth():int
  {
    return map.width;
  }
  // mapheight
  public function get mapheight():int
  {
    return map.height-1;
  }

  // repaint(window)
  public function repaint(window:Rectangle):void
  {
    var x0:int = Math.floor(window.x/tilesize);
    var y0:int = Math.floor(window.y/tilesize);
    var mw:int = Math.floor(window.width/tilesize)+1;
    var mh:int = Math.floor(window.height/tilesize)+1;
    if (_prevrect.x != x0 || _prevrect.y != y0 ||
	_prevrect.width != mw || _prevrect.height != mh) {
      renderTiles(x0, y0, mw, mh);
      _prevrect.x = x0;
      _prevrect.y = y0;
      _prevrect.width = mw;
      _prevrect.height = mh;
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
  public function getTile(x:int, y:int):int
  {
    if (x < 0 || map.width <= x || 
	y < 0 || map.height <= y+1) {
      return -1;
    }
    var c:uint = map.getPixel(x, y+1);
    return _tilevalue[c];
  }

  // scanTile(x0, y0, x1, y1, f)
  public function scanTile(x0:int, y0:int, x1:int, y1:int, f:Function):Array
  {
    var a:Array = new Array();
    var dx:int = Math.abs(x1+1-x0);
    var dy:int = Math.abs(y1+1-y0);
    var vx:int = (x0 < x1)? +1 : -1;
    var vy:int = (y0 < y1)? +1 : -1;
    var n:int = Math.max(dx, dy);
    for (var i:int = 0; i < n; i++) {
      for (var j:int = 0; j <= i; j++) {
	if (j < dx && (i-j) < dy) {
	  var x:int = x0+j*vx;
	  var y:int = y0+(i-j)*vy;
	  if (f(getTile(x, y))) {
	    a.push(new Point(x, y));
	  }
	}
      }
    }
    return a;
  }

  // hasTile(x0, y0, x1, y1, f)
  public function hasTile(x0:int, y0:int, x1:int, y1:int, f:Function):Boolean
  {
    return (scanTile(x0, y0, x1, y1, f).length != 0);
  }

  // getTileRect(x, y)
  public function getTileRect(x:int, y:int):Rectangle
  {
    return new Rectangle(x*tilesize, y*tilesize, tilesize, tilesize);
  }

  // getTileByRect(x, y)
  public function getTileByRect(r:Rectangle):Rectangle
  {
    var x0:int = Math.floor(r.left/tilesize);
    var y0:int = Math.floor(r.top/tilesize);
    var x1:int = Math.floor((r.right+tilesize-1)/tilesize);
    var y1:int = Math.floor((r.bottom+tilesize-1)/tilesize);
    return new Rectangle(x0, y0, x1-x0, y1-y0);
  }

  // hasTileByRect(r, f)
  public function hasTileByRect(r:Rectangle, f:Function):Boolean
  {
    var r1:Rectangle = getTileByRect(r);
    return hasTile(r1.left, r1.top, r1.right, r1.bottom, f);
  }

  // getCollisionByRect(r, v, f)
  public function getCollisionByRect(r:Rectangle, v:Point, f:Function):Point
  {
    var src:Rectangle = r.clone();
    src.x += v.x;
    src.y += v.y;
    src = src.union(r);
    var r1:Rectangle = getTileByRect(src);
    var a:Array = scanTile(r1.left, r1.top, r1.right, r1.bottom, f);
    for each (var p:Point in a) {
      var t:Rectangle = getTileRect(p.x, p.y);
      v = Utils.collideRect(t, r, v);
    }
    return v;
  }

  // hasCollisionByRect(r, f)
  public function hasCollisionByRect(r:Rectangle, v:Point, f:Function):Boolean
  {
    var src:Rectangle = r.clone();
    src.x += v.x;
    src.y += v.y;
    src = src.union(r);
    return hasTileByRect(src, f);
  }

  // hasLadderNearby(r)
  public function hasLadderNearby(r:Rectangle):int
  {
    var dx:int = tilesize/2;
    var h0:Boolean = hasCollisionByRect(r, new Point(-dx, 0), Tile.isgrabbable);
    var h1:Boolean = hasCollisionByRect(r, new Point(+dx, 0), Tile.isgrabbable);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }
  }

  // hasHoleNearby(r)
  public function hasHoleNearby(r:Rectangle):int
  {
    var r0:Rectangle = new Rectangle(r.x, r.y+r.height, -tilesize/2, 1);
    var r1:Rectangle = new Rectangle(r.x+r.width, r.y+r.height, +tilesize/2, 1);
    var h0:Boolean = hasTileByRect(r0, Tile.isnonobstacle);
    var h1:Boolean = hasTileByRect(r1, Tile.isnonobstacle);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }    
  }
}

} // package
