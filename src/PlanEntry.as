package SOF {

//  PlanEntry
//
public class PlanEntry
{
  public static const NONE:int = 0;
  public static const WALK:int = 1;
  public static const FALL:int = 2;
  public static const CLIMB:int = 3;
  public static const JUMP:int = 4;

  public var x:int, y:int;
  public var action:int;
  public var cost:int;
  public var next:PlanEntry;
  public function PlanEntry(x:int, y:int, action:int, cost:int, next:PlanEntry)
  {
    this.x = x;
    this.y = y;
    this.action = action;
    this.cost = cost;
    this.next = next;
  }
}

}
