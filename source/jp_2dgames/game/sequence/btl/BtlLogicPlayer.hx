package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.sequence.btl.BtlLogic;
import jp_2dgames.game.gui.message.Message;

/**
 * 状態
 **/
private enum State {
  Init; // 初期化
  Main; // メイン
  Wait; // 終了待ち
  End;  // 終了
}

/**
 * バトル演出の再生
 **/
class BtlLogicPlayer {

  // --------------------------------------------------
  // ■フィールド
  // 演出情報
  var _data:BtlLogicData;
  // 状態
  var _state:State = State.Init;
  // 停止タイマー
  var _tWait:Int = 0;

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  /**
   * 開始
   **/
  public function start(logic:BtlLogicData):Void {
    _data  = logic;
    _state = State.Init;
    _tWait = 0;
  }

  /**
   * 初期化
   **/
  public static function init(data:BtlLogicData):Void {
    _data = data;
    _state = State.Start;
    _cntHit = 0;
  }

  /**
   * 演出が終了したかどうか
   **/
  public static function isEnd():Bool {
    return _state == State.End;
  }

  /**
   * 更新
   **/
  public static function proc(elapsed:Float, owner:SeqMgr):Void {
    if(_data.count <= 0) {
      // 行動終了
      return;
    }
    if(owner.isEndWait() == false) {
      // 演出中
      return;
    }

    switch(_data.type) {
      case BtlLogic.None:
        // 何もしない

      case BtlLogic.Attack(type, prm):
        // 攻撃
        _procAttack(owner, type, prm);

      case BtlLogic.Recover(prm):
        // 回復
        var hp = prm.hp;
        _data.target.recover(hp);
        var name = _data.actor.getName();
        Message.push2(Msg.RECOVER_HP, [name, hp]);
        Snd.playSe("recover");
        owner.startWait();
        _data.count--;
    }

    if(_data.count <= 0) {
      // 演出終了
      _state = State.End;
    }
  }

  /**
   * 更新・攻撃
   **/
  static function _procAttack(owner:SeqMgr, type:BtlLogicAttack, prm:BtlLogicAttackParam):Void {
    // 命中判定
    var damage = BtlCalc.damage(prm, _data.actor, _data.target);
    if(BtlCalc.isHit(prm, _data.actor, _data.target)) {
      // 命中回数増加
      _cntHit++;
    }
    else {
      // 外れ
      damage = BtlCalc.VAL_EVADE;
    }
    // ダメージ処理
    _data.target.damage(damage);

    _data.count--;
    switch(type) {
      case BtlLogicAttack.Normal:
        // 1回攻撃
        owner.startWait();
      case BtlLogicAttack.Multi:
        // 複数回攻撃
        if(_data.count <= 0) {
          owner.startWait();
        }
        else {
          owner.startWaitHalf();
        }
    }

    if(_data.count == 0) {
      // 攻撃終了
      // 命中回数を記録
      if(_cntHit == 0) {
        // 一度も命中しなかった
        _data.actor.btlPrms.cntAttackEvade += 1;
      }
      else {
        // 一度でも命中した
        _data.actor.btlPrms.cntAttackEvade = 0;
        if(prm.bst != BadStatus.None) {
          // バステ付着
          _data.target.adhereBadStatus(prm.bst);
        }
      }
    }
  }
}
