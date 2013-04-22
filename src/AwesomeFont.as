package SOF {

import flash.display.Bitmap;
import SOF.BitmapFont;

//  AwesomeFont
// 
public class AwesomeFont extends BitmapFont
{
  [Embed(source="../../assets/awesomefont.png", mimeType="image/png")]
  private static const AwesomeFontGlyphsCls:Class;
  private static const awesomefontglyphs:Bitmap = new AwesomeFontGlyphsCls();
  private static const awesomefontwidths:Array = [
      0, 0, 0, 0, 0, 0, 0, 0,						  
      0, 0, 0, 0, 0, 0, 0, 0,						  
      0, 0, 0, 0, 0, 0, 0, 0,						  
      0, 0, 0, 0, 0, 0, 0, 0,						  
      0, 4, 6, 10, 16, 20, 29, 36, 
      38, 42, 46, 52, 58, 61, 67, 69, 
      76, 80, 84, 88, 92, 96, 100, 104, 
      108, 112, 116, 118, 121, 126, 132, 137, 
      141, 149, 155, 161, 167, 173, 178, 184, 
      190, 196, 202, 208, 214, 220, 228, 234, 
      240, 246, 253, 259, 265, 273, 279, 285, 
      293, 301, 307, 313, 315, 322, 326, 332, 
      338, 348, 353, 357, 362, 366, 371, 376, 
      380, 384, 386, 390, 394, 396, 402, 406, 
      411, 415, 420, 425, 429, 433, 438, 442, 
      448, 452, 456, 461, 465, 474, 479, 489];

  public function AwesomeFont()
  {
    super(awesomefontglyphs.bitmapData, awesomefontwidths);
  }
}

}
