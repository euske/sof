package SOF {

import flash.events.Event;

//  ActorActionEvent
// 
public class ActorActionEvent extends Event
{
  public static const ACTION:String = "ACTION";

  public var arg:String;

  public function ActorActionEvent(arg:String)
  {
    super(ACTION);
    this.arg = arg;
  }
}

}
