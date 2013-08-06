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

  // scanTile(x, y, w, h, f)
  public function scanTile(x:int, y:int, w:int, h:int, f:Function):Array
  {
    var a:Array = new Array();
    for (var dy:int = 0; dy < h; dy++) {
      for (var dx:int = 0; dx < w; dx++) {
	if (f(getTile(x+dx, y+dy))) {
	  a.push(new Point(x+dx, y+dy));
	}
      }
    }
    return a;
  }

  // hasTile(x, y, w, h, f)
  public function hasTile(x:int, y:int, w:int, h:int, f:Function):Boolean
  {
    return (scanTile(x, y, w, h, f).length != 0);
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
    return hasTile(r1.x, r1.y, r1.width, r1.height, f);
  }

  // getCollisionByRect(r, vx, vy, f)
  public function getCollisionByRect(r:Rectangle, vx:int, vy:int, f:Function):Point
  {
    var src:Rectangle = r.union(Utils.moveRect(r, vx, vy));
    var r1:Rectangle = getTileByRect(src);
    var a:Array = scanTile(r1.x, r1.y, r1.width, r1.height, f);
    var v:Point = new Point(vx, vy);
    for each (var p:Point in a) {
      var t:Rectangle = getTileRect(p.x, p.y);
      v = Utils.collideRect(t, r, v);
    }
    return v;
  }

  // hasCollisionByRect(r, f)
  public function hasCollisionByRect(r:Rectangle, vx:int, vy:int, f:Function):Boolean
  {
    var src:Rectangle = r.union(Utils.moveRect(r, vx, vy));
    return hasTileByRect(src, f);
  }
}

} // package
