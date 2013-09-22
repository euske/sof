package {

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

//  Actor
//
public class Actor extends Sprite
{
  public var pos:Point;
  public var skin:MCSkin;

  protected var _scene:Scene;
  protected var _nametag:MCNameTag;
  protected var _balloon:MCBalloon;

  private var vg:int = 0;
  private var phase:Number = 0;
  private var jumping:Boolean;

  public const gravity:int = 2;
  public const speed:int = 8;
  public const jumpspeed:int = 24;
  public const maxspeed:int = 24;

  public static const DIE:String = "DIE";
  public static const JUMP:String = "JUMP";
  public static const LAND:String = "LAND";

  // Actor(image)
  public function Actor(scene:Scene)
  {
    pos = new Point(0, 0);
    skin = new MCSkin();
    _scene = scene;
    _nametag = new MCNameTag();
    _balloon = new MCBalloon();
    addChild(skin);
    addChild(_nametag);
    addChild(_balloon);
  }

  // bounds
  public function get bounds():Rectangle
  {
    var b:Rectangle = skin.bounds;
    return new Rectangle(pos.x+b.x, pos.y+b.y, b.width, b.height);
  }
  public function set bounds(value:Rectangle):void
  {
    pos.x = Math.floor((value.left+value.right)/2);
    pos.y = Math.floor((value.top+value.bottom)/2);
  }

  // nametag
  public function set nametag(value:String):void
  {
    _nametag.text = value;
    _nametag.x = -_nametag.width/2;
    _nametag.y = skin.bounds.y-_nametag.height-10;
  }

  // move()
  public function move(v0:Point):void
  {
    if (isGrabbing()) {
      // climing a ladder.
      var vl:Point = _scene.tilemap.getCollisionByRect(bounds, v0.x, v0.y, Tile.isobstacle);
      pos = Utils.movePoint(pos, vl.x, vl.y);
      vg = 0;
    } else {
      // falling.
      var vf:Point = _scene.tilemap.getCollisionByRect(bounds, v0.x, vg, Tile.isstoppable);
      pos = Utils.movePoint(pos, vf.x, vf.y);
      // moving (in air).
      var vdx:Point = _scene.tilemap.getCollisionByRect(bounds, v0.x-vf.x, 0, Tile.isobstacle);
      pos = Utils.movePoint(pos, vdx.x, vdx.y);
      var vdy:Point;
      if (0 < v0.y) {
	// start climing down.
	vdy = _scene.tilemap.getCollisionByRect(bounds, 0, vg-vf.y+v0.y, Tile.isobstacle);
      } else {
	// falling (cont'd).
	vdy = _scene.tilemap.getCollisionByRect(bounds, 0, vg-vf.y, Tile.isstoppable);
      }
      pos = Utils.movePoint(pos, vdy.x, vdy.y);
      vg = Math.min(vf.y+vdx.y+vdy.y+gravity, maxspeed);
    }

    if (v0.x != 0 || v0.y != 0) {
      skin.dir = v0;
    }

    if (_scene.tilemap.hasCollisionByRect(bounds, 0, vg, Tile.isstoppable)) {
      phase += v0.x;
      skin.phase = Math.cos(phase)*0.5;
    }
  }

  // update(v)
  public virtual function update():void
  {
  }

  // repaint()
  public virtual function repaint():void
  {
    var p:Point = _scene.translatePoint(pos);
    this.x = p.x;
    this.y = p.y;
    skin.repaint();
    if (skin.dir.x < 0) {
      _balloon.x = skin.bounds.x-_balloon.width-10;
    } else {
      _balloon.x = skin.bounds.x+skin.bounds.width+20;
    }
    _balloon.y = skin.bounds.y-_balloon.height/2;
  }

  // speak()
  public function speak(text:String=null):void
  {
    _balloon.text = text;
  }

  // jump()
  public function jump():void
  {
    if (isLanded()) {
      dispatchEvent(new ActorActionEvent(JUMP));
      vg = -jumpspeed;
      jumping = true;
    }
  }

  // isLanded()
  public function isLanded():Boolean
  {
    return _scene.tilemap.hasCollisionByRect(bounds, 0, 1, Tile.isstoppable);
  }
  
  // isGrabbing()
  public function isGrabbing():Boolean
  {
    return _scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable);
  }
  
  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    var r:Rectangle = Utils.moveRect(bounds, dx, dy);
    return (!_scene.tilemap.hasTileByRect(r, Tile.isobstacle));
  }
  
  // hasUpperLadderNearby()
  public function hasUpperLadderNearby():int
  {
    var r:Rectangle = bounds;
    var r0:Rectangle = Utils.moveRect(r, -r.width, 0);
    var r1:Rectangle = Utils.moveRect(r, +r.width, 0);
    var h0:Boolean = _scene.tilemap.hasTileByRect(r0, Tile.isgrabbable);
    var h1:Boolean = _scene.tilemap.hasTileByRect(r1, Tile.isgrabbable);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }
  }

  // hasLowerLadderNearby()
  public function hasLowerLadderNearby():int
  {
    var r:Rectangle = bounds;
    var rb:Rectangle = new Rectangle(r.x, r.bottom, r.width, 1);
    var rb0:Rectangle = Utils.moveRect(rb, -rb.width, 0);
    var rb1:Rectangle = Utils.moveRect(rb, +rb.width, 0);
    var h0:Boolean = _scene.tilemap.hasTileByRect(rb0, Tile.isgrabbable);
    var h1:Boolean = _scene.tilemap.hasTileByRect(rb1, Tile.isgrabbable);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }    
  }

  // hasHoleNearby()
  public function hasHoleNearby():int
  {
    var r:Rectangle = bounds;
    var rb:Rectangle = new Rectangle(r.x, r.bottom, r.width, 1);
    var rb0:Rectangle = Utils.moveRect(rb, -rb.width, 0);
    var rb1:Rectangle = Utils.moveRect(rb, +rb.width, 0);
    var h0:Boolean = _scene.tilemap.hasTileByRect(rb0, Tile.isnone);
    var h1:Boolean = _scene.tilemap.hasTileByRect(rb1, Tile.isnone);
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
