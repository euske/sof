package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Person
//
public class Person extends Actor
{
  private var target:Actor;
  private var curgoal:Point;
  private var curaction:int;
  private var vx:int, vy:int;

  // Person(image)
  public function Person(scene:Scene)
  {
    super(scene);
    vx = int(Math.random()*3)-1;
    vy = 0;
    addEventListener(ActorActionEvent.ACTION, onActorAction);
  }

  // setTarget(actor)
  public function setTarget(actor:Actor):void
  {
    target = actor;
    curgoal = null;
    curaction = PlanEntry.NONE;
  }

  // onActorAction()
  private function onActorAction(e:ActorActionEvent):void
  {
    if (e.arg == Actor.LAND) {
      curaction = PlanEntry.NONE;
    }
  }

  // update()
  public override function update():void
  {
    super.update();
    if (target == null) {
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
      var src:Rectangle = scene.tilemap.getTileByRect(bounds);
      var dst:Rectangle = scene.tilemap.getTileByRect(target.bounds);
      if (curaction == PlanEntry.NONE) {
	// Get a macro-level planning.
	var plan:PlanMap = scene.createPlan(dst.x, dst.y, dst.width, dst.height);
	var e:PlanEntry = plan.getEntry(src.x, src.y);
	if (e != null && e.next != null) {
	  curgoal = new Point(e.next.x, e.next.y);
	  curaction = e.action;
	  //log("goal="+curgoal+", action="+curaction);
	  if (curaction == PlanEntry.JUMP) {
	    jump();
	  }
	}
	PlanVisualizer.update(plan);
      } else {
	// Micro-level (greedy) planning.
	// assert(curgoal != null);
	// assert(curaction != PlanEntry.NONE);
	//log("goal="+curgoal+", src="+src);
	var dx:int = 0, dy:int = 0;
	if (curgoal.x < src.x) { 
	  dx = -1;
	} else if (src.x < curgoal.x) {
	  dx = +1;
	}
	var r:Rectangle = bounds.clone();
	r.x += speed*dx;
	if (scene.tilemap.hasTileByRect(r, Tile.isobstacle)) {
	  dx = 0;
	}
	if (dx == 0) {
	  if (curgoal.y < src.y) { 
	    dy = -1; 
	  } else if (src.y < curgoal.y) {
	    dy = +1;
	  }
	}
	if (dx != 0 || dy != 0) {
	  vx = dx; 
	  vy = dy;
	} else {
	  curaction = PlanEntry.NONE;
	}
      }
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
