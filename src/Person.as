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
	  curplan.center.x != dst.x || 
	  curplan.center.y != dst.y) {
	// Make a plan.
	curplan = scene.createPlan(dst, 0, -2, 0, +1);
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
	// Get a micro-level (greedy) plan.
	var vx1:int;
	switch (curentry.action) {
	case PlanEntry.JUMP:
	  jump();
	  if (curentry.next.x < src.x) { 
	    vx = -1;
	  } else if (src.x < curentry.next.x) {
	    vx = +1;
	  } 
	  break;
	case PlanEntry.FALL:
	  if (curentry.next.x < src.x) { 
	    vx = -1;
	  } else if (src.x < curentry.next.x) {
	    vx = +1;
	  } else {
	    vx = hasHoleNearby();
	  }
	  break;
	case PlanEntry.CLIMB:
	  if (curentry.next.y < src.y) { 
	    // move toward a nearby ladder.
	    vx1 = hasUpperLadderNearby();
	    if (vx1 != 0) {
	      vx = vx1;
	    } else {
	      vy = -1;
	    }
	  } else if (src.y < curentry.next.y) {
	    // move toward a nearby ladder.
	    vx1 = hasLowerLadderNearby();
	    if (vx1 != 0) {
	      vx = vx1;
	    } else {
	      vy = +1;
	    }
	  }
	  break;
	case PlanEntry.WALK:
	  if (curentry.next.x < src.x) { 
	    vx = -1;
	  } else if (src.x < curentry.next.x) {
	    vx = +1;
	  } 
	  break;
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
