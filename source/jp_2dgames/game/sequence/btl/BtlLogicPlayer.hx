package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.particle.ParticleNumber;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import flixel.FlxG;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.BadStatusUtil;
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

  static inline var TIMER_WAIT:Int = 30;
  static inline var TIMER_WAIT_SEQUENCE:Int = 10;

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
    FlxG.watch.add(this, "_tWait", "LogicPlayer.wait");
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
   * 演出が終了したかどうか
   **/
  public function isEnd():Bool {
    return _state == State.End;
  }

  /**
   * 更新
   **/
  public function update():Void {
    if(_checkWait()) {
      // 停止中
      return;
    }

    switch(_state) {
      case State.Init:
        _state = State.Main;

      case State.Main:
        if(BtlLogicUtil.isBegin(_data.type)) {
          // 開始演出
          _updateMainBegin();
        }
        else {
          // 通常演出
          _updateMain();
        }

      case State.Wait:
        _state = State.End;

      case State.End:
    }
  }

  /**
   * 停止中かどうか
   **/
  function _checkWait():Bool {
    if(_tWait > 0) {
      _tWait--;
      // 停止中
      return true;
    }

    // 停止していない
    return false;
  }

  /**
   * 開始演出の更新
   **/
  function _updateMainBegin():Void {
    var actor  = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);
    var tWait  = TIMER_WAIT;

    switch(_data.type) {
      case BtlLogic.BeginEffect:
        // 開始演出
        tWait = 0; // ウェイトなし

      case BtlLogic.BeginAttack:
        // 攻撃
        Message.push2(Msg.ATTACK_BEGIN, [actor.getName()]);

      case BtlLogic.BeginItem(item):
        // アイテム
        var name = ItemUtil.getName(item);
        Message.push2(Msg.ITEM_USE, [name]);

      default:
        throw 'Error: Invalid data.type = ${_data.type}';
    }

    // メイン処理終了
    _endMain(tWait);
  }

  /**
   * メインの更新
   **/
  function _updateMain():Void {
    var actor  = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    // 停止時間
    var tWait = TIMER_WAIT;

    switch(_data.type) {
      case BtlLogic.BeginEffect, BtlLogic.BeginAttack, BtlLogic.BeginItem:
        // ここに来てはいけない
        throw 'Error: Invalid _data.type = ${_data.type}';

      case BtlLogic.EndAction:

      case BtlLogic.UseItem(item):
        // ■アイテムを使った
        var name = ItemUtil.getName2(item);
        Message.push2(Msg.ITEM_USE, [actor.getName(), name]);

      case BtlLogic.MessageDisp(msgID, args):
        // ■メッセージ表示
        Message.push2(msgID, args);

      case BtlLogic.HpDamage(val, bSeq):
        // ■HPダメージ
        _damage(target, val, bSeq);

      case BtlLogic.HpRecover(val):
        // ■HP回復
        _recoverHp(target, val);

      case BtlLogic.ChanceRoll(b):
        // ■成功 or 失敗
        _chanceRoll(target, b);

      case BtlLogic.Badstatus(bst):
        // ■バステ付着
        target.adhereBadStatus(bst);

      case BtlLogic.Dead:
        // ■死亡
        target.vanish();

      case BtlLogic.BtlEnd(bWin):
        // ■バトル終了
    }

    // メイン処理終了
    _endMain(tWait);
  }

  /**
   * ダメージ演出
   **/
  function _damage(target:Actor, val:Int, bSeq:Bool):Void {
    // ダメージ値反映
    target.damage(val);
    var px = target.xcenter;
    var py = target.ycenter;
    if(bSeq) {
      // 連続攻撃の場合だけランダムでずらす
      px += FlxG.random.int(-16, 16);
      py += FlxG.random.int(-8, 8);
    }
    // ダメージエフェクト
    Particle.start(PType.Ball, px, py, FlxColor.RED);
    ParticleNumber.start(px, py, val);
    Snd.playSe("hit");
  }

  /**
   * 回復演出
   **/
  function _recoverHp(target:Actor, val:Int):Void {
    target.recover(val);
  }


  function _chanceRoll(target:Actor, b:Bool):Void {
    if(b == false) {
      var px = target.xcenter;
      var py = target.ycenter;
      ParticleNumber.start(px, py, BtlCalc.VAL_EVADE);
      Snd.playSe("miss");
    }
  }

  /**
   * メイン処理終了
   **/
  function _endMain(tWait:Int):Void {
    _state = State.Wait;
    _tWait = tWait;
    if(_tWait > 0) {
      if(_data.bWaitQuick) {
        // 待ち時間短縮
        _tWait = TIMER_WAIT_SEQUENCE;
      }
    }
  }

  /**
   * 更新
   **/
  /*
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
  */

  /**
   * 更新・攻撃
   **/
  /*
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
  */
}
