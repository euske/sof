package {

import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import TileMap;
import PlanMap;
import Actor;

//  Scene
// 
public class Scene extends Sprite
{
  public var tilemap:TileMap;
  private var window:Rectangle;
  private var mapsize:Point;
  public var actors:Array = [];

  // Scene(width, height, tilemap)
  public function Scene(width:int, height:int, tilemap:TileMap)
  {
    this.window = new Rectangle(0, 0, width, height);
    this.tilemap = tilemap;
    this.mapsize = new Point(tilemap.mapwidth*tilemap.tilesize,
			     tilemap.mapheight*tilemap.tilesize);
  }

  // add(actor)
  public function add(actor:Actor):void
  {
    addChild(actor);
    actors.push(actor);
  }

  // remove(actor)
  public function remove(actor:Actor):void
  {
    removeChild(actor);
    actors.splice(actors.indexOf(actor), 1);
  }

  // update()
  public function update():void
  {
    for each (var actor:Actor in actors) {
      actor.update();
    }
  }

  // repaint()
  public function repaint():void
  {
    for each (var actor:Actor in actors) {
      actor.repaint();
    }
    tilemap.repaint(window);
  }

  // setCenter(p)
  public function setCenter(p:Point, hmargin:int, vmargin:int):void
  {
    // Center the window position.
    if (p.x-hmargin < window.x) {
      window.x = p.x-hmargin;
    } else if (window.x+window.width < p.x+hmargin) {
      window.x = p.x+hmargin-window.width;
    }
    if (p.y-vmargin < window.y) {
      window.y = p.y-vmargin;
    } else if (window.y+window.height < p.y+vmargin) {
      window.y = p.y+vmargin-window.height;
    }
    
    // Adjust the window position to fit the world.
    if (window.x < 0) {
      window.x = 0;
    } else if (mapsize.x < window.x+window.width) {
      window.x = mapsize.x-window.width;
    }
    if (window.y < 0) {
      window.y = 0;
    } else if (mapsize.y < window.y+window.height) {
      window.y = mapsize.y-window.height;
    }
  }

  // createPlan(dst, bounds)
  public function createPlan(cx:int, cy:int, w:int, h:int):PlanMap
  {
    var plan:PlanMap = new PlanMap(Math.floor(window.width/2/tilemap.tilesize),
				   Math.floor(window.height/2/tilemap.tilesize),
				   cx, cy);
    plan.fillPlan(tilemap, w, h);
    return plan;
  }

  // translatePoint(p)
  public function translatePoint(p:Point):Point
  {
    return new Point(p.x-window.x, p.y-window.y);
  }

  // scanTileX(r)
  public function scanTileX(r:Rectangle, f:Function):Boolean
  {
    return tilemap.scanTileX(r, f) != tilemap.NOTFOUND;
  }

  // scanTileY(r)
  public function scanTileY(r:Rectangle, f:Function):Boolean
  {
    return tilemap.scanTileY(r, f) != tilemap.NOTFOUND;
  }

  // getDistanceX(r)
  public function getDistanceX(src:Rectangle, vx:int, f:Function):int
  {
    var r:Rectangle; 
    var x:int = tilemap.NOTFOUND;
    if (vx < 0) {
      r = new Rectangle(src.x, src.y, vx, src.height);
      x = tilemap.scanTileX(r, f);
    } else if (0 < vx) {
      r = new Rectangle(src.x+src.width, src.y, vx, src.height);
      x = tilemap.scanTileX(r, f);
    }
    if (x != tilemap.NOTFOUND) {
      vx = x - r.x;
    }
    return vx;
  }

  // getDistanceY(r)
  public function getDistanceY(src:Rectangle, vy:int, f:Function):int
  {
    var r:Rectangle; 
    var y:int = tilemap.NOTFOUND;
    if (vy < 0) {
      r = new Rectangle(src.x, src.y, src.width, vy);
      y = tilemap.scanTileY(r, f);
    } else if (0 < vy) {
      r = new Rectangle(src.x, src.y+src.height, src.width, vy);
      y = tilemap.scanTileY(r, f);
    }
    if (y != tilemap.NOTFOUND) {
      vy = y - r.y;
    }
    return vy;
  }

  // hasLadderNearby(r)
  public function hasLadderNearby(r:Rectangle):int
  {
    var r0:Rectangle = new Rectangle(r.x, r.y, -tilemap.tilesize/2, r.height);
    var r1:Rectangle = new Rectangle(r.x+r.width, r.y, +tilemap.tilesize/2, r.height);
    var h0:Boolean = scanTileX(r0, Tile.isgrabbable);
    var h1:Boolean = scanTileX(r1, Tile.isgrabbable);
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
    var r0:Rectangle = new Rectangle(r.x, r.y+r.height, -tilemap.tilesize/2, 1);
    var r1:Rectangle = new Rectangle(r.x+r.width, r.y+r.height, +tilemap.tilesize/2, 1);
    var h0:Boolean = scanTileX(r0, Tile.isnonobstacle);
    var h1:Boolean = scanTileX(r1, Tile.isnonobstacle);
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
