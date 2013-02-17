package SOF {

import flash.display.Shape;
import SOF.PlanEntry;
import SOF.PlanMap;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public static var main:PlanVisualizer;

  public function PlanVisualizer()
  {
    super();
    main = this;
  }

  public static function update(plan:PlanMap):void
  {
    main.update(plan);
  }

  public function update(plan:PlanMap):void
  {
    graphics.clear();
    for (var y:int = plan.y0; y <= plan.y1; y++) {
      for (var x:int = plan.x0; x <= plan.x1; x++) {
	var e:PlanEntry = plan.getEntry(x, y);
	var c:int = 0x0000ff;
	switch (e.action) {
	case PlanEntry.WALK:
	  c = 0xffffff;
	  break;
	case PlanEntry.FALL:
	  c = 0x0000ff;
	  break;
	case PlanEntry.CLIMB:
	  c = 0x00ff00;
	  break;
	case PlanEntry.JUMP:
	  c = 0xff00ff;
	  break;
	default:
	  continue;
	}
	graphics.lineStyle(0, c);
	graphics.drawRect(x*10, y*10, 10, 10);
	graphics.lineStyle(0, 0xffff00);
	if (e.next != null) {
	  graphics.moveTo(x*10+5, y*10+5);
	  graphics.lineTo(e.next.x*10+5, e.next.y*10+5);
	}
      }
    }
  }
}

}
