package jp_2dgames.game.global;

import jp_2dgames.game.shop.Shop;
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
  static inline var START_LEVEL:Int = 1;
  static inline var FIRST_MONEY:Int = 0;
  static inline var START_FOOD:Int  = 10;

  // レベル
  static var _level:Int;
  // お金
  static var _money:Int;
  // プレイヤーステータス
  static var _player:Params;
  // 敵ステータス
  static var _enemy:Params;
  // 歩いた歩数
  static var _step:Int;
  // 倒した敵の数
  static var _killEnemies:Int;

  public static var level(get, never):Int;
  public static var money(get, never):Int;
  public static var step(get, never):Int;
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
    _player = new Params();
    _player.id = EnemiesKind.Player;
    _player.food = START_FOOD; // 初期食糧設定

    // TODO: 職業は戦士とする
    var kind = ClassesKind.Fighter;
    _player.setFromKind(kind);

    // アイテム初期化
    ItemList.createInstance();
    var items = ClassDB.getItems(kind);
    for(itemid in items) {
      var item = ItemUtil.add(itemid);
      ItemList.push(item);
    }

    // 敵パラメータ
    _enemy = new Params();
    _enemy.id = EnemiesKind.Slime;

    // 倒した敵の数を初期化
    _killEnemies = 0;
  }

  /**
   * レベル開始時の初期化 (PlayState)
   **/
  public static function initLevel():Void {
    _step = FloorInfoDB.getSteps(level);

    // TODO: ショップアイテムの生成
    Shop.create(Global.level);
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
  public static function setMoney(v:Int):Void {
    _money = v;
  }
  public static function getPlayerParam():Params {
    return _player;
  }
  public static function getEnemyParam():Params {
    return _enemy;
  }
  public static function subStep():Void {
    _step--;
  }
  public static function setStep(v:Int):Void {
    _step = v;
  }
  public static function addKillEnemies():Void {
    _killEnemies++;
  }
  public static function setKillEnemies(v:Int):Void {
    _killEnemies = v;
  }

  // -----------------------------------------------
  // ■アクセサ
  static function get_level()       { return _level; }
  static function get_money()       { return _money; }
  static function get_step()        { return _step;  }
  static function get_killEnemies() { return _killEnemies; }
}
