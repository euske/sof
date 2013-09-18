package {

import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

//  PlanVisualizer
// 
public class PlanVisualizer extends Shape
{
  public static var main:PlanVisualizer;

  public var src:Point;
  public var plan:PlanMap;
  public var tilemap:TileMap;

  public function PlanVisualizer(tilemap:TileMap)
  {
    super();
    main = this;
    this.tilemap = tilemap;
  }

  public function repaint():void
  {
    graphics.clear();
    if (plan == null) return;

    var ts:int = tilemap.tilesize;
    var tw:Rectangle = tilemap.tilewindow;
    for (var y:int = 0; y < tw.height; y++) {
      for (var x:int = 0; x <= tw.width; x++) {
	var e:PlanEntry = plan.getEntry(tw.x+x, tw.y+y);
	if (e == null) continue;
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
	graphics.drawRect((e.x-tw.x)*ts, (e.y-tw.y)*ts, ts, ts);
	graphics.lineStyle(0, 0xffff00);
	if (e.next != null) {
	  graphics.moveTo((e.x-tw.x)*ts+ts/2, (e.y-tw.y)*ts+ts/2);
	  graphics.lineTo((e.next.x-tw.x)*ts+ts/2, (e.next.y-tw.y)*ts+ts/2);
	}
      }
    }
    var pc:Point = new Point((plan.x0+plan.x1)/2, (plan.y0+plan.y1)/2);
    graphics.lineStyle(0, 0x00ff00);
    graphics.drawRect((pc.x-tw.x)*ts+2, (pc.y-tw.y)*ts+2, ts-4, ts-4);
    if (src != null) {
      graphics.lineStyle(0, 0xffffff);
      graphics.drawRect((src.x-tw.x)*ts+2, (src.y-tw.y)*ts+2, ts-4, ts-4);
    }

    this.x = tilemap.x;
    this.y = tilemap.y;
  }
}

} // package
