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
  public var scene:Scene;
  public var pos:Point;
  public var skin:MCSkin;
  public var nametag:MCNameTag;
  public var balloon:MCBalloon;

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
    this.scene = scene;
    pos = new Point(0, 0);
    skin = new MCSkin();
    nametag = new MCNameTag();
    balloon = new MCBalloon();
    addChild(skin);
    addChild(nametag);
    addChild(balloon);
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

  // setSkinImage(skin)
  public function setSkinImage(image:BitmapData):void
  {
    skin.setImage(image);
  }

  // setName(name)
  public function setName(name:String):void
  {
    nametag.setText(name);
    nametag.x = -nametag.width/2;
    nametag.y = skin.bounds.y-nametag.height-10;
  }

  // move()
  public function move(v0:Point):void
  {
    if (isGrabbing()) {
      // climing a ladder.
      var vl:Point = scene.tilemap.getCollisionByRect(bounds, v0.x, v0.y, Tile.isobstacle);
      pos = Utils.movePoint(pos, vl.x, vl.y);
      vg = 0;
    } else {
      // falling.
      var vf:Point = scene.tilemap.getCollisionByRect(bounds, v0.x, vg, Tile.isstoppable);
      pos = Utils.movePoint(pos, vf.x, vf.y);
      // moving (in air).
      var vdx:Point = scene.tilemap.getCollisionByRect(bounds, v0.x-vf.x, 0, Tile.isobstacle);
      pos = Utils.movePoint(pos, vdx.x, vdx.y);
      var vdy:Point;
      if (0 < v0.y) {
	// start climing down.
	vdy = scene.tilemap.getCollisionByRect(bounds, 0, vg-vf.y+v0.y, Tile.isobstacle);
      } else {
	// falling (cont'd).
	vdy = scene.tilemap.getCollisionByRect(bounds, 0, vg-vf.y, Tile.isstoppable);
      }
      pos = Utils.movePoint(pos, vdy.x, vdy.y);
      vg = Math.min(vf.y+vdx.y+vdy.y+gravity, maxspeed);
    }

    if (v0.x != 0 || v0.y != 0) {
      skin.setDirection(v0.x, v0.y);
    }

    if (scene.tilemap.hasCollisionByRect(bounds, 0, vg, Tile.isstoppable)) {
      phase += v0.x;
      skin.setPhase(Math.cos(phase)*0.5);
    }
  }

  // update(v)
  public virtual function update():void
  {
  }

  // repaint()
  public virtual function repaint():void
  {
    var p:Point = scene.translatePoint(pos);
    this.x = p.x;
    this.y = p.y;
    skin.repaint();
    if (skin.vx < 0) {
      balloon.x = skin.bounds.x-balloon.width-10;
    } else {
      balloon.x = skin.bounds.x+skin.bounds.width+20;
    }
    balloon.y = skin.bounds.y-balloon.height/2;
  }

  // speak()
  public function speak(text:String=null):void
  {
    balloon.setText(text);
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
    return scene.tilemap.hasCollisionByRect(bounds, 0, vg, Tile.isstoppable);
  }
  
  // isGrabbing()
  public function isGrabbing():Boolean
  {
    return scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable);
  }
  
  // isMovable(dx, dy)
  public function isMovable(dx:int, dy:int):Boolean
  {
    var r:Rectangle = Utils.moveRect(bounds, dx, dy);
    return (!scene.tilemap.hasTileByRect(r, Tile.isobstacle));
  }
  
  // hasUpperLadderNearby()
  public function hasUpperLadderNearby():int
  {
    var r:Rectangle = bounds;
    var r0:Rectangle = Utils.moveRect(r, -r.width, 0);
    var r1:Rectangle = Utils.moveRect(r, +r.width, 0);
    var h0:Boolean = scene.tilemap.hasTileByRect(r0, Tile.isgrabbable);
    var h1:Boolean = scene.tilemap.hasTileByRect(r1, Tile.isgrabbable);
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
    var h0:Boolean = scene.tilemap.hasTileByRect(rb0, Tile.isgrabbable);
    var h1:Boolean = scene.tilemap.hasTileByRect(rb1, Tile.isgrabbable);
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
    var h0:Boolean = scene.tilemap.hasTileByRect(rb0, Tile.isnone);
    var h1:Boolean = scene.tilemap.hasTileByRect(rb1, Tile.isnone);
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
