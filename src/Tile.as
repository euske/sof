package {

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

}

} // package
