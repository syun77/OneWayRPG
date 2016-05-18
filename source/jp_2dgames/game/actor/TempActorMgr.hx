package jp_2dgames.game.actor;

import flixel.group.FlxGroup;
import jp_2dgames.game.actor.BtlGroupUtil;

/**
 * アクター管理（テンポラリ）
 **/
class TempActorMgr {

  static var _pool:FlxTypedGroup<Actor> = null;
  public static function create():Void {
    _pool = new FlxTypedGroup<Actor>();
  }
  public static function destroy():Void {
    _pool = null;
  }
  public static function add():Actor {
    var actor = _pool.recycle(Actor);
    return actor;
  }

  /**
   * ActorMgrから情報をコピー
   **/
  public static function copyFromActorMgr():Void {
    var idx:Int = 0;
    ActorMgr.forEach(function(actor:Actor) {
      var act:Actor = _pool.members[idx];
      actor.copyTo(act);
      idx++;
    });
  }

  public static function forEach(func:Actor->Void):Void {
    _pool.forEach(func);
  }
  public static function forEachAlive(func:Actor->Void):Void {
    _pool.forEachAlive(func);
  }

  /**
   * 生存しているActorのリストを取得
   **/
  public static function getAlive():Array<Actor> {
    return _pool.members;
  }

  /**
   * 生存数をカウントする
   **/
  public static function count(group:BtlGroup):Int {
    var ret:Int = 0;
    forEachAlive(function(actor:Actor) {
      if(actor.isDead()) {
        return;
      }
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
