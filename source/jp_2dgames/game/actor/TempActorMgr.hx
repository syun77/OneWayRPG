package jp_2dgames.game.actor;

import flixel.group.FlxGroup;
import jp_2dgames.game.actor.BtlGroupUtil;

/**
 * アクター管理（テンポラリ）
 **/
class TempActorMgr {

  static var _instance:FlxTypedGroup<Actor> = null;
  public static function createInstance():Void {
    _instance = new FlxTypedGroup<Actor>();
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function add():Actor {
    var actor = _instance.recycle(Actor);
    return actor;
  }
  public static function forEach(func:Actor->Void):Void {
    _instance.forEach(func);
  }
  public static function forEachAlive(func:Actor->Void):Void {
    _instance.forEachAlive(func);
  }

  /**
   * 生存数をカウントする
   **/
  public static function count(group:BtlGroup):Int {
    var ret:Int = 0;
    forEachAlive(function(actor:Actor) {
      if(actor.group == group) {
        ret++;
      }
    });
    return ret;
  }

  /**
   * プレイヤーを取得
   **/
  public static function getPlayer():Actor {
    var ret:Actor = null;
    forEach(function(actor:Actor) {
      if(actor.group == BtlGroup.Player) {
        ret = actor;
      }
    });

    return ret;
  }

  /**
   * 敵を取得
   **/
  public static function getEnemy():Actor {
    var ret:Actor = null;
    forEach(function(actor:Actor) {
      if(actor.group == BtlGroup.Enemy) {
        ret = actor;
      }
    });

    return ret;
  }


  // -----------------------------------------
  // ■フィールド

  /**
   * コンストラクタ
   **/
  public function new() {
  }
}
