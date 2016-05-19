package jp_2dgames.game.global;

import jp_2dgames.game.dat.ItemLotteryDB;
import jp_2dgames.game.dat.ClassDB;
import jp_2dgames.game.dat.FloorInfoDB;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.dat.MyDB;

/**
 * グローバル変数
 **/
class Global {

  public static inline var MAX_LEVEL:Int = 6;
  public static inline var MAX_LIFE:Int = 100;
  static inline var START_LEVEL:Int = 3;
  static inline var FIRST_MONEY:Int = 0;

  // スコア
  static var _score:Int;
  // レベル
  static var _level:Int;
  // お金
  static var _money:Int;
  // プレイヤーステータス
  static var _param:Params;
  // 歩いた歩数
  static var _step:Int;
  // ショップアイテム
  static var _shop:Array<ItemData>;

  public static var score(get, never):Int;
  public static var level(get, never):Int;
  public static var money(get, never):Int;
  public static var step(get, never):Int;
  public static var shop(get, never):Array<ItemData>;

  /**
   * 起動時の初期化
   **/
  public static function init():Void {
  }

  /**
   * ゲーム開始時の初期化 (PlayInitState)
   **/
  public static function initGame():Void {
    _score = 0;
    _level = START_LEVEL;
    _money = FIRST_MONEY;
    // プレイヤーパラメータ
    _param = new Params();
    _param.id = EnemiesKind.Player;
    // アイテム初期化
    ItemList.createInstance();
    var items = ClassDB.getItems(ClassesKind.Fighter);
    for(itemid in items) {
      var item = ItemUtil.add(itemid);
      ItemList.push(item);
    }
  }

  /**
   * レベル開始時の初期化 (PlayState)
   **/
  public static function initLevel():Void {
    _score = 0;
    _step = FloorInfoDB.getSteps(level);

    // TODO: ショップアイテムの生成
    _shop = new Array<ItemData>();
    var gen = ItemLotteryDB.createGenerator(Global.level);
    for(i in 0...3) {
      var id = gen.exec();
      var item = ItemUtil.add(id);
      _shop.push(item);
    }
  }


  public static function addScore(v:Int):Void {
    _score += v;
  }
  public static function addLevel():Bool {
    _level++;
    if(_level >= MAX_LEVEL) {
      return true;
    }
    return false;
  }
  public static function setLevel(v:Int):Void {
    _level = v;
  }
  public static function addMoney(v:Int):Void {
    _money += v;
  }
  public static function subMoney(v:Int):Void {
    _money -= v;
  }
  public static function getPlayerParam():Params {
    return _param;
  }
  public static function subStep():Void {
    _step--;
  }

  // -----------------------------------------------
  // ■アクセサ
  static function get_score() { return _score; }
  static function get_level() { return _level; }
  static function get_money() { return _money; }
  static function get_step()  { return _step;  }
  static function get_shop()  { return _shop;  }
}
