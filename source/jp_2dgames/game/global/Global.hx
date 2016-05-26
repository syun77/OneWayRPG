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
  static inline var START_LEVEL:Int = 5;
  static inline var FIRST_MONEY:Int = 0;

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
  // 倒した敵の数
  static var _killEnemies:Int;

  public static var level(get, never):Int;
  public static var money(get, never):Int;
  public static var step(get, never):Int;
  public static var shop(get, never):Array<ItemData>;
  public static var killEnemies(get, never):Int;

  /**
   * 起動時の初期化
   **/
  public static function init():Void {
  }

  /**
   * ゲーム開始時の初期化 (PlayInitState)
   **/
  public static function initGame():Void {
    _level = START_LEVEL;
    _money = FIRST_MONEY;

    // プレイヤーパラメータ
    _param = new Params();
    _param.id = EnemiesKind.Player;

    // TODO: 職業は戦士とする
    var kind = ClassesKind.Fighter;
    _param.setHpMax(ClassDB.getHp(kind));

    // アイテム初期化
    ItemList.createInstance();
    var items = ClassDB.getItems(kind);
    for(itemid in items) {
      var item = ItemUtil.add(itemid);
      ItemList.push(item);
    }

    // 倒した敵の数を初期化
    _killEnemies = 0;
  }

  /**
   * レベル開始時の初期化 (PlayState)
   **/
  public static function initLevel():Void {
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
  public static function addKillEnemies():Void {
    _killEnemies++;
  }

  // -----------------------------------------------
  // ■アクセサ
  static function get_level()       { return _level; }
  static function get_money()       { return _money; }
  static function get_step()        { return _step;  }
  static function get_shop()        { return _shop;  }
  static function get_killEnemies() { return _killEnemies; }
}
