package SOF {

//  Tile
// 
public class Tile
{
  public static const NONE:int = 0;
  public static const COBBLE:int = 1;
  public static const LAVA:int = 2;
  public static const LADDER:int = 3;
  public static const STONE:int = 4;
  public static const DIRT:int = 5;
  public static const GRASS:int = 6;
  public static const PLANK:int = 7;
  public static const BRICK:int = 8;
  public static const TNT:int = 9;
  public static const COBWEB:int = 10;
  public static const ROSE:int = 11;
  public static const DANDELION:int = 12;
  public static const SAPLING:int = 13;
  public static const BEDROCK:int = 14;
  public static const SAND:int = 15;
  public static const WOOD:int = 16;
  public static const IRONBLK:int = 17;
  public static const GOLDBLK:int = 18;
  public static const DIAMONDBLK:int = 19;
  public static const REDMUSH:int = 20;
  public static const BROWNMUSH:int = 21;
  public static const GOLDORE:int = 22;
  public static const IRONORE:int = 23;
  public static const COALORE:int = 24;
  public static const BOOKSHELF:int = 25;
  public static const MOSSY:int = 26;
  public static const OBSIDIAN:int = 27;
  public static const FURNANCE:int = 28;
  public static const GLASS:int = 29;
  public static const DIAMONDORE:int = 30;
  public static const REDSTONEORE:int = 31;
  public static const LEAF:int = 32;
  public static const STONEBRICK:int = 33;

  // isobstacle
  public static var isobstacle:Function = 
    (function (b:int):Boolean { return b == COBBLE || b < 0; });
  // isnonobstacle
  public static var isnonobstacle:Function = 
    (function (b:int):Boolean { return !isobstacle(b); });
  // isgrabbable
  public static var isgrabbable:Function = 
    (function (b:int):Boolean { return b == LADDER; });
  // isstoppable
  public static var isstoppable:Function = 
    (function (b:int):Boolean { return b != NONE; });
  
  // pixelToBlockId(c)
  public static function pixelToBlockId(c:uint):int
  {
    switch (c) {
    case 0x000000: // 0
      return NONE;
    case 0x404040: // 1
      return COBBLE;
    case 0xff0000: // 2
      return LAVA;
    case 0xff6a00: // 3
      return LADDER;
    case 0xffd800: // 4
      return STONE;
    case 0xb6ff00: // 5
      return DIRT;
    case 0x4cff00: // 6
      return GRASS;
    case 0x00ff21: // 7
      return PLANK;
    case 0x00ff90: // 8
      return BRICK;
    case 0x00ffff: // 9
      return TNT;
    case 0x0094ff: // 10
      return COBWEB;
    case 0x0026ff: // 11
      return ROSE;
    case 0x4800ff: // 12
      return DANDELION;
    case 0xb200ff: // 13
      return SAPLING;
    case 0xff00dc: // 14
      return BEDROCK;
    case 0xff006e: // 15
      return SAND;
    case 0xffffff: // 16
      return WOOD;
    case 0x808080: // 17
      return IRONBLK;
    case 0x7f0000: // 18
      return GOLDBLK;
    case 0x7f3300: // 19
      return DIAMONDBLK;
    case 0x7f6a00: // 20
      return REDMUSH;
    case 0x5b7f00: // 21
      return BROWNMUSH;
    case 0x267f00: // 22
      return GOLDORE;
    case 0x007f0e: // 23
      return IRONORE;
    case 0x007f46: // 24
      return COALORE;
    case 0x007f7f: // 25
      return BOOKSHELF;
    case 0x004a7f: // 26
      return MOSSY;
    case 0x00137f: // 27
      return OBSIDIAN;
    case 0x21007f: // 28
      return FURNANCE;
    case 0x57007f: // 29
      return GLASS;
    case 0x7f006e: // 30
      return DIAMONDORE;
    case 0x7f0037: // 31
      return REDSTONEORE;
    default:
      return NONE;
    }
  }
}

}
