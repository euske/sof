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
  private var plantimeout:int;

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
      var src:Point = scene.tilemap.getCoordsByPoint(pos);
      var dst:Point = scene.tilemap.getCoordsByPoint(target.pos);
      // invalidate plan.
      if (curplan != null && !curplan.dst.equals(dst)) {
	curplan = null;
      }
      // make a plan.
      if (curplan == null) {
	if (target.isLanded()) {
	  var jumpdt:int = Math.floor(jumpspeed / gravity);
	  var falldt:int = Math.floor(maxspeed / gravity);
	  curplan = scene.createPlan(dst);
	  curplan.fillPlan(src, skin.tilebounds, jumpdt, falldt, speed, gravity);
	  PlanVisualizer.main.plan = curplan;
	}
      }
      // follow a plan.
      if (curentry == null && curplan != null) {
	// Get a macro-level plan.
	var entry:PlanEntry = curplan.getEntry(src.x, src.y);
	if (entry != null && entry.next != null) {
	  Main.log("entry="+entry);
	  curentry = entry;
	}
      }
      PlanVisualizer.main.src = src;
      if (curentry != null) {
	var pn:Point = curentry.next.p;
	var nextpos:Point = scene.tilemap.getTilePoint(pn.x, pn.y);
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
	  vy = Utils.clamp(-1, (nextpos.y-pos.y), +1);
	  if (!isMovable(0, vy*speed)) {
	    vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	    vy = 0;
	  }
	  break;
	  
	case PlanEntry.JUMP:
	  if (src.equals(curentry.p)) {
	    jump();
	  }
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  break;
	}
	  //Main.log("action="+curentry.action+", vx="+vx+", vy="+vy);
	if (curentry.next.p.equals(src)) {
	    curentry = null;
	}
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
