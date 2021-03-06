package jp_2dgames.game.actor;

import flixel.group.FlxGroup;
import flixel.FlxState;
import jp_2dgames.game.actor.BtlGroupUtil;

/**
 * アクター管理
 **/
class ActorMgr {

  static var _cntUID:Int;
  static var _instance:FlxTypedGroup<Actor> = null;
  public static function createInstance(state:FlxState):Void {
    _instance = new FlxTypedGroup<Actor>(2);
    state.add(_instance);
    for(i in 0..._instance.maxSize) {
      var actor = new Actor();
      _instance.add(actor);
      state.add(actor.shield);
    }
    _cntUID = 1000;
  }
  public static function destroyInstance():Void {
    _instance = null;
  }
  public static function add(p:Params):Actor {
    var actor:Actor = _instance.recycle(Actor);
    actor.uid = _cntUID;
    _cntUID++;
    actor.init(p);
    return actor;
  }
  public static function forEach(func:Actor->Void):Void {
    _instance.forEach(func);
  }
  public static function forEachAlive(func:Actor->Void):Void {
    _instance.forEachAlive(func);
  }
  public static function search(uid:Int):Actor {
    var ret:Actor = null;
    forEach(function(actor:Actor) {
      if(uid == actor.uid) {
        ret = actor;
      }
    });
    return ret;
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
  public static function countExists():Int {
    return _instance.countLiving();
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

  // -------------------------------------------
  // ■フィールド


  /**
   * コンストラクタ
   **/
  public function new() {
  }
}
