package {

import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageScaleMode;
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.AsyncErrorEvent;
import flash.text.TextField;
import flash.text.TextFieldType;
import flash.ui.Keyboard;
import flash.utils.ByteArray;
import flash.media.Sound;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

//  Main 
//
[SWF(width="640", height="480", backgroundColor="#000000", frameRate=24)]
public class Main extends Sprite
{
  // Background image: 
  //[Embed(source="../assets/background.png", mimeType="image/png")]
  //private static const BackgroundCls:Class;
  //private static const background:Bitmap = new BackgroundCls();
  
  // Skin image: http://www.minecraft.net/skin/USERNAME
  //[Embed(source="Skinzones.png", mimeType="image/png")]
  [Embed(source="../assets/skins/FFSTV.png", mimeType="image/png")]
  private static const Image0Cls:Class;
  private static const image0:Bitmap = new Image0Cls();
  [Embed(source="../assets/skins/MissBlow.png", mimeType="image/png")]
  private static const Image1Cls:Class;
  private static const image1:Bitmap = new Image1Cls();
  [Embed(source="../assets/skins/Snarfy_Snarf.png", mimeType="image/png")]
  private static const Image2Cls:Class;
  private static const image2:Bitmap = new Image2Cls();
  [Embed(source="../assets/skins/Deakwanda.png", mimeType="image/png")]
  private static const Image3Cls:Class;
  private static const image3:Bitmap = new Image3Cls();

  // Jump sound
  [Embed(source="../assets/jump1.mp3")]
  private static const JumpSoundCls:Class;
  private static const jump:Sound = new JumpSoundCls();

  // Video
  [Embed(source="../assets/Frage1.flv", mimeType="application/octet-stream")]
  private static const Frage1VideoCls:Class;

  // Tile images: http://www.minecraftwiki.net/wiki/File:BlockCSS.png
  [Embed(source="../assets/tiles.png", mimeType="image/png")]
  private static const TilesImageCls:Class;
  private static const tilesimage:Bitmap = new TilesImageCls();

  [Embed(source="../assets/map.png", mimeType="image/png")]
  private static const MapImageCls:Class;
  private static const mapimage:Bitmap = new MapImageCls();

  private static const images:Array = [ image1, image2, image3 ];

  private static var _logger:TextField;

  private var _paused:Boolean = false;
  private var _keydown:int;

  // Main()
  public function Main()
  {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.addEventListener(Event.ACTIVATE, OnActivate);
    stage.addEventListener(Event.DEACTIVATE, OnDeactivate);
    stage.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
    stage.addEventListener(KeyboardEvent.KEY_DOWN, OnKeyDown);
    stage.addEventListener(KeyboardEvent.KEY_UP, OnKeyUp);

    _logger = new TextField();
    _logger.multiline = true;
    _logger.border = true;
    _logger.width = 400;
    _logger.height = 100;
    _logger.background = true;
    _logger.type = TextFieldType.DYNAMIC;
    addChild(_logger);

    init();
  }

  // log(x)
  public static function log(x:String):void
  {
    _logger.appendText(x+"\n");
    _logger.scrollV = _logger.maxScrollV;
    if (_logger.parent != null) {
      _logger.parent.setChildIndex(_logger, _logger.parent.numChildren-1);
    }
  }

  // setPauseState(paused)
  private function setPauseState(paused:Boolean):void
  {
    _paused = paused;
  }

  // OnActivate(e)
  protected function OnActivate(e:Event):void
  {
    setPauseState(false);
  }

  // OnDeactivate(e)
  protected function OnDeactivate(e:Event):void
  {
    setPauseState(true);
  }

  // OnEnterFrame(e)
  protected function OnEnterFrame(e:Event):void
  {
    if (!_paused) {
      update();
    }
  }

  // OnKeyDown(e)
  protected function OnKeyDown(e:KeyboardEvent):void 
  {
    if (_keydown == e.keyCode) return;
    _keydown = e.keyCode;

    switch (e.keyCode) {
    case 80:			// P
      setPauseState(!_paused);
      break;

    default:
      keydown(e.keyCode);
      break;
    }
  }

  // OnKeyUp(e)
  protected function OnKeyUp(e:KeyboardEvent):void 
  {
    _keydown = 0;

    keyup(e.keyCode);
  }

  /// Game-related functions

  private var scene:Scene;
  private var tilemap:TileMap;
  private var player:Player;
  private var state:int = 0;

  private var visualizer:PlanVisualizer;

  // init()
  private function init():void
  {
    log("init");
    
    //background.alpha = 0.7;
    //addChild(background);
    
    tilemap = new TileMap(mapimage.bitmapData, tilesimage.bitmapData, 32);
    addChild(tilemap);

    scene = new Scene(stage.stageWidth, stage.stageHeight, tilemap);

    player = new Player(scene);
    player.bounds = tilemap.getTileRect(3, 3);
    player.addEventListener(ActorActionEvent.ACTION, onActorAction);
    player.addEventListener(ActorActionEvent.ACTION, onPlayerAction);
    player.speak("Video Games AWESOME!");
    player.setSkinImage(image0.bitmapData);
    player.setName("Farshar");
    scene.add(player);

    for (var i:int = 0; i < images.length; i++) {
      var actor:Person = new Person(scene); 
      actor.bounds = tilemap.getTileRect(i+5, i+5);
      actor.addEventListener(ActorActionEvent.ACTION, onActorAction);
      actor.setSkinImage(images[i].bitmapData);
      switch (i) {
      case 0:
	actor.setName("MissBlow");
	actor.setTarget(player);
	break;
      case 1:
	actor.setName("Snarf");
	break;
      case 2:
	actor.setName("Deakwanda");
	break;
      }
      scene.add(actor);
    }

    addChild(scene);
    
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
      player.vx = -1;
      break;
    case Keyboard.RIGHT:
    case 68:			// D
    case 76:			// L
      player.vx = +1;
      break;
    case Keyboard.UP:
    case 87:			// W
    case 75:			// K
      player.vy = -1;
      break;
    case Keyboard.DOWN:
    case 83:			// S
    case 74:			// J
      player.vy = +1;
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
      player.vx = 0;
      break;
    case Keyboard.UP:
    case Keyboard.DOWN:
    case 87:			// W
    case 75:			// K
    case 83:			// S
    case 74:			// J
      player.vy = 0;
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
  private var video:Video;

  private function popupVideo(bytes:ByteArray):void
  {
    popdownVideo();
    video = new Video();
    var nc:NetConnection = new NetConnection();
    nc.connect(null);
    var ns:NetStream = new NetStream(nc);
    ns.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
    ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncErrorEvent);
    ns.play(null);
    ns.appendBytes(bytes);
    video.x = (stage.stageWidth-video.width)/2;
    video.y = (stage.stageHeight-video.height)/2;
    video.attachNetStream(ns);
    addChild(video);
  }
  
  private function popdownVideo():void
  {
    if (video != null) {
      removeChild(video);
      video = null;
    }
  }

  private function onNetStatusEvent(ev:NetStatusEvent):void
  {
    switch (ev.info.code) {
    case "NetStream.Buffer.Empty":
      popdownVideo();
      break;
    }
  }

  private function onAsyncErrorEvent(ev:AsyncErrorEvent):void
  {
  }

} // Main

} // package


import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;


//  Person
//
class Person extends Actor
{
  private var target:Actor;
  private var curgoal:Point;
  private var curaction:int;

  // Person(image)
  public function Person(scene:Scene)
  {
    super(scene);
    vx = int(Math.random()*3)-1;
    vy = 0;
    addEventListener(ActorActionEvent.ACTION, onActorAction);
  }

  // setTarget(actor)
  public function setTarget(actor:Actor):void
  {
    target = actor;
    curgoal = null;
    curaction = PlanEntry.NONE;
  }

  // onActorAction()
  private function onActorAction(e:ActorActionEvent):void
  {
    if (e.arg == Actor.LAND) {
      curaction = PlanEntry.NONE;
    }
  }

  // update()
  public override function update():void
  {
    super.update();
    if (target == null) {
      if (Math.random() < 0.05) {
	vx = int(Math.random()*3)-1;
	vy = 0;
      } else if (Math.random() < 0.05) {
	vx = 0;
	vy = int(Math.random()*3)-1;
      } else if (Math.random() < 0.1) {
	jump();
      }
    } else {
      var src:Rectangle = scene.tilemap.getTileByRect(bounds);
      var dst:Rectangle = scene.tilemap.getTileByRect(target.bounds);
      if (curaction == PlanEntry.NONE) {
	// Get a macro-level planning.
	var plan:PlanMap = scene.createPlan(dst.x, dst.y, dst.width, dst.height);
	var e:PlanEntry = plan.getEntry(src.x, src.y);
	if (e != null && e.next != null) {
	  curgoal = new Point(e.next.x, e.next.y);
	  curaction = e.action;
	  //log("goal="+curgoal+", action="+curaction);
	  if (curaction == PlanEntry.JUMP) {
	    jump();
	  }
	}
	PlanVisualizer.update(plan);
      } else {
	// Micro-level (greedy) planning.
	// assert(curgoal != null);
	// assert(curaction != PlanEntry.NONE);
	//log("goal="+curgoal+", src="+src);
	var dx:int = 0, dy:int = 0;
	if (curgoal.x < src.x) { 
	  dx = -1;
	} else if (src.x < curgoal.x) {
	  dx = +1;
	}
	var r:Rectangle = bounds.clone();
	r.x += speed*dx;
	if (scene.tilemap.hasTileByRect(r, Tile.isobstacle)) {
	  dx = 0;
	}
	if (dx == 0) {
	  if (curgoal.y < src.y) { 
	    dy = -1; 
	  } else if (src.y < curgoal.y) {
	    dy = +1;
	  }
	}
	if (dx != 0 || dy != 0) {
	  vx = dx; 
	  vy = dy;
	} else {
	  curaction = PlanEntry.NONE;
	}
      }
    }

    if (Math.random() < 0.05) {
      switch (int(Math.random()*3)) {
      case 0:
	speak("Derp.");
	break;
      case 1:
	speak("SNARF!");
	break;
      default:
	speak();
	break;
      }
    }
  }
}


//  Player
//
class Player extends Actor
{
  // Player(image)
  public function Player(scene:Scene)
  {
    super(scene);
  }

  // update()
  public override function update():void
  {
    if (vy < 0) {
      // move toward a nearby ladder.
      var vxladder:int = scene.tilemap.hasLadderNearby(bounds);
      Main.log("hasladderneaby="+vxladder);
      if (vxladder != 0) {
	vx = vxladder;
	vy = 0;
      }
    } else if (0 < vy) {
      // move toward a nearby hole.
      var vxhole:int = scene.tilemap.hasHoleNearby(bounds);
      Main.log("hasholerneaby="+vxhole);
      if (vxhole != 0) {
	vx = vxhole;
	vy = 0;
      }
    }
    
    super.update();
    scene.setCenter(pos, 200, 100);

    if (800 < bounds.y) {
      dispatchEvent(new ActorActionEvent(DIE));
    }
  }
}
