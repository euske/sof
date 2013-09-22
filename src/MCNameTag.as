package {

import flash.display.Sprite;
import flash.display.Bitmap;
import AwesomeFont;

//  MCNameTag
//
public class MCNameTag extends Sprite
{
  public static var font:AwesomeFont = new AwesomeFont();

  public const scale:int = 2;
  public const marginWidth:int = 1;

  public function MCNameTag()
  {
  }
  
  // text
  public function set text(value:String):void
  {
    graphics.clear();
    removeChildren();
    if (value != null) {
      var w:int = font.getTextWidth(value);
      graphics.beginFill(0x000000, 0.5);
      graphics.drawRect(0, 0, 
			w*scale + marginWidth*2,
			font.height*scale + marginWidth*2);
      graphics.endFill();

      var glyphs:Bitmap = font.render(value, 0xffffff, scale);
      glyphs.x = marginWidth;
      glyphs.y = marginWidth;
      addChild(glyphs);
    }
  }
}

} // package
