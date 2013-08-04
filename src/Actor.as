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
  public var vx:int, vy:int;

  private var vg:int = 0;
  private var phase:Number = 0;
  private var jumping:Boolean;

  public const gravity:int = 2;
  public const speed:int = 8;
  public const jumpacc:int = -24;
  public const maxacc:int = 16;

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

  // move(v)
  public function move(v:Point):void
  {
    pos.x += v.x;
    pos.y += v.y;
  }

  // update()
  public virtual function update():void
  {
    var v:Point;
    if (scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable)) {
      v = new Point(vx*speed, vy*speed);
      v = scene.tilemap.getCollisionByRect(bounds, v, Tile.isobstacle)
      move(v);
    } else {
      var v0:Point = new Point(vx*speed, Math.min(vy*speed+vg+gravity, maxacc));
      v = scene.tilemap.getCollisionByRect(bounds, v0, Tile.isstoppable);
      move(v);
      var vx1:Point = new Point(v0.x-v.x, 0);
      vx1 = scene.tilemap.getCollisionByRect(bounds, vx1, Tile.isobstacle);
      move(vx1);
      var v2:Point;
      if (vy != 0) {
	v2 = new Point(0, v0.y-v.y+vy*speed);
	v2 = scene.tilemap.getCollisionByRect(bounds, v2, Tile.isobstacle);
      } else {
	v2 = new Point(0, v0.y-v.y);
	v2 = scene.tilemap.getCollisionByRect(bounds, v2, Tile.isstoppable);
      }
      move(v2);
      vg = v.y+v2.y;
    }

    // if (scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable) ||
    // 	0 < vy1 && scene.getDistanceY(bounds, vy1, Tile.isgrabbable) == 0) {
    //   // climbing
    //   vg = 0;
    //   pos.y += scene.getDistanceY(bounds, speed*vy1, Tile.isobstacle);
    //   if (jumping) {
    // 	jumping = false;
    // 	dispatchEvent(new ActorActionEvent(LAND));
    //   }
    // } else {
    //   // falling
    //   vg = scene.getDistanceY(bounds, vg+gravity, Tile.isstoppable);
    //   if (jumping && 0 <= vg) {
    // 	jumping = false;
    // 	dispatchEvent(new ActorActionEvent(LAND));
    //   }
    //   pos.y += vg;
    // }

    if (vx != 0 || vy != 0) {
      skin.setDirection(vx, vy);
    }
    if (vg == 0) {
      phase += vx;
      skin.setPhase(Math.cos(phase)*0.5);
    }
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
    if (scene.tilemap.hasCollisionByRect(bounds, new Point(0, gravity), Tile.isstoppable)) {
      dispatchEvent(new ActorActionEvent(JUMP));
      vg = jumpacc;
      jumping = true;
    }
  }
}

} // package
