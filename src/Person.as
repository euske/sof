package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Person
//
public class Person extends Actor
{
  private var target:Actor;
  private var curplan:PlanMap;
  private var curentry:PlanEntry;

  // Person(image)
  public function Person(scene:Scene)
  {
    super(scene);
    addEventListener(ActorActionEvent.ACTION, onActorAction);
  }

  // setTarget(actor)
  public function setTarget(actor:Actor):void
  {
    target = actor;
    curplan = null;
  }

  // onActorAction()
  private function onActorAction(e:ActorActionEvent):void
  {
  }

  // update()
  public override function update():void
  {
    super.update();
    var vx:int, vy:int;
    if (target == null) {
      // random
      if (Math.random() < 0.05) {
	vx = int(Math.random()*3)-1;
	vy = 0;
      } else if (Math.random() < 0.05) {
	vx = 0;
	vy = int(Math.random()*3)-1;
      } else if (Math.random() < 0.1) {
	jump();
      }
      move(new Point(vx*speed, vy*speed));
    } else {
      // planned
      var dst:Point = scene.tilemap.getCoordsByPoint(target.pos);
      if (curplan == null || 
	  curplan.dst.x != dst.x || 
	  curplan.dst.y != dst.y) {
	// Make a plan.
	var dt:int = Math.floor(jumpspeed / gravity);
	var dx:int = Math.floor(dt*speed / scene.tilemap.tilesize);
	var dy:int = Math.floor(dt*(dt+1)/2 * gravity / scene.tilemap.tilesize);
	curplan = scene.createPlan(dst);
	curplan.fillPlan(0, 0, -2, +1, dx, dy);
	curentry = null;
	PlanVisualizer.main.plan = curplan;
      }
      var src:Point = scene.tilemap.getCoordsByPoint(pos);
      if (curentry == null || curentry.x != src.x || curentry.y != src.y) {
	// Get a macro-level plan.
	var entry:PlanEntry = curplan.getEntry(src.x, src.y);
	if (entry != null && (curentry == null || entry.cost < curentry.cost)) {
	  Main.log("entry="+entry);
	  curentry = entry;
	}
	PlanVisualizer.main.src = src;
      }
      if (curentry != null && curentry.next != null) {
	var nextpos:Point = scene.tilemap.getTilePoint(curentry.next.x, curentry.next.y);
	// Get a micro-level (greedy) plan.
	switch (curentry.action) {
	case PlanEntry.WALK:
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  if (!isMovable(vx*speed, 0)) {
	    vx = 0;
	    vy = Utils.clamp(-1, (nextpos.y-pos.y), +1);
	  }
	  break;

	case PlanEntry.FALL:
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  break;

	case PlanEntry.CLIMB:
	  if (scene.tilemap.hasTileByRect(bounds, Tile.isgrabbable)) {
	    vy = Utils.clamp(-1, (nextpos.y-pos.y), +1);
	    if (!isMovable(0, vy*speed)) {
	      vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	      vy = 0;
	    }
	  } else {
	    vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  }
	  break;

	case PlanEntry.JUMP:
	  jump();
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  break;
	}
	//Main.log("action="+curentry.action+", vx="+vx+", vy="+vy);
      }
      move(new Point(vx*speed, vy*speed));
    }

    if (Math.random() < 0.05) {
      switch (int(Math.random()*3)) {
      case 0:
	speak("Derp.");
	break;
      case 1:
	speak("SNARF!");
	break;
      default:
	speak();
	break;
      }
    }
  }
}

} // package
