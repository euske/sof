package {

import flash.display.Shape;
import flash.geom.Point;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public static var main:PlanVisualizer;

  public var src:Point;
  public var plan:PlanMap;

  public function PlanVisualizer()
  {
    super();
    main = this;
  }

  public function update():void
  {
    graphics.clear();
    if (plan == null) return;
    for (var y:int = plan.y0; y <= plan.y1; y++) {
      for (var x:int = plan.x0; x <= plan.x1; x++) {
	var e:PlanEntry = plan.getEntry(x, y);
	var c:int = 0x0000ff;
	switch (e.action) {
	case PlanEntry.WALK:
	  c = 0xffffff;		// white
	  break;
	case PlanEntry.FALL:
	  c = 0x0000ff;		// blue
	  break;
	case PlanEntry.CLIMB:	// green
	  c = 0x00ff00;
	  break;
	case PlanEntry.JUMP:	// magenta
	  c = 0xff00ff;
	  break;
	default:
	  continue;
	}
	graphics.lineStyle(0, c);
	graphics.drawRect(e.x*10, e.y*10, 10, 10);
	graphics.lineStyle(0, 0xffff00);
	if (e.next != null) {
	  graphics.moveTo(e.x*10+5, e.y*10+5);
	  graphics.lineTo(e.next.x*10+5, e.next.y*10+5);
	}
      }
    }
    var pc:Point = new Point((plan.x0+plan.x1)/2, (plan.y0+plan.y1)/2);
    graphics.lineStyle(0, 0x00ff00);
    graphics.drawRect(pc.x*10+2, pc.y*10+2, 6, 6);
    if (src != null) {
      graphics.lineStyle(0, 0xffffff);
      graphics.drawRect(src.x*10+2, src.y*10+2, 6, 6);
    }
  }
}

} // package
