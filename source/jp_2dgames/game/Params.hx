package jp_2dgames.game;

import jp_2dgames.game.dat.ClassDB;
import jp_2dgames.game.dat.MyDB;

/**
 * キャラクターパラメータ
 **/
class Params {

  public var id:EnemiesKind;   // ID
  public var kind:ClassesKind; // クラス
  public var hp:Int     = 10;  // HP
  public var hpmax:Int  = 10;  // 最大HP
  public var food:Int   = 10;  // 食糧
  public var str:Int    = 0;   // 力
  public var vit:Int    = 0;   // 体力
  public var dex:Int    = 0;   // 器用さ
  public var agi:Int    = 0;   // 素早さ
  public var shield:Int = 0;   // シールドの枚数
  public var shieldMax:Int = 0; // シールドの最大数

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  /**
   * 初期化
   **/
  public function clear():Void {
    hp     = 0;
    hpmax  = 0;
    food   = 0;
    str    = 0;
    vit    = 0;
    dex    = 0;
    agi    = 0;
    shield = 0;
    shieldMax = 0;
  }

  /**
   * コピー
   **/
  public function copy(src:Params):Void {
    id     = src.id;
    kind   = src.kind;
    hp     = src.hp;
    hpmax  = src.hpmax;
    food   = src.food;
    str    = src.str;
    vit    = src.vit;
    dex    = src.dex;
    agi    = src.agi;
    shield = src.shield;
    shieldMax = src.shieldMax;
  }

  /**
   * 最大HPを設定する
   **/
  public function setHpMax(v:Int):Void {
    hpmax = v;
    hp = v;
  }

  /**
   * 職業に対応するパラメータを設定
   **/
  public function setFromKind(kind:ClassesKind):Void {

    this.kind = kind;

    // 最大HP設定
    var hp = ClassDB.getHp(kind);
    setHpMax(hp);
    // 食糧
    food = ClassDB.getFood(kind);
    // VIT
    vit = ClassDB.getVit(kind);
    // DEX
    dex = ClassDB.getDex(kind);
    // AGI
    agi = ClassDB.getAgi(kind);
  }

  /**
   * シールド設定
   **/
  public function setShield(v:Int):Void {
    shield = v;
    shieldMax = v;
  }

  /**
   * シールドが存在するかどうか
   **/
  public function isValidShield():Bool {
    return shield > 0;
  }

  /**
   * シールドの枚数を減らす
   **/
  public function subShield(v:Int):Void {
    shield -= v;
    if(shield < 0) {
      shield = 0;
    }
  }
}
