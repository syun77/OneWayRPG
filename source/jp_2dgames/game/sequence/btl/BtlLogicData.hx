package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.sequence.btl.BtlLogic;
import jp_2dgames.game.actor.Actor;

/**
 * バトル演出データ
 **/
class BtlLogicData {

  /*
  public var type:BtlLogic; // 行動種別
  public var count:Int;     // 行動回数
  public var actor:Actor;   // 行動主体者
  public var target:Actor;  // 行動対象者
  */

  public var actor:Actor;     // 行動主体者
  public var type:BtlLogic;   // 演出種別
  public var target:Actor;    // 対象者
  public var bWaitQuick:Bool; // 項同時間を短縮するかどうか

  /**
   * コンストラクタ
   **/
  /*
  public function new(type:BtlLogic, count:Int, actor:Actor, target:Actor) {
    this.type   = type;
    this.count  = count;
    this.actor  = actor;
    this.target = target;
  }
  */
  public function new(type:BtlLogic, actor:Actor, target:Actor) {
    this.type       = type;
    this.actor      = actor;
    this.target     = target;
    this.bWaitQuick = false;
  }

  /**
   * コピーする
   **/
  public function copy(src:BtlLogicData):Void {
    type       = src.type;
    actor      = src.actor;
    target     = src.target;
    bWaitQuick = src.bWaitQuick;
  }
}
