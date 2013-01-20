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
  //[Embed(source="Skinzones.png", mimeType="image/png")]
  [Embed(source="../skins/FFSTV.png", mimeType="image/png")]
  private static const Image0Cls:Class;
  private static const image0:Bitmap = new Image0Cls();
  [Embed(source="../skins/MissBlow.png", mimeType="image/png")]
  private static const Image1Cls:Class;
  private static const image1:Bitmap = new Image1Cls();
  [Embed(source="../skins/Snarfy_Snarf.png", mimeType="image/png")]
  private static const Image2Cls:Class;
  private static const image2:Bitmap = new Image2Cls();
  [Embed(source="../skins/Deakwanda.png", mimeType="image/png")]
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
    loginit();
    stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);
    stage.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
    stage.scaleMode = StageScaleMode.NO_SCALE;
    init();
    awesomefont = new BitmapFont(awesomefontglyphs.bitmapData, awesomefontwidths);
    addChild(awesomefont.render("Video Games Awesome", 0xff0000));
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
      logger.parent.setChildIndex(logger, logger.parent.numChildren-1);
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
    if (!paused) {
      update();
    }
  }

  /// Game-related functions

  private var paused:Boolean = false;
  private var scene:Scene;
  private var tilemap:TileMap;
  private var player:Player;
  private var state:int = 0;

  private var visualizer:PlanVisualizer;

  // init()
  private function init():void
  {
    Main.log("init");

    graphics.beginFill(0x000000);
    graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
    graphics.endFill();
    
    tilemap = new TileMap(mapimage.bitmapData, blocksimage.bitmapData, 32);
    scene = new Scene(stage.stageWidth, stage.stageHeight, tilemap);

    player = new Player(scene, image0.bitmapData);
    player.bounds = tilemap.getBlockRect(3, 3);
    player.addEventListener(ActorActionEvent.ACTION, onActorAction);
    player.addEventListener(ActorActionEvent.ACTION, onPlayerAction);
    scene.add(player);

    for (var i:int = 0; i < images.length; i++) {
      var actor:Person = new Person(scene, images[i].bitmapData);
      actor.bounds = tilemap.getBlockRect(i+5, i+5);
      actor.addEventListener(ActorActionEvent.ACTION, onActorAction);
      if (i == 0) actor.setTarget(player);
      scene.add(actor);
    }

    addChild(scene);
    //playVideo(new Frage1VideoCls());
    
    visualizer = new PlanVisualizer();
    visualizer.x = 100;
    visualizer.y = 100;
    addChild(visualizer);
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

    case 80:			// P
      paused = !paused;
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
    visualizer.update(scene.actors[1].plan);
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
  public function render(text:String, color:uint=0xffffff):Bitmap
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
//  Draw a Minecraft skin centered at (0,0)
// 
class MCSkin extends Shape3D
{
  public const N:int = 8, M:int = 1;
  public const bounds:Rectangle = new Rectangle(-16, -32*2-16, 32*1, 32*4);

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

    graphics.lineStyle(0, 0xff0000);
    graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
  }
}


//  PlanEntry
//
class PlanEntry
{
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

//  PlanMap
// 
class PlanMap
{
  public var blocksize:int;
  public var center:Point;
  public var maxcost:int;
  public var x0:int, y0:int, x1:int, y1:int;
  private var width:int;
  private var a:Array;

  public function PlanMap(blocksize:int, center0:Point, width0:int, height0:int)
  {
    this.blocksize = blocksize;
    this.center = getBlockCoords(center0);
    this.maxcost = (width0+height0+1)*2;
    this.x0 = -Math.floor(width0/blocksize);
    this.y0 = -Math.floor(height0/blocksize);
    this.x1 = +Math.floor(width0/blocksize);
    this.y1 = +Math.floor(height0/blocksize);
    this.width = (x1-x0+1);
    this.a = new Array(y1-y0+1);
    for (var y:int = y0; y <= y1; y++) {
      var b:Array = new Array(width);
      for (var x:int = x0; x <= x1; x++) {
	b[x-x0] = new PlanEntry(x, y, 0, maxcost, null);
      }
      a[y-y0] = b;
    }
  }

  public function getBlockCoords(p:Point):Point
  {
    return new Point(Math.floor(p.x/blocksize), 
		     Math.floor(p.y/blocksize));
  }

  public function getBlockRect(x:int, y:int):Rectangle
  {
    return new Rectangle((x+center.x)*blocksize, (y+center.y)*blocksize, 
			 blocksize, blocksize);
  }

  public function getEntry(x:int, y:int):PlanEntry
  {
    if (x < x0 || x1 < x || y < y0 || y1 < y) return null;
    return a[y-y0][x-x0];
  }
}

//  PlanVisualizer
// 
class PlanVisualizer extends Shape
{
  public function update(plan:PlanMap):void
  {
    graphics.clear();
    graphics.beginFill(0xffffff);
    graphics.drawRect(0, 0, 10, 10);
    graphics.endFill();
    for (var y:int = plan.y0; y <= plan.y1; y++) {
      for (var x:int = plan.x0; x <= plan.x1; x++) {
	var e:PlanEntry = plan.getEntry(x, y);
	var c:int = 0x0000ff;
	switch (e.action) {
	case PlanEntry.WALK:
	  c = 0xffffff;
	  break;
	case PlanEntry.FALL:
	  c = 0x0000ff;
	  break;
	case PlanEntry.CLIMB:
	  c = 0x00ff00;
	  break;
	case PlanEntry.JUMP:
	  c = 0xff00ff;
	  break;
	default:
	  continue;
	}
	graphics.lineStyle(0, c);
	graphics.drawRect(x*10, y*10, 10, 10);
	graphics.lineStyle(0, 0xffff00);
	if (e.next != null) {
	  graphics.moveTo(x*10+5, y*10+5);
	  graphics.lineTo(e.next.x*10+5, e.next.y*10+5);
	}
      }
    }
  }
}

//  TileMap
//
class TileMap extends Bitmap
{
  public var map:BitmapData;
  public var blocks:BitmapData;
  public var blocksize:int;
  public const NOTFOUND:int = -999;

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

  // repaint(window)
  public function repaint(window:Rectangle):void
  {
    var x0:int = Math.floor(window.x/blocksize);
    var y0:int = Math.floor(window.y/blocksize);
    var mw:int = Math.floor(window.width/blocksize)+1;
    var mh:int = Math.floor(window.height/blocksize)+1;
    if (prevrect.x != x0 || prevrect.y != y0 ||
	prevrect.width != mw || prevrect.height != mh) {
      renderBlocks(x0, y0, mw, mh);
      prevrect.x = x0;
      prevrect.y = y0;
      prevrect.width = mw;
      prevrect.height = mh;
    }
    this.x = (x0*blocksize)-window.x;
    this.y = (y0*blocksize)-window.y;
  }

  // renderBlocks(x, y)
  protected function renderBlocks(x0:int, y0:int, mw:int, mh:int):void
  {
    if (bitmapData == null) {
      bitmapData = new BitmapData(mw*blocksize, 
				  mh*blocksize, 
				  true, 0x00000000);
    }
    for (var dy:int = 0; dy < mh; dy++) {
      for (var dx:int = 0; dx < mw; dx++) {
	var i:int = getBlock(x0+dx, y0+dy);
	var src:Rectangle = new Rectangle(i*blocksize, 0, blocksize, blocksize);
	var dst:Point = new Point(dx*blocksize, dy*blocksize);
	bitmapData.copyPixels(blocks, src, dst);
      }
    }
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

  // getBlock(x, y)
  private function getBlock(x:int, y:int):int
  {
    if (x < 0 || map.width <= x || 
	y < 0 || map.height <= y) {
      return -1;
    }
    var c:uint = map.getPixel(x, y);
    return pixelToBlockId(c);
  }

  // getBlockRect(x, y)
  public function getBlockRect(x:int, y:int):Rectangle
  {
    return new Rectangle(x*blocksize, y*blocksize, blocksize, blocksize);
  }

  // isobstacle
  public static var isobstacle:Function = 
    (function (b:int):Boolean { return b == 1 || b < 0; });
  // isnonobstacle
  public static var isnonobstacle:Function = 
    (function (b:int):Boolean { return !isobstacle(b); });
  // isgrabbable
  public static var isgrabbable:Function = 
    (function (b:int):Boolean { return b == 3; });
  // isstoppable
  public static var isstoppable:Function = 
    (function (b:int):Boolean { return b != 0; });
  
  // scanBlockX(r)
  public function scanBlockX(r:Rectangle, f:Function):int
  {
    var y0:int = Math.floor(r.y/blocksize);
    var y1:int = Math.floor((r.y+r.height-1)/blocksize);
    var x0:int, x1:int;
    var x:int, y:int;
    if (r.width < 0) {
      x0 = Math.floor((r.x-1)/blocksize);
      x1 = Math.floor((r.x+r.width)/blocksize);
      for (x = x0; x1 <= x; x--) {
	for (y = y0; y <= y1; y++) {
	  if (f(getBlock(x, y))) {
	    return (x+1)*blocksize;
	  }
	}
      }
    } else if (0 < r.width) {
      x0 = Math.floor(r.x/blocksize);
      x1 = Math.floor((r.x+r.width-1)/blocksize);
      for (x = x0; x <= x1; x++) {
	for (y = y0; y <= y1; y++) {
	  if (f(getBlock(x, y))) {
	    return x*blocksize;
	  }
	}
      }
    }
    return NOTFOUND;
  }

  // scanBlockY(r)
  public function scanBlockY(r:Rectangle, f:Function):int
  {
    var x0:int = Math.floor(r.x/blocksize);
    var x1:int = Math.floor((r.x+r.width-1)/blocksize);
    var y0:int, y1:int;
    var x:int, y:int;
    if (r.height < 0) {
      y0 = Math.floor((r.y-1)/blocksize);
      y1 = Math.floor((r.y+r.height)/blocksize);
      for (y = y0; y1 <= y; y--) {
	for (x = x0; x <= x1; x++) {
	  if (f(getBlock(x, y))) {
	    return (y+1)*blocksize;
	  }
	}
      }
    } else if (0 < r.height) {
      y0 = Math.floor(r.y/blocksize);
      y1 = Math.floor((r.y+r.height-1)/blocksize);
      for (y = y0; y <= y1; y++) {
	for (x = x0; x <= x1; x++) {
	  if (f(getBlock(x, y))) {
	    return y*blocksize;
	  }
	}
      }
    }
    return NOTFOUND;
  }

  private function hasBlock(x0:int, x1:int, y0:int, y1:int, f:Function):Boolean
  {
    for (var y:int = y0; y <= y1; y++) {
      for (var x:int = x0; x <= x1; x++) {
	if (f(getBlock(x, y))) return true;
      }
    }
    return false;
  }

  // createPlan(dst, b, width, height)
  public function createPlan(dst:Point, b:Rectangle, width:int, height:int):PlanMap
  {
    var plan:PlanMap = new PlanMap(blocksize, dst, width, height);
    var r0:Rectangle = plan.getBlockRect(0, 0);
    var dx0:int = Math.floor((r0.width/2+b.x)/blocksize);
    var dy0:int = Math.floor((r0.height/2+b.y)/blocksize);
    var dx1:int = Math.floor((r0.width/2+b.x+b.width-1)/blocksize);
    var dy1:int = Math.floor((r0.height/2+b.y+b.height-1)/blocksize);
    var e1:PlanEntry = plan.getEntry(0, 0);
    e1.cost = 0;
    var queue:Array = [ e1 ];
    while (0 < queue.length) {
      var e0:PlanEntry = queue.pop();
      var cost:int = e0.cost+1;
      var x0:int = e0.x+plan.center.x;
      var y0:int = e0.y+plan.center.y;
      if (hasBlock(x0+dx0, x0+dx1, y0+dy0, y0+dy1, isobstacle)) continue;

      // try walking right.
      if (plan.x0 < e0.x && isstoppable(getBlock(x0-1, y0+dy1+1))) {
	e1 = plan.getEntry(e0.x-1, e0.y);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try walking left.
      if (e0.x < plan.x1 && isstoppable(getBlock(x0+1, y0+dy1+1))) {
	e1 = plan.getEntry(e0.x+1, e0.y);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.WALK;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try falling.
      if (plan.y0 < e0.y && !isstoppable(getBlock(x0, y0+dy1))) {
	e1 = plan.getEntry(e0.x, e0.y-1);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.FALL;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing down.
      if (plan.y0 < e0.y && isgrabbable(getBlock(x0, y0+dy1))) {
	e1 = plan.getEntry(e0.x, e0.y-1);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.JUMP;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      // try climbing up.
      if (e0.y < plan.y1 && 
	  hasBlock(x0+dx0, x0+dx1, y0+dy0+1, y0+dy1+1, isgrabbable)) {
	e1 = plan.getEntry(e0.x, e0.y+1);
	if (cost < e1.cost) {
	  e1.action = PlanEntry.CLIMB;
	  e1.cost = cost;
	  e1.next = e0;
	  queue.push(e1);
	}
      }
      //queue.sortOn("cost", Array.DESCENDING);
    }
    return plan;
  }
}


//  Scene
// 
class Scene extends Sprite
{
  private var tilemap:TileMap;
  private var window:Rectangle;
  private var mapsize:Point;
  public var actors:Array = [];

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
    addChild(actor.skin);
    actors.push(actor);
  }

  // remove(actor)
  public function remove(actor:Actor):void
  {
    removeChild(actor.skin);
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
  public function setCenter(p:Point, hmargin:int, vmargin:int):void
  {
    // Center the window position.
    if (p.x-hmargin < window.x) {
      window.x = p.x-hmargin;
    } else if (window.x+window.width < p.x+hmargin) {
      window.x = p.x+hmargin-window.width;
    }
    if (p.y-vmargin < window.y) {
      window.y = p.y-vmargin;
    } else if (window.y+window.height < p.y+vmargin) {
      window.y = p.y+vmargin-window.height;
    }
    
    // Adjust the window position to fit the world.
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

  // createPlan(dst, bounds)
  public function createPlan(dst:Point, bounds:Rectangle):PlanMap
  {
    return tilemap.createPlan(dst, bounds, window.width/2, window.height/2);
  }

  // translatePoint(p)
  public function translatePoint(p:Point):Point
  {
    return new Point(p.x-window.x, p.y-window.y);
  }

  // scanBlockX(r)
  public function scanBlockX(r:Rectangle, f:Function):Boolean
  {
    return tilemap.scanBlockX(r, f) != tilemap.NOTFOUND;
  }

  // scanBlockY(r)
  public function scanBlockY(r:Rectangle, f:Function):Boolean
  {
    return tilemap.scanBlockY(r, f) != tilemap.NOTFOUND;
  }

  // getDistanceX(r)
  public function getDistanceX(src:Rectangle, vx:int, f:Function):int
  {
    var r:Rectangle; 
    var x:int = tilemap.NOTFOUND;
    if (vx < 0) {
      r = new Rectangle(src.x, src.y, vx, src.height);
      x = tilemap.scanBlockX(r, f);
    } else if (0 < vx) {
      r = new Rectangle(src.x+src.width, src.y, vx, src.height);
      x = tilemap.scanBlockX(r, f);
    }
    if (x != tilemap.NOTFOUND) {
      vx = x - r.x;
    }
    return vx;
  }

  // getDistanceY(r)
  public function getDistanceY(src:Rectangle, vy:int, f:Function):int
  {
    var r:Rectangle; 
    var y:int = tilemap.NOTFOUND;
    if (vy < 0) {
      r = new Rectangle(src.x, src.y, src.width, vy);
      y = tilemap.scanBlockY(r, f);
    } else if (0 < vy) {
      r = new Rectangle(src.x, src.y+src.height, src.width, vy);
      y = tilemap.scanBlockY(r, f);
    }
    if (y != tilemap.NOTFOUND) {
      vy = y - r.y;
    }
    return vy;
  }

  // hasLadderNearby(r)
  public function hasLadderNearby(r:Rectangle):int
  {
    var r0:Rectangle = new Rectangle(r.x, r.y, -tilemap.blocksize/2, r.height);
    var r1:Rectangle = new Rectangle(r.x+r.width, r.y, +tilemap.blocksize/2, r.height);
    var h0:Boolean = scanBlockX(r0, TileMap.isgrabbable);
    var h1:Boolean = scanBlockX(r1, TileMap.isgrabbable);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }
  }

  // hasHoleNearby(r)
  public function hasHoleNearby(r:Rectangle):int
  {
    var r0:Rectangle = new Rectangle(r.x, r.y+r.height, -tilemap.blocksize/2, 1);
    var r1:Rectangle = new Rectangle(r.x+r.width, r.y+r.height, +tilemap.blocksize/2, 1);
    var h0:Boolean = scanBlockX(r0, TileMap.isnonobstacle);
    var h1:Boolean = scanBlockX(r1, TileMap.isnonobstacle);
    if (!h0 && h1) {
      return +1;
    } else if (h0 && !h1) {
      return -1;
    } else {
      return 0;
    }    
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
  public var scene:Scene;
  public var skin:MCSkin;

  public var pos:Point;
  private var vx:int = 0, vy:int = 0, vg:int = 0;
  private var phase:Number = 0;

  public const gravity:int = 4;
  public const speed:int = 8;
  public const jumpacc:int = -40;

  public static const JUMP:String = "JUMP";
  public static const DIE:String = "DIE";

  // Actor(image)
  public function Actor(scene:Scene, image:BitmapData)
  {
    this.scene = scene;
    this.skin = new MCSkin(image);
  }

  // bounds
  public function get bounds():Rectangle
  {
    var b:Rectangle = skin.bounds;
    return new Rectangle(pos.x+b.x, pos.y+b.y, b.width, b.height);
  }
  public function set bounds(r:Rectangle):void
  {
    pos = new Point(r.x+r.width/2, r.y+r.height/2);
  }

  // move(vx, vy)
  public function move(vx:int, vy:int):void
  {
    this.vx = vx;
    this.vy = vy;
  }

  // jump()
  public function jump():void
  {
    var v:int = vg+gravity;
    if (0 < v && scene.getDistanceY(bounds, v, TileMap.isstoppable) == 0) {
      dispatchEvent(new ActorActionEvent(JUMP));
      vg = scene.getDistanceY(bounds, jumpacc, TileMap.isstoppable);
    }
  }

  // update()
  public virtual function update():void
  {
    var vx1:int = vx;
    var vy1:int = vy;
    if (vy < 0) {
      // move toward a nearby ladder.
      var vxladder:int = scene.hasLadderNearby(bounds);
      if (vxladder != 0) {
	vx1 = vxladder;
	vy1 = 0;
      }
    } else if (0 < vy) {
      // move toward a nearby hole.
      var vxhole:int = scene.hasHoleNearby(bounds);
      if (vxhole != 0) {
	vx1 = vxhole;
	vy1 = 0;
      }
    }
    pos.x += scene.getDistanceX(bounds, speed*vx1, TileMap.isobstacle);
    if (scene.scanBlockY(bounds, TileMap.isgrabbable) ||
	0 < vy1 && scene.getDistanceY(bounds, vy1, TileMap.isgrabbable) == 0) {
      // climbing
      vg = 0;
      pos.y += scene.getDistanceY(bounds, speed*vy1, TileMap.isobstacle);
    } else {
      // falling
      vg = scene.getDistanceY(bounds, vg+gravity, TileMap.isstoppable);
      pos.y += vg;
    }
    if (vx1 != 0 || vy1 != 0) {
      skin.setDirection(vx1, vy1);
    }
    if (vg == 0) {
      phase += vx1;
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
  public var plan:PlanMap;

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
  private var action:int = 1;
  public override function update():void
  {
    super.update();
    if (target != null) {
      plan = scene.createPlan(target.pos, skin.bounds);
      var p:Point = plan.getBlockCoords(pos);
      var e:PlanEntry = plan.getEntry(p.x-plan.center.x, p.y-plan.center.y);
      if (e != null) {
	//Main.log("e="+e.x+","+e.y);
      	if (e.next != null) {
	  var dx:int = e.next.x-e.x;
	  var dy:int = e.next.y-e.y;
	  if (dy < 0) { 
	    dy = -1; 
	  } else if (0 < dy) {
	    dy = +1;
	  } else if (dx < 0) { 
	    dx = -1; 
	  } else if (0 < dx) {
	    dx = +1;
	  }
	  move(dx, dy);
	}
      }
    } else {
      if (Math.random() < 0.05) {
	move(int(Math.random()*3)-1, 0);
      } else if (Math.random() < 0.05) {
	move(0, int(Math.random()*3)-1);
      } else if (Math.random() < 0.1) {
	jump();
      }
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
    scene.setCenter(pos, 200, 100);

    if (800 < bounds.y) {
      dispatchEvent(new ActorActionEvent(DIE));
    }
  }
}
