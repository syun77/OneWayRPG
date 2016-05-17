package jp_2dgames.game.sequence.btl;

import flixel.FlxG;
import jp_2dgames.game.actor.BtlGroupUtil;
import jp_2dgames.game.actor.TempActorMgr;
import jp_2dgames.game.actor.Actor;

/**
 * 状態
 **/
private enum State {
  Begin; // 開始
  Main;  // メイン
  End;   // 終了
}

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
  public static function createLogic(owner:SeqMgr):Void {
    _instance._createLogic(owner);
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

  /**
   * 終了したかどうか
   **/
  public static function isEnd():Bool {
    return _instance._isEnd();
  }

  /**
   * 更新
   **/
  public static function update():Void {
    _instance._update();
  }


  // ---------------------------------------------------
  // ■フィールド
  var _pool:List<BtlLogicData>;
  var _logicPlayer:BtlLogicPlayer;
  var _state:State;

  /**
   * コンストラクタ
   **/
  function new() {
    _pool = new List<BtlLogicData>();
    _state = State.End;
    _logicPlayer = new BtlLogicPlayer();
    FlxG.watch.add(this, "_state", "Logic.state");
  }

  /**
   * 終了したかどうか
   **/
  function _isEnd():Bool {
    return _state == State.End;
  }

  /**
   * 演出データを生成
   **/
  function _createLogic(owner:SeqMgr):Void {

    _state = State.Begin;

    // ActorMgrからTempActorMgrに情報をコピーする
    TempActorMgr.copyFromActorMgr();
    var player = TempActorMgr.getPlayer();
    var enemy  = TempActorMgr.getEnemy();

    // 行動順の決定
    var actorList = TempActorMgr.getAlive();
    // 行動順ソート
    // 必ず、プレイヤー -> 敵 なのでソート不要

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
      var efts:List<BtlLogicData> = null;
      if(actor.group == BtlGroup.Player) {
        // プレイヤー
        var item = owner.getSelectedItem();
        efts = BtlLogicFactory.createPlayerLogic(actor, enemy, item);
      }
      else {
        // 敵
        efts = BtlLogicFactory.createEnemyLogic(player, actor);
      }
      if(efts != null) {
        for(eft in efts) {
          push(eft);
        }
      }

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
   * バトル終了チェック
   **/
  function _checkBattleEnd():Bool {
    if(TempActorMgr.count(BtlGroup.Player) == 0) {
      // 味方が全滅
      return true;
    }

    if(TempActorMgr.count(BtlGroup.Enemy) == 0) {
      // 敵が全滅
      return true;
    }

    // 終了していない
    return false;
  }

  /**
   * 更新
   **/
  function _update():Void {
    switch(_state) {
      case State.Begin:
        var logic = pop();
        if(logic != null) {
          _logicPlayer.start(logic);
          _state = State.Main;
        }
        else {
          // 再生する演出がなくなったので終わり
          _state = State.End;
        }
      case State.Main:
        _logicPlayer.update();
        if(_logicPlayer.isEnd()) {
          // 次の演出へ
          _state = State.Begin;
        }
      case State.End:
    }
  }

  /**
   * バトル演出データをキューに登録
   **/
  function _push(data:BtlLogicData):Void {
    _pool.add(data);
  }

  /**
   * バトル演出データをキューから取り出し
   **/
  function _pop():BtlLogicData {
    return _pool.pop();
  }

}
