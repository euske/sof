package {

import flash.geom.Point;
import flash.geom.Rectangle;

//  Player
//
public class Player extends Actor
{
  public var dir:Point;

  // Player(image)
  public function Player(scene:Scene)
  {
    super(scene);
    dir = new Point(0, 0);
  }

  // update()
  public override function update():void
  {
    super.update();

    var v:Point = new Point(dir.x*speed, dir.y*speed);
    if (v.y < 0) {
      // move toward a nearby ladder.
      var vxladder:int = hasLadderNearby();
      if (vxladder != 0) {
	v.x = vxladder*speed;
	v.y = 0;
      }
    } else if (0 < v.y) {
      // move toward a nearby hole.
      var vxhole:int = hasHoleNearby();
      if (vxhole != 0) {
	v.x = vxhole*speed;
	v.y = 0;
      }
    }
    move(v);
    scene.setCenter(pos, 200, 100);

    if (800 < bounds.y) {
      dispatchEvent(new ActorActionEvent(DIE));
    }
  }
}

} // package
