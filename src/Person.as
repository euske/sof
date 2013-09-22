package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Person
//
public class Person extends Actor
{
  public var visualizer:PlanVisualizer;

  private var _target:Actor;
  private var _plan:PlanMap;
  private var _entry:PlanEntry;

  // Person(image)
  public function Person(scene:Scene)
  {
    super(scene);
    addEventListener(ActorActionEvent.ACTION, onActorAction);
  }

  // target
  public function set target(value:Actor):void
  {
    _target = value;
    _plan = null;
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
    if (_target == null) {
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
      var src:Point = _scene.tilemap.getCoordsByPoint(pos);
      var dst:Point = _scene.tilemap.getCoordsByPoint(_target.pos);
      // invalidate plan.
      if (_plan != null && !_plan.dst.equals(dst)) {
	_plan = null;
      }
      // make a plan.
      if (_plan == null) {
	if (_target.isLanded()) {
	  var jumpdt:int = Math.floor(jumpspeed / gravity);
	  var falldt:int = Math.floor(maxspeed / gravity);
	  var plan:PlanMap = _scene.createPlan(dst);
	  if (plan.fillPlan(src, skin.tilebounds, 
			    jumpdt, falldt, speed, gravity)) {
	    _plan = plan;
	    if (visualizer != null) {
	      visualizer.plan = plan;
	    }
	  }
	}
      }
      // follow a plan.
      if (_entry == null && _plan != null) {
	// Get a macro-level plan.
	var entry:PlanEntry = _plan.getEntry(src.x, src.y);
	if (entry != null && entry.next != null) {
	  Main.log("entry="+entry);
	  _entry = entry;
	}
      }
      if (_entry != null) {
	var pn:Point = _entry.next.p;
	var nextpos:Point = _scene.tilemap.getTilePoint(pn.x, pn.y);
	// Get a micro-level (greedy) plan.
	switch (_entry.action) {
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
	  if (src.equals(_entry.p)) {
	    jump();
	  }
	  vx = Utils.clamp(-1, (nextpos.x-pos.x), +1);
	  break;
	}
	  //Main.log("action="+_entry.action+", vx="+vx+", vy="+vy);
	if (_entry.next.p.equals(src)) {
	    _entry = null;
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
