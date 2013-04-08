package SOF {

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import SOF.MCSkin;
import SOF.MCNameTag;
import SOF.MCBalloon;
import SOF.TileMap;
import SOF.Tile;
import SOF.ActorActionEvent;

//  Actor
//
public class Actor extends Sprite
{
  public var scene:Scene;
  public var skin:MCSkin;
  public var nametag:MCNameTag;
  public var balloon:MCBalloon;
  
  public var pos:Point;

  private var vx:int = 0, vy:int = 0, vg:int = 0;
  private var phase:Number = 0;
  private var jumping:Boolean;

  public const gravity:int = 2;
  public const speed:int = 8;
  public const jumpacc:int = -24;

  public static const DIE:String = "DIE";
  public static const JUMP:String = "JUMP";
  public static const LAND:String = "LAND";

  // Actor(image)
  public function Actor(scene:Scene, image:BitmapData)
  {
    this.scene = scene;
    this.skin = new MCSkin(image);
    this.nametag = new MCNameTag();
    this.balloon = new MCBalloon();
    addChild(this.skin);
    addChild(this.nametag);
    addChild(this.balloon);
  }

  // bounds
  public function get bounds():Rectangle
  {
    var b:Rectangle = skin.bounds;
    return new Rectangle(pos.x+b.x, pos.y+b.y, b.width, b.height);
  }
  public function set bounds(r:Rectangle):void
  {
    pos = new Point(r.x+r.width/2, r.y+r.height/2);
  }

  // move(vx, vy)
  public function move(vx:int, vy:int):void
  {
    this.vx = vx;
    this.vy = vy;
  }

  // jump()
  public function jump():void
  {
    var v:int = vg+gravity;
    if (0 < v && scene.getDistanceY(bounds, v, Tile.isstoppable) == 0) {
      dispatchEvent(new ActorActionEvent(JUMP));
      vg = scene.getDistanceY(bounds, jumpacc, Tile.isstoppable);
      jumping = true;
    }
  }

  // update()
  public virtual function update():void
  {
    var vx1:int = vx;
    var vy1:int = vy;
    if (vy < 0) {
      // move toward a nearby ladder.
      var vxladder:int = scene.hasLadderNearby(bounds);
      if (vxladder != 0) {
	vx1 = vxladder;
	vy1 = 0;
      }
    } else if (0 < vy) {
      // move toward a nearby hole.
      var vxhole:int = scene.hasHoleNearby(bounds);
      if (vxhole != 0) {
	vx1 = vxhole;
	vy1 = 0;
      }
    }
    pos.x += scene.getDistanceX(bounds, speed*vx1, Tile.isobstacle);
    if (scene.scanTileY(bounds, Tile.isgrabbable) ||
	0 < vy1 && scene.getDistanceY(bounds, vy1, Tile.isgrabbable) == 0) {
      // climbing
      vg = 0;
      pos.y += scene.getDistanceY(bounds, speed*vy1, Tile.isobstacle);
      if (jumping) {
	jumping = false;
	dispatchEvent(new ActorActionEvent(LAND));
      }
    } else {
      // falling
      vg = scene.getDistanceY(bounds, vg+gravity, Tile.isstoppable);
      if (jumping && 0 <= vg) {
	jumping = false;
	dispatchEvent(new ActorActionEvent(LAND));
      }
      pos.y += vg;
    }
    if (vx1 != 0 || vy1 != 0) {
      skin.setDirection(vx1, vy1);
    }
    if (vg == 0) {
      phase += vx1;
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
  public virtual function speak(text:String=null):void
  {
    balloon.setText(text);
  }

  // setName(name)
  public virtual function setName(name:String):void
  {
    nametag.setText(name);
    nametag.x = -nametag.width/2;
    nametag.y = skin.bounds.y-nametag.height-10;
  }

}

}
