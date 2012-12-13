// Main.as

package
{
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.media.Video;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.NetDataEvent;
import flash.media.Sound;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;


//  Main 
//
[SWF(width="640", height="480", backgroundColor="#ffffff", frameRate=24)]
public class Main extends Sprite
{
  // Skin image: http://www.minecraft.net/skin/USERNAME
  //[Embed(source="../../skins/skinzones.png", mimeType="image/png")]
  [Embed(source="../../skins/FFSTV.png", mimeType="image/png")]
  private static const Image0Cls:Class;
  private static const image0:Bitmap = new Image0Cls();
  [Embed(source="../../skins/MissBlow.png", mimeType="image/png")]
  private static const Image1Cls:Class;
  private static const image1:Bitmap = new Image1Cls();
  [Embed(source="../../skins/Snarfy_Snarf.png", mimeType="image/png")]
  private static const Image2Cls:Class;
  private static const image2:Bitmap = new Image2Cls();
  [Embed(source="../../skins/Deakwanda.png", mimeType="image/png")]
  private static const Image3Cls:Class;
  private static const image3:Bitmap = new Image3Cls();

  // Font
  [Embed(source="../assets/awesomefont.png", mimeType="image/png")]
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
  
  // Jump sound
  [Embed(source="../assets/jump1.mp3")]
  private static const JumpSoundCls:Class;
  private static const jump:Sound = new JumpSoundCls();

  // Video
  [Embed(source="../assets/Frage1.flv", mimeType="application/octet-stream")]
  private static const Frage1VideoCls:Class;

  // Block images: http://www.minecraftwiki.net/wiki/File:BlockCSS.png
  [Embed(source="../assets/blocks.png", mimeType="image/png")]
  private static const BlocksImageCls:Class;
  private static const blocksimage:Bitmap = new BlocksImageCls();

  [Embed(source="../assets/map.png", mimeType="image/png")]
  private static const MapImageCls:Class;
  private static const mapimage:Bitmap = new MapImageCls();

  private static const images:Array = [ image1, image2, image3 ];
  
  private static var awesomefont:BitmapFont;

  // Main()
  public function Main()
  {
    //loginit();
    //Main.log("foo!");
    stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
    stage.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
    stage.scaleMode = StageScaleMode.NO_SCALE;
    init();
    awesomefont = new BitmapFont(awesomefontglyphs.bitmapData, awesomefontwidths);
    addChild(awesomefont.render("Video Games Awesome", 0xffff0000));
  }

  /// Logging functions
  private static var logger:TextField;

  // loginit(width, height)
  private function loginit(width:int=400, height:int=100):void
  {
    logger = new TextField();
    logger.multiline = true;
    logger.border = true;
    logger.width = width;
    logger.height = height;
    logger.background = true;
    logger.type = TextFieldType.DYNAMIC;
    logger.x = 0;
    logger.y = stage.stageHeight-height;
    addChild(logger);
  }

  // log(x)
  public static function log(x:String):void
  {
    if (logger != null) {
      logger.appendText(x+"\n");
      logger.scrollV = logger.maxScrollV;
    }
  }

  // OnKeyDown(e)
  protected function OnKeyDown(e:KeyboardEvent):void 
  {
    keydown(e.keyCode);
  }

  // OnKeyUp(e)
  protected function OnKeyUp(e:KeyboardEvent):void 
  {
    keyup(e.keyCode);
  }

  // OnEnterFrame(e)
  protected function OnEnterFrame(e:Event):void
  {
    update();
  }

  /// Game-related functions

  private var scene:Scene;
  private var tilemap:TileMap;
  private var player:Player;
  private var state:int = 0;

  // init()
  private function init():void
  {
    graphics.beginFill(0xff000000);
    graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
    graphics.endFill();
    
    tilemap = new TileMap(mapimage.bitmapData, blocksimage.bitmapData, 32);
    scene = new Scene(stage.stageWidth, stage.stageHeight, tilemap);

    player = new Player(scene, image0.bitmapData);
    player.setPosition(new Point(100, 100));
    player.addEventListener(ActorActionEvent.ACTION, onActorAction);
    player.addEventListener(ActorActionEvent.ACTION, onPlayerAction);
    scene.add(player);

    for (var i:int = 0; i < images.length; i++) {
      var actor:Person = new Person(scene, images[i].bitmapData);
      actor.setPosition(new Point(i*100+200, i*100+200));
      actor.addEventListener(ActorActionEvent.ACTION, onActorAction);
      actor.setTarget(player);
      scene.add(actor);
    }

    addChild(scene);
    //playVideo(new Frage1VideoCls());
  }

  // keydown(keycode)
  private function keydown(keycode:int):void
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case 65:			// A
    case 72:			// H
      player.move(-1, 0);
      break;
    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      player.move(+1, 0);
      break;
    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      player.move(0, -1);
      break;
    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      player.move(0, +1);
      break;
    case Keyboard.SPACE:
    case 88:			// X
    case 90:			// Z
      player.jump();
      break;
    }
  }

  // keyup(keycode)
  private function keyup(keycode:int):void 
  {
    switch (keycode) {
    case Keyboard.LEFT:
    case Keyboard.RIGHT:
    case 65:			// A
    case 68:			// D
    case 72:			// H
    case 76:			// L
      player.move(0, 0);
      break;
    case Keyboard.UP:
    case Keyboard.DOWN:
    case 87:			// W
    case 75:			// K
    case 83:			// S
    case 74:			// J
      player.move(0, 0);
      break;
    }
  }

  // update()
  private function update():void
  {
    scene.update();
    scene.repaint();
  }

  // onActorAction()
  private function onActorAction(e:ActorActionEvent):void
  {
    if (e.arg == Actor.DIE) {
      scene.remove(Actor(e.currentTarget));
    }
  }

  // onPlayerAction()
  private function onPlayerAction(e:ActorActionEvent):void
  {
    if (e.arg == Actor.JUMP) {
      jump.play();
    } else if (e.arg == Actor.DIE) {
      if (state == 0) {
	state = 1;
	popupVideo(new Frage1VideoCls());
      }
    }
  }

  // popupVideo(bytes)
  private function popupVideo(bytes:ByteArray):void
  {
    var video:Video = new Video();
    var nc:NetConnection = new NetConnection();
    nc.connect(null);
    var ns:NetStream = new NetStream(nc);
    ns.addEventListener(NetStatusEvent.NET_STATUS, 
			(function (ev:NetStatusEvent):void {
			  switch (ev.info.code) {
			  case "NetStream.Buffer.Empty":
			    removeChild(video);
			    break;
			  }
			}));
    ns.play(null);
    ns.appendBytes(bytes);
    video.x = (stage.stageWidth-video.width)/2;
    video.y = (stage.stageHeight-video.height)/2;
    video.attachNetStream(ns);
    addChild(video);
  }
  
} // Main

} // package


import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.media.Sound;
import flash.ui.Keyboard;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;


//  BitmapFont
// 
class BitmapFont
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
  public function render(text:String, color:uint=0xffffffff):Bitmap
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
    return new Bitmap(data);
  }

  private function getCharWidth(c:int):int
  {
    if (widths.length <= c+1) return 0;
    return widths[c+1] - widths[c];
  }

}


//  Shape3D
// 
class Shape3D extends Shape
{
  // VX:
  public const VX:Number = 0.4;
  // VZ:
  public const VZ:Number = 0.2;

  private var skin:BitmapData;

  // Shape3D(image)
  public function Shape3D(image:BitmapData)
  {
    skin = image;
  }

  // p3d(x,y,z)
  protected function p3d(x:int, y:int, z:int):Point
  {
    // +Z: toward the screen, -Z: toward the user.
    return new Point(x+z*VX, y-z*VZ);
  }

  // quad(r, p, a, b)
  protected function quad(r:Rectangle, p:Point, a:Point, b:Point):void
  {
    var m:Matrix = new Matrix(a.x/r.width, a.y/r.width, 
			      b.x/r.height, b.y/r.height, 
			      p.x-(r.x*a.x/r.width+r.y*b.x/r.height),
			      p.y-(r.x*a.y/r.width+r.y*b.y/r.height));
    graphics.beginBitmapFill(skin, m, false);
    graphics.moveTo(p.x, p.y);
    graphics.lineTo(p.x+a.x, p.y+a.y);
    graphics.lineTo(p.x+a.x+b.x, p.y+a.y+b.y);
    graphics.lineTo(p.x+b.x, p.y+b.y);
    graphics.lineTo(p.x, p.y);
    graphics.endFill();
  }
}


//  MCSkin
// 
class MCSkin extends Shape3D
{
  public const N:int = 8, M:int = 1;

  // MCSkin(image)
  public function MCSkin(image:BitmapData)
  {
    super(image);
  }

  // setPhase(r)
  public function setPhase(r:Number):void
  {
    p0 = Math.cos(r);
    q0 = Math.sin(r);
    p1 = p0;
    q1 = -q0;
  }

  // setDirection(vx, vz)
  public function setDirection(vx:int, vz:int):void
  {
    this.vx = vx;
    this.vz = vz;
  }

  private var vx:int = 1, vz:int = 0;
  private var p0:Number = 1.0;
  private var q0:Number = 0.0;
  private var p1:Number = 1.0;
  private var q1:Number = 0.0;
  private const bounds:Rectangle = new Rectangle(-16, -32*2-16, 32*1, 32*4);

  public function get2DBounds():Rectangle
  {
    return bounds;
  }

  // repaint()
  public function repaint():void
  {
    // Skin format: http://www.minecraftwiki.net/wiki/File:Skinzones.png
    graphics.clear();

    if (vz == 0) {
      // L-arm
      if (0 < vx) {
	quad(new Rectangle(44, 20, 4, 12), // front
	     p3d(+N*p0,-N*6-N*q0,N*3), p3d(0,0,N*2), p3d(N*6*q0,N*6*p0,0));    
	quad(new Rectangle(40, 20, 4, 12), // right
	     p3d(-N*p0,-N*6+N*q0,N*3), p3d(N*2*p0,-N*2*q0,0), p3d(N*6*q0,N*6*p0,0));    
      } else {
	quad(new Rectangle(52, 20, 4, 12), // back
	     p3d(+N*p0,-N*6+N*q0,N*3), p3d(0,0,N*2), p3d(-N*6*q0,N*6*p0,0));    
	quad(new Rectangle(48, 20, 4, 12), // left
	     p3d(-N*p0,-N*6-N*q0,N*3), p3d(N*2*p0,+N*2*q0,0), p3d(-N*6*q0,N*6*p0,0));    
      }
      // L-leg
      if (0 < vx) {
	quad(new Rectangle(4, 20, 4, 12), // front
	     p3d(+N*p1,-N*q1,+N), p3d(0,0,N*2), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(0, 20, 4, 12), // right
	     p3d(-N*p1,+N*q1,+N), p3d(N*2*p1,-N*2*q1,0), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p1,+N*q1,+N), p3d(0,0,N*2), p3d(N*2*p1,-N*2*q1,0));
      } else {
	quad(new Rectangle(12, 20, 4, 12), // back
	     p3d(+N*p1,+N*q1,+N), p3d(0,0,N*2), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(8, 20, 4, 12), // left
	     p3d(-N*p1,-N*q1,+N), p3d(N*2*p1,N*2*q1,0), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p1,-N*q1,+N), p3d(0,0,N*2), p3d(N*2*p1,+N*2*q1,0));
      }
      // R-leg
      if (0 < vx) {
	quad(new Rectangle(4, 20, 4, 12), // front
	     p3d(+N*p0,-N*q0,-N), p3d(0,0,N*2), p3d(N*6*q0,N*6*p0,0));    
	quad(new Rectangle(0, 20, 4, 12), // right
	     p3d(-N*p0,+N*q0,-N), p3d(N*2*p0,-N*2*q0,0), p3d(N*6*q0,N*6*p0,0));
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p0,+N*q0,-N), p3d(0,0,N*2), p3d(N*2*p0,-N*2*q0,0));
      } else {
	quad(new Rectangle(12, 20, 4, 12), // back
	     p3d(+N*p0,+N*q0,-N), p3d(0,0,N*2), p3d(-N*6*q0,N*6*p0,0));    
	quad(new Rectangle(8, 20, 4, 12), // left
	     p3d(-N*p0,-N*q0,-N), p3d(N*2*p0,N*2*q0,0), p3d(-N*6*q0,N*6*p0,0));    
	quad(new Rectangle(4, 16, 4, 4), // top
	     p3d(-N*p0,-N*q0,-N), p3d(0,0,N*2), p3d(N*2*p0,+N*2*q0,0));
      }
      // body
      if (0 < vx) {
	quad(new Rectangle(20, 20, 8, 12), // front
	     p3d(+N,-N*6,-N), p3d(0,0,N*4), p3d(0,N*6,0));
	quad(new Rectangle(16, 20, 4, 12), // right
	     p3d(-N,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));
      } else {
	quad(new Rectangle(32, 20, 8, 12), // back
	     p3d(+N,-N*6,-N), p3d(0,0,N*4), p3d(0,N*6,0));
	quad(new Rectangle(28, 20, 4, 12), // left
	     p3d(-N,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));
      }

      // head
      if (0 < vx) {
	quad(new Rectangle(8, 8, 8, 8), // front
	     p3d(+N*2,-N*10,-N), p3d(0,0,N*4), p3d(0,N*4,0));
	quad(new Rectangle(0, 8, 8, 8), // right
	     p3d(-N*2,-N*10,-N), p3d(N*4,0,0), p3d(0,N*4,0));
	quad(new Rectangle(8, 0, 8, 8), // top
	     p3d(-N*2,-N*10,-N), p3d(0,0,N*4), p3d(N*4,0,0));
      } else {
	quad(new Rectangle(24, 8, 8, 8), // back
	     p3d(+N*2,-N*10,-N), p3d(0,0,N*4), p3d(0,N*4,0));
	quad(new Rectangle(16, 8, 8, 8), // left
	     p3d(-N*2,-N*10,-N), p3d(N*4,0,0), p3d(0,N*4,0));
	quad(new Rectangle(8, 0, 8, 8), // top
	     p3d(+N*2,-N*10,-N), p3d(0,0,N*4), p3d(-N*4,0,0));
      }
      // mask
      if (0 < vx) {
	quad(new Rectangle(40, 8, 8, 8), // front
	     p3d(+N*2+M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
	quad(new Rectangle(32, 8, 8, 8), // right
	     p3d(-N*2-M,-N*10-M,-N-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
	quad(new Rectangle(40, 0, 8, 8), // top
	     p3d(-N*2-M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(N*4+M*2,0,0));
      } else {
	quad(new Rectangle(56, 8, 8, 8), // back
	     p3d(+N*2+M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
	quad(new Rectangle(48, 8, 8, 8), // left
	     p3d(-N*2-M,-N*10-M,-N-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
	quad(new Rectangle(40, 0, 8, 8), // top
	     p3d(+N*2+M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(-N*4-M*2,0,0));
      }
      // R-arm
      if (0 < vx) {
	quad(new Rectangle(44, 20, 4, 12), // front
	     p3d(+N*p1,-N*6-N*q1,-N*3), p3d(0,0,N*2), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(40, 20, 4, 12), // right
	     p3d(-N*p1,-N*6+N*q1,-N*3), p3d(N*2*p1,-N*2*q1,0), p3d(N*6*q1,N*6*p1,0));    
	quad(new Rectangle(44, 16, 4, 4), // top
	     p3d(-N*p1,-N*6+N*q1,-N*3), p3d(0,0,N*2), p3d(N*2*p1,-N*2*q1,0));
      } else {
	quad(new Rectangle(52, 20, 4, 12), // back
	     p3d(+N*p1,-N*6+N*q1,-N*3), p3d(0,0,N*2), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(48, 20, 4, 12), // left
	     p3d(-N*p1,-N*6-N*q1,-N*3), p3d(N*2*p1,+N*2*q1,0), p3d(-N*6*q1,N*6*p1,0));    
	quad(new Rectangle(44, 16, 4, 4), // top
	     p3d(-N*p1,-N*6-N*q1,-N*3), p3d(0,0,N*2), p3d(N*2*p1,N*2*q1,0));
      }
    } else if (0 < vz) {
      // R-leg
      quad(new Rectangle(4, 20, 4, 12), // front
	   p3d(-N*2,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      // L-leg
      quad(new Rectangle(4, 20, 4, 12), // front
	   p3d(0,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(8, 20, 4, 12), // right
	   p3d(+N*2,0,-N), p3d(0,0,N*2), p3d(0,N*6,0));
      // R-arm
      quad(new Rectangle(44, 20, 4, 12), // front
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));
      // body
      quad(new Rectangle(20, 20, 8, 12), // front
	   p3d(-N*2,-N*6,-N), p3d(N*4,0,0), p3d(0,N*6,0));
      // L-arm
      quad(new Rectangle(44, 20, 4, 12), // front
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    	   
      quad(new Rectangle(48, 20, 4, 12), // right
	   p3d(+N*4,-N*6,-N), p3d(0,0,N*2), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));
      // head
      quad(new Rectangle(8, 8, 8, 8), // front
	   p3d(-N*2,-N*10,-N*2), p3d(N*4,0,0), p3d(0,N*4,0));
      quad(new Rectangle(16, 8, 8, 8), // right
	   p3d(+N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(0,N*4,0));
      quad(new Rectangle(8, 0, 8, 8), // top
	   p3d(-N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(N*4,0,0));
      // mask
      quad(new Rectangle(40, 8, 8, 8), // front
	   p3d(-N*2-M,-N*10-M,-N*2-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
      quad(new Rectangle(48, 8, 8, 8), // right
	   p3d(+N*2+M,-N*10-M,-N*2-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
      quad(new Rectangle(40, 0, 8, 8), // top
	   p3d(-N*2-M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(N*4+M*2,0,0));
      
    } else if (vz < 0) {
      // L-leg
      quad(new Rectangle(12, 20, 4, 12), // front
	   p3d(-N*2,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      // R-leg
      quad(new Rectangle(12, 20, 4, 12), // front
	   p3d(0,0,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(0, 20, 4, 12), // right
	   p3d(+N*2,0,-N), p3d(0,0,N*2), p3d(0,N*6,0));
      // L-arm
      quad(new Rectangle(52, 20, 4, 12), // front
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(-N*4,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));
      // body
      quad(new Rectangle(32, 20, 8, 12), // front
	   p3d(-N*2,-N*6,-N), p3d(N*4,0,0), p3d(0,N*6,0));
      // R-arm
      quad(new Rectangle(52, 20, 4, 12), // front
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,N*6,0));    	   
      quad(new Rectangle(40, 20, 4, 12), // right
	   p3d(+N*4,-N*6,-N), p3d(0,0,N*2), p3d(0,N*6,0));    
      quad(new Rectangle(44, 16, 4, 4), // top
	   p3d(+N*2,-N*6,-N), p3d(N*2,0,0), p3d(0,0,N*2));      
      // head
      quad(new Rectangle(24, 8, 8, 8), // front
	   p3d(-N*2,-N*10,-N*2), p3d(N*4,0,0), p3d(0,N*4,0));
      quad(new Rectangle(0, 8, 8, 8), // right
	   p3d(+N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(0,N*4,0));
      quad(new Rectangle(8, 0, 8, 8), // top
	   p3d(-N*2,-N*10,-N*2), p3d(0,0,N*4), p3d(N*4,0,0));
      // mask
      quad(new Rectangle(56, 8, 8, 8), // front
	   p3d(-N*2-M,-N*10-M,-N*2-M), p3d(N*4+M*2,0,0), p3d(0,N*4+M*2,0));
      quad(new Rectangle(32, 8, 8, 8), // right
	   p3d(+N*2+M,-N*10-M,-N*2-M), p3d(0,0,N*4+M*2), p3d(0,N*4+M*2,0));
      quad(new Rectangle(40, 0, 8, 8), // top
	   p3d(-N*2-M,-N*10-M,-N-M), p3d(0,0,N*4+M*2), p3d(N*4+M*2,0,0));
    }

    graphics.lineStyle(0, 0xffff0000);
    graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
}


//  TileMap
//
class TileMap extends Bitmap
{
  public var map:BitmapData;
  public var blocks:BitmapData;
  public var blocksize:int;

  private var prevrect:Rectangle;

  // TileMap(map, blocks, blocksize, width, height)
  public function TileMap(map:BitmapData, 
			  blocks:BitmapData,
			  blocksize:int)
  {
    this.map = map;
    this.blocks = blocks;
    this.blocksize = blocksize;
    this.prevrect = new Rectangle(-1,-1,0,0);
  }

  // mapwidth
  public function get mapwidth():int
  {
    return map.width;
  }
  // mapheight
  public function get mapheight():int
  {
    return map.height;
  }

  // getBlockAt(x, y)
  public function getBlockAt(x:int, y:int):int
  {
    var c:uint = map.getPixel(x, y);
    return pixelToBlockId(c);
  }

  // getBlock(r)
  public function getBlock(r:Rectangle):int
  {
    return getBlockAt((r.x+r.width/2)/blocksize,
		      (r.y+r.height/2)/blocksize);
  }

  // scanBlock(r)
  public function scanBlock(r:Rectangle, f:Function):Boolean
  {
    var x0:int = r.x/blocksize;
    var x1:int = (r.x+r.width-1)/blocksize;
    var y0:int = r.y/blocksize;
    var y1:int = (r.y+r.height-1)/blocksize;
    var x:int, y:int;
    for (y = y0; y <= y1; y++) {
      for (x = x0; x <= x1; x++) {
	if (f(getBlockAt(x, y))) return true;
      }
    }
    return false;
  }

  // scanBlockX(r)
  public function scanBlockX(r:Rectangle, f:Function):int
  {
    var y0:int = r.y/blocksize;
    var y1:int = (r.y+r.height-1)/blocksize;
    var x0:int, x1:int;
    var x:int, y:int;
    if (r.width < 0) {
      x0 = (r.x-1)/blocksize;
      x1 = (r.x+r.width)/blocksize;
      for (x = x0; x1 <= x; x--) {
	if (x <= 0) return 0;
	for (y = y0; y <= y1; y++) {
	  if (f(getBlockAt(x, y))) {
	    return (x+1)*blocksize;
	  }
	}
      }
    } else if (0 < r.width) {
      x0 = r.x/blocksize;
      x1 = (r.x+r.width-1)/blocksize;
      for (x = x0; x <= x1; x++) {
	if (map.width <= x) return map.width*blocksize;
	for (y = y0; y <= y1; y++) {
	  if (f(getBlockAt(x, y))) {
	    return x*blocksize;
	  }
	}
      }
    }
    return -1;
  }

  // scanBlockY(r)
  public function scanBlockY(r:Rectangle, f:Function):int
  {
    var x0:int = r.x/blocksize;
    var x1:int = (r.x+r.width-1)/blocksize;
    var y0:int, y1:int;
    var x:int, y:int;
    if (r.height < 0) {
      y0 = (r.y-1)/blocksize;
      y1 = (r.y+r.height)/blocksize;
      for (y = y0; y1 <= y; y--) {
	if (y <= 0) return 0;
	for (x = x0; x <= x1; x++) {
	  if (f(getBlockAt(x, y))) {
	    return (y+1)*blocksize;
	  }
	}
      }
    } else if (0 < r.height) {
      y0 = r.y/blocksize;
      y1 = (r.y+r.height-1)/blocksize;
      for (y = y0; y <= y1; y++) {
	if (map.height <= y) return map.height*blocksize;
	for (x = x0; x <= x1; x++) {
	  if (f(getBlockAt(x, y))) {
	    return y*blocksize;
	  }
	}
      }
    }
    return -1;
  }

  // repaint(window)
  public function repaint(window:Rectangle):void
  {
    var x:int = int(window.x/blocksize);
    var y:int = int(window.y/blocksize);
    var mw:int = int(window.width/blocksize)+1;
    var mh:int = int(window.height/blocksize)+1;
    renderBlocks(x, y, mw, mh);
    this.x = (x*blocksize)-window.x;
    this.y = (y*blocksize)-window.y;
  }

  // renderBlocks(x, y)
  protected function renderBlocks(x0:int, y0:int, mw:int, mh:int):void
  {
    if (prevrect.x == x0 && prevrect.y == y0 &&
	prevrect.width == mw && prevrect.height == mh) return;
    if (bitmapData == null) {
      bitmapData = new BitmapData(mw*blocksize, 
				  mh*blocksize, 
				  true, 0x00000000);
    }
    for (var dy:int = 0; dy < mh; dy++) {
      for (var dx:int = 0; dx < mw; dx++) {
	var i:int = getBlockAt(x0+dx, y0+dy);
	var src:Rectangle = 
	  new Rectangle(i*blocksize, 0, blocksize, blocksize);
	var dst:Point = 
	  new Point(dx*blocksize, dy*blocksize);
	bitmapData.copyPixels(blocks, src, dst);
      }
    }
    prevrect.x = x0;
    prevrect.y = y0;
    prevrect.width = mw;
    prevrect.height = mh;
  }

  // pixelToBlockId(c)
  protected function pixelToBlockId(c:uint):int
  {
    switch (c) {
    case 0x000000: // 0
      return 0;
    case 0x404040: // 1
      return 1;
    case 0xff0000: // 2
      return 2;
    case 0xff6a00: // 3
      return 3;
    case 0xffd800: // 4
      return 4;
    case 0xb6ff00: // 5
      return 5;
    case 0x4cff00: // 6
      return 6;
    case 0x00ff21: // 7
      return 7;
    case 0x00ff90: // 8
      return 8;
    case 0x00ffff: // 9
      return 9;
    case 0x0094ff: // 10
      return 10;
    case 0x0026ff: // 11
      return 11;
    case 0x4800ff: // 12
      return 12;
    case 0xb200ff: // 13
      return 13;
    case 0xff00dc: // 14
      return 14;
    case 0xff006e: // 15
      return 15;
    case 0xffffff: // 16
      return 16;
    case 0x808080: // 17
      return 17;
    case 0x7f0000: // 18
      return 18;
    case 0x7f3300: // 19
      return 19;
    case 0x7f6a00: // 20
      return 20;
    case 0x5b7f00: // 21
      return 21;
    case 0x267f00: // 22
      return 22;
    case 0x007f0e: // 23
      return 23;
    case 0x007f46: // 24
      return 24;
    case 0x007f7f: // 25
      return 25;
    case 0x004a7f: // 26
      return 26;
    case 0x00137f: // 27
      return 27;
    case 0x21007f: // 28
      return 28;
    case 0x57007f: // 29
      return 29;
    case 0x7f006e: // 30
      return 30;
    case 0x7f0037: // 31
      return 31;
    default:
      return 0;
    }
  }
}


//  Scene
// 
class Scene extends Sprite
{
  private var tilemap:TileMap;
  private var window:Rectangle;
  private var mapsize:Point;
  private var actors:Array = [];

  // Scene(width, height, tilemap)
  public function Scene(width:int, height:int, tilemap:TileMap)
  {
    this.window = new Rectangle(0, 0, width, height);
    this.tilemap = tilemap;
    this.mapsize = new Point(tilemap.mapwidth*tilemap.blocksize,
			     tilemap.mapheight*tilemap.blocksize);
    addChild(tilemap);
  }

  // add(actor)
  public function add(actor:Actor):void
  {
    addChild(actor.getSkin());
    actors.push(actor);
  }

  // remove(actor)
  public function remove(actor:Actor):void
  {
    removeChild(actor.getSkin());
    actors.splice(actors.indexOf(actor), 1);
  }

  // update()
  public function update():void
  {
    for each (var actor:Actor in actors) {
      actor.update();
    }
  }

  // repaint()
  public function repaint():void
  {
    for each (var actor:Actor in actors) {
      actor.repaint();
    }
    tilemap.repaint(window);
  }

  // setCenter(p)
  public function setCenter(p:Point, margin:int):void
  {
    if (p.x-margin < window.x) {
      window.x = p.x-margin;
    } else if (window.x+window.width < p.x+margin) {
      window.x = p.x+margin-window.width;
    }
    if (p.y-margin < window.y) {
      window.y = p.y-margin;
    } else if (window.y+window.height < p.y+margin) {
      window.y = p.y+margin-window.height;
    }
    
    if (window.x < 0) {
      window.x = 0;
    } else if (mapsize.x < window.x+window.width) {
      window.x = mapsize.x-window.width;
    }
    if (window.y < 0) {
      window.y = 0;
    } else if (mapsize.y < window.y+window.height) {
      window.y = mapsize.y-window.height;
    }
  }

  // translatePoint(p)
  public function translatePoint(p:Point):Point
  {
    return new Point(p.x-window.x, p.y-window.y);
  }

  // scanBlock(r)
  public function scanBlock(r:Rectangle, f:Function):Boolean
  {
    return tilemap.scanBlock(r, f);
  }

  // getCollisionX(r)
  public function getCollisionX(src:Rectangle, vx:int, isobstacle:Function):int
  {
    var r:Rectangle; 
    var x:int = -1;
    if (vx < 0) {
      r = new Rectangle(src.x, src.y, vx, src.height);
      x = tilemap.scanBlockX(r, isobstacle);
    } else if (0 < vx) {
      r = new Rectangle(src.x+src.width, src.y, vx, src.height);
      x = tilemap.scanBlockX(r, isobstacle);
    }
    if (x != -1) {
      vx = x - r.x;
    }
    return vx;
  }

  // getCollisionY(r)
  public function getCollisionY(src:Rectangle, vy:int, isobstacle:Function):int
  {
    var r:Rectangle; 
    var y:int = -1;
    if (vy < 0) {
      r = new Rectangle(src.x, src.y, src.width, vy);
      y = tilemap.scanBlockY(r, isobstacle);
    } else if (0 < vy) {
      r = new Rectangle(src.x, src.y+src.height, src.width, vy);
      y = tilemap.scanBlockY(r, isobstacle);
    }
    if (y != -1) {
      vy = y - r.y;
    }
    return vy;
  }
}


//  ActorActionEvent
// 
class ActorActionEvent extends Event
{
  public static const ACTION:String = "ACTION";

  public var arg:String;

  public function ActorActionEvent(arg:String)
  {
    super(ACTION);
    this.arg = arg;
  }
}


//  Actor
//
class Actor extends EventDispatcher
{
  protected var scene:Scene;
  protected var skin:MCSkin;
  protected var pos:Point;

  protected var vx:int = 0, vy:int = 0, vh:int = 0;
  protected var phase:Number = 0;
  protected var jumping:Boolean;

  public const gravity:int = 4;
  public const speed:int = 8;
  public const jumpacc:int = -36;

  public static const JUMP:String = "JUMP";
  public static const DIE:String = "DIE";

  // Actor(image)
  public function Actor(scene:Scene, image:BitmapData)
  {
    this.scene = scene;
    this.skin = new MCSkin(image);
  }

  // getSkin()
  public function getSkin():Shape
  {
    return skin;
  }

  // getBounds()
  public function getBounds():Rectangle
  {
    var r:Rectangle = skin.get2DBounds();
    return new Rectangle(pos.x+r.x, pos.y+r.y, r.width, r.height);
  }

  // setPosition()
  public function setPosition(p:Point):void
  {
    pos = p;
  }

  // move(dx, dy)
  public function move(dx:int, dy:int):void
  {
    if (dx != 0 || dy != 0) {
      skin.setDirection(dx, dy);
    }
    vx = dx*speed;
    vh = dy*speed;
  }

  // jump()
  public function jump():void
  {
    jumping = true;
  }

  // getCollisionX(vx, f)
  public function getCollisionX(vx:int, f:Function):int
  {
    return scene.getCollisionX(getBounds(), vx, f);
  }
  
  // getCollisionY(vy, f)
  public function getCollisionY(vy:int, f:Function):int
  {
    return scene.getCollisionY(getBounds(), vy, f);
  }

  // update()
  public virtual function update():void
  {
    var isobstacle:Function = (function (b:int):Boolean { return b == 1; });
    var isgrabbable:Function = (function (b:int):Boolean { return b == 3; });
    var isstoppable:Function = (function (b:int):Boolean { return b != 0; });
    if (scene.scanBlock(getBounds(), isgrabbable)) {
      // climbing
      vy = getCollisionY(vh, isobstacle);
    } else {
      // falling
      var vy1:int = vy+gravity;
      if (jumping && 0 < vy1 && 
	  getCollisionY(vy1, isstoppable) == 0 &&
	  getCollisionY(jumpacc, isstoppable) < 0) {
	vy = jumpacc;
	dispatchEvent(new ActorActionEvent(JUMP));
      } else {
	vy = vy1;
      }
      vy = getCollisionY(vy, isstoppable);
    }
    jumping = false;
    pos.y += vy;
    pos.x += getCollisionX(vx, isobstacle);
    if (vx != 0) {
      phase += Math.abs(vx)*0.1;
      skin.setPhase(Math.cos(phase)*0.5);
    }
  }

  // repaint()
  public virtual function repaint():void
  {
    var p:Point = scene.translatePoint(pos);
    skin.x = p.x;
    skin.y = p.y;
    skin.repaint();
  }
}


//  Person
//
class Person extends Actor
{
  private var target:Actor;

  // Person(image)
  public function Person(scene:Scene, image:BitmapData)
  {
    super(scene, image);
    move(int(Math.random()*3)-1, 0);
  }

  // setTarget(actor)
  public function setTarget(actor:Actor):void
  {
    target = actor;
  }

  // update()
  public override function update():void
  {
    super.update();
    if (Math.random() < 0.05) {
      move(int(Math.random()*3)-1, 0);
    } else if (Math.random() < 0.1) {
      jump();
    }
  }
}


//  Player
//
class Player extends Actor
{
  // Player(image)
  public function Player(scene:Scene, image:BitmapData)
  {
    super(scene, image);
  }

  // update()
  public override function update():void
  {
    super.update();
    scene.setCenter(pos, 200);
    if (800 < pos.y) {
      dispatchEvent(new ActorActionEvent(DIE));
    }
  }
}
