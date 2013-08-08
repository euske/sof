package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Person
//
public class Person extends Actor
{
  private var target:Actor;
  private var cursrc:Point;
  private var curgoal:Point;

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
    curgoal = null;
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
      var src:Point = scene.tilemap.getCoordsByPoint(pos);
      if (cursrc == null || cursrc.x != src.x || cursrc.y != src.y) {
	// Get a macro-level planning.
	var dst:Point = scene.tilemap.getCoordsByPoint(target.pos);
	Main.log("src="+src+", dst="+dst);
	var plan:PlanMap = scene.createPlan(dst.x, dst.y, 0, -3, 0, 0);
	var e:PlanEntry = plan.getEntry(src.x, src.y);
	if (e != null && e.next != null) {
	  cursrc = src;
	  curgoal = new Point(e.next.x, e.next.y);
	  Main.log("goal="+curgoal+", action="+e.action);
	  if (e.action == PlanEntry.JUMP) {
	    jump();
	  }
	}
	PlanVisualizer.update(plan);
      }
      if (curgoal != null) {
	// Micro-level (greedy) planning.
	//Main.log("goal="+curgoal+", pos="+src);
	if (curgoal.x < src.x) { 
	  vx = -1;
	} else if (src.x < curgoal.x) {
	  vx = +1;
	} 
	if (curgoal.y < src.y) { 
	  vy = -1; 
	} else if (src.y < curgoal.y) {
	  vy = +1;
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
