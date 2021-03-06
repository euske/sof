package {

import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Scene
// 
public class Scene extends Sprite
{
  public var tilemap:TileMap;

  private var _window:Rectangle;
  private var _mapsize:Point;

  // actors
  public var actors:Array = [];

  // Scene(width, height, tilemap)
  public function Scene(width:int, height:int, tilemap:TileMap)
  {
    this.tilemap = tilemap;
    _window = new Rectangle(0, 0, width, height);
    _mapsize = new Point(tilemap.mapwidth*tilemap.tilesize,
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
    tilemap.repaint(_window);
  }

  // setCenter(p)
  public function setCenter(p:Point, hmargin:int, vmargin:int):void
  {
    // Center the window position.
    if (p.x-hmargin < _window.x) {
      _window.x = p.x-hmargin;
    } else if (_window.x+_window.width < p.x+hmargin) {
      _window.x = p.x+hmargin-_window.width;
    }
    if (p.y-vmargin < _window.y) {
      _window.y = p.y-vmargin;
    } else if (_window.y+_window.height < p.y+vmargin) {
      _window.y = p.y+vmargin-_window.height;
    }
    
    // Adjust the window position to fit the world.
    if (_window.x < 0) {
      _window.x = 0;
    } else if (_mapsize.x < _window.x+_window.width) {
      _window.x = _mapsize.x-_window.width;
    }
    if (_window.y < 0) {
      _window.y = 0;
    } else if (_mapsize.y < _window.y+_window.height) {
      _window.y = _mapsize.y-_window.height;
    }
  }

  // translatePoint(p)
  public function translatePoint(p:Point):Point
  {
    return new Point(p.x-_window.x, p.y-_window.y);
  }

  // createPlan(center)
  public function createPlan(center:Point):PlanMap
  {
    var x0:int = Math.floor(_window.left/tilemap.tilesize);
    var y0:int = Math.floor(_window.top/tilemap.tilesize);
    var x1:int = Math.ceil(_window.right/tilemap.tilesize);
    var y1:int = Math.ceil(_window.bottom/tilemap.tilesize);
    return new PlanMap(tilemap, center, 
		       new Rectangle(x0, y0, x1-x0, y1-y0));
  }
}

} // package
