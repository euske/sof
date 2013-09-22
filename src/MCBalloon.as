package {

import flash.display.Sprite;
import flash.display.Bitmap;
import AwesomeFont;

//  MCBalloon
//
public class MCBalloon extends Sprite
{
  private static var font:AwesomeFont = new AwesomeFont();

  public const scale:int = 2;
  public const marginWidth:int = 10;
  public const cornerWidth:int = 10;

  public function MCBalloon()
  {
  }

  // text
  public function set text(value:String):void
  {
    graphics.clear();
    removeChildren();
    if (value != null) {
      var w:int = font.getTextWidth(value);
      graphics.lineStyle(4, 0xffffff);
      graphics.beginFill(0x444444);
      graphics.drawRoundRect(0, 0, 
			     w*scale + marginWidth*2,
			     font.height*scale + marginWidth*2,
			     cornerWidth, cornerWidth);
      graphics.endFill();

      var glyphs:Bitmap = font.render(value, 0xffff00, scale);
      glyphs.x = marginWidth;
      glyphs.y = marginWidth;
      addChild(glyphs);
    }
  }
}

} // package
