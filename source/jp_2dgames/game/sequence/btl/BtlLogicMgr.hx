package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.actor.Actor;

/**
 * バトル演出管理（キュー）
 **/
class BtlLogicMgr {

  // インスタンス
  static var _instance:BtlLogicMgr = null;

  /**
   * 生成
   **/
  public static function create():Void {
    _instance = new BtlLogicMgr();
  }

  /**
   * 破棄
   **/
  public static function destroy():Void {
    _instance = null;
  }

  /**
   * 演出データ生成
   **/
  public static function createLogic():Void {
    _instance._createLogic();
  }

  /**
   * バトル演出データをキューに登録
   **/
  public static function push(data:BtlLogicData):Void {
    _instance._push(data);
  }

  /**
   * バトル演出データをキューから取り出し
   **/
  public static function pop():BtlLogicData {
    return _instance._pop();
  }


  // ---------------------------------------------------
  // ■フィールド
  var _pool:List<BtlLogicData>;

  /**
   * コンストラクタ
   **/
  function new() {
    _pool = new List<BtlLogicData>();
  }

  /**
   * 演出データを生成
   **/
  function _createLogic():Void {

    // ActorMgrからTempActorMgrに情報をコピーする

    // 行動順の決定
    var actorList:Array<Actor> = null;

    // バトル終了フラグ
    var bEnd = false;
    for(actor in actorList) {
      // 行動順に実行

      // 死亡チェック
      if(actor.isDead()) {
        // 死亡しているので何もしない
        continue;
      }

      // バステチェック
      if(false) {
        // TODO: 行動不能
        continue;
      }

      // 演出データを生成

      // 死亡チェック

      // バトル終了チェック
      bEnd = _checkBattleEnd();
      if(bEnd) {
        // バトル終了
        break;
      }
    }

    // ターン終了処理
    if(bEnd == false) {
      // ターン終了演出生成

      // 死亡チェック

      // バトル終了チェック
      if(_checkBattleEnd()) {
        // 終了
      }
    }

  }

  /**
   * バトル演出データをキューに登録
   **/
  function _push(data:BtlLogicData):Void {
    _pool.push(data);
  }

  /**
   * バトル演出データをキューから取り出し
   **/
  function _pop():BtlLogicData {
    return _pool.pop();
  }

  /**
   * バトル終了チェック
   **/
  function _checkBattleEnd():Bool {
    if(false) {
      // TODO: 味方が全滅
      return true;
    }

    if(false) {
      // TODO: 敵が全滅
      return true;
    }

    // 終了していない
    return false;
  }
}
