package {

//  PlanEntry
//
public class PlanEntry
{
  public static const NONE:String = "NONE";
  public static const WALK:String = "WALK";
  public static const FALL:String = "FALL";
  public static const CLIMB:String = "CLIMB";
  public static const JUMP:String = "JUMP";

  public var x:int, y:int;
  public var action:String;
  public var cost:int;
  public var next:PlanEntry;
  public function PlanEntry(x:int, y:int, action:String, cost:int, next:PlanEntry)
  {
    this.x = x;
    this.y = y;
    this.action = action;
    this.cost = cost;
    this.next = next;
  }

  public function toString():String
  {
    return ("<PlanEntry: ("+x+","+y+") action="+action+", cost="+cost+">");
  }
}

} // package
