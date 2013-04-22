package {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;

//  BitmapFont
// 
public class BitmapFont
{
  private var glyphs:BitmapData;
  private var widths:Array;

  // height
  //   The height of this font.
  public var height:int;

  // BitmapFont(glyphs, widths)
  public function BitmapFont(glyphs:BitmapData, widths:Array)
  {
    this.glyphs = glyphs;
    this.height = glyphs.height;
    this.widths = widths;
  }

  // getTextWidth(text)
  //   Returns a width of a given string.
  public function getTextWidth(text:String):int
  {
    var w:int = 0;
    for (var i:int = 0; i < text.length; i++) {
      w += getCharWidth(text.charCodeAt(i));
    }
    return w;
  }

  // render(text, color)
  //   Creates a Bitmap with a given string rendered.
  public function render(text:String, color:uint=0xffffff, scale:int=1):Bitmap
  {
    var width:int = getTextWidth(text);
    var data:BitmapData = new BitmapData(width, height, true, 0xffffffff);
    var x:int = 0;
    for (var i:int = 0; i < text.length; i++) {
      var c:int = text.charCodeAt(i);
      if (widths.length <= c+1) continue;
      var w:int = getCharWidth(c);
      var src:Rectangle = new Rectangle(widths[c], 0, w, height);
      data.copyPixels(glyphs, src, new Point(x, 0));
      x += w;
    }
    var ct:ColorTransform = new ColorTransform();
    ct.color = color;
    data.colorTransform(data.rect, ct);
    var bitmap:Bitmap = new Bitmap(data);
    bitmap.width *= scale;
    bitmap.height *= scale;
    return bitmap;
  }

  private function getCharWidth(c:int):int
  {
    if (widths.length <= c+1) return 0;
    return widths[c+1] - widths[c];
  }

}

} // package
