package {

import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldType;

//  Logger
//
public class Logger extends TextField
{
  private static var logger:Logger = null;

  // Logger(width, height)
  public function Logger(width:int=400, height:int=100)
  {
    super();
    this.multiline = true;
    this.border = true;
    this.width = width;
    this.height = height;
    this.background = true;
    this.type = TextFieldType.DYNAMIC;
    addEventListener(Event.ADDED, OnAdded);
    logger = this;
  }

  // log(x)
  public static function log(x:String):void
  {
    if (logger != null) {
      logger.appendText(x+"\n");
      logger.scrollV = logger.maxScrollV;
      logger.parent.setChildIndex(logger, logger.parent.numChildren-1);
    }
  }

  protected function OnAdded(e:Event):void 
  {
    e.target.x = 0;
    e.target.y = parent.height-e.target.height;
  }
}

} // package
