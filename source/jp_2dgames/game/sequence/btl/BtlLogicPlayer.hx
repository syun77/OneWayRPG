package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.EffectDB;
import jp_2dgames.game.particle.ParticleAnim;
import flixel.tweens.FlxTween;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.lib.MyColor;
import flixel.math.FlxMath;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.particle.ParticleBmpFont;
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
        _updateMain();

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
   * メインの更新
   **/
  function _updateMain():Void {
    var actor  = ActorMgr.search(_data.actorID);
    var target = ActorMgr.search(_data.targetID);

    // 停止時間
    var tWait = TIMER_WAIT;

    switch(_data.type) {
      case BtlLogic.BeginAttack(attr):
        // 攻撃
        Message.push2(Msg.ATTACK_BEGIN, [actor.getName()]);
        _startAttackEffect(target, attr);

      case BtlLogic.EndAction(bHit):
        // 攻撃が命中したかどうか
        if(bHit) {
          actor.btlPrms.cntAttackEvade = 0;
        }
        else {
          actor.btlPrms.cntAttackEvade++;
        }
        // ウェイトなし
        tWait = 0;

      case BtlLogic.UseItem(item):
        // ■アイテムを使った
        item.now--;
        if(item.now <= 0) {
          // 壊れる
          ItemList.del(item.uid);
        }
        switch(ItemUtil.getCategory(item)) {
        case ItemCategory.Weapon:
          // 攻撃エフェクト
          var attr = ItemUtil.getAttribute(item);
          _startAttackEffect(target, attr);
        case ItemCategory.Portion:
        }
        var name = ItemUtil.getName2(item);
        Message.push2(Msg.ITEM_USE, [actor.getName(), name]);

      case BtlLogic.MessageDisp(msgID, args):
        // ■メッセージ表示
        Message.push2(msgID, args);
        if(_data.bWaitQuick) {
          tWait = 0;
        }

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
        _adhereBadStatus(target, bst);

      case BtlLogic.Dead:
        // ■死亡
        target.vanish();

      case BtlLogic.TurnEnd:
        // ■ターン終了
        target.turnEnd();
        tWait = 0; // ウェイトなし

      case BtlLogic.BtlEnd(bWin):
        // ■バトル終了
    }

    // メイン処理終了
    _endMain(tWait);
  }

  /**
   * 攻撃開始演出
   **/
  function _startAttackEffect(target:Actor, attr:Attribute):Void {
    var px = target.xcenter;
    var py = target.ycenter;
    var eft = AttributeUtil.toEffectType(attr);
    ParticleAnim.start(eft, px, py);
  }

  /**
   * ダメージ演出
   **/
  function _damage(target:Actor, val:Int, bSeq:Bool):Void {
    // ダメージ値反映
    var ratio = target.damage(val);
    var name = target.getName();
    if(target.group == BtlGroup.Player) {
      // プレイヤーダメージのときだけ画面を揺らす
      var v = FlxMath.lerp(0.01, 0.05, ratio);
      FlxG.camera.shake(v, 0.1 + (v * 10));
      Message.push2(Msg.DAMAGE_PLAYER, [name, val]);
    }
    else {
      Message.push2(Msg.DAMAGE_ENEMY, [name, val]);
    }
    var px = target.xcenter;
    var py = target.ycenter;
    if(bSeq) {
      // 連続攻撃の場合だけランダムでずらす
      px += FlxG.random.int(-16, 16);
      py += FlxG.random.int(-8, 8);
    }
    // ダメージエフェクト
    Particle.start(PType.Ball, px, py, FlxColor.RED);
    ParticleBmpFont.startNumber(px, py, val);
    Snd.playSe("hit");
  }

  /**
   * 回復演出
   **/
  function _recoverHp(target:Actor, val:Int):Void {
    target.recover(val);

    var px = target.xcenter;
    var py = target.ycenter;
    ParticleBmpFont.startNumber(px, py, val, MyColor.LIME);
    Snd.playSe("recover");
  }


  function _chanceRoll(target:Actor, b:Bool):Void {
    if(b == false) {
      var px = target.xcenter;
      var py = target.ycenter;
      ParticleBmpFont.start(px, py, "MISS!");
      Snd.playSe("miss");
      Message.push2(Msg.ATTACK_MISS, [target.getName()]);
    }
  }

  function _adhereBadStatus(target:Actor, bst:BadStatus):Void {
    target.adhereBadStatus(bst);
    var c = BadStatusUtil.getColor(bst);
    FlxTween.color(target, 1, c, FlxColor.WHITE);
    target.shake(0.2);
    var px = target.xcenter;
    var py = target.ycenter;
    ParticleAnim.start(EffectType.EftBst, px, py, c);

    var name = target.getName();
    var msg = BadStatusUtil.getMessage(bst);
    Message.push2(msg, [name]);
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
}
