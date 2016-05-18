package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.sequence.btl.BtlLogic;

/**
 * バトル演出データ
 **/
class BtlLogicData {

  public var type:BtlLogic;   // 演出種別
  public var actorID:Int;     // 行動主体者
  public var targetID:Int;    // 対象者
  public var bWaitQuick:Bool; // 項同時間を短縮するかどうか

  public function new(type:BtlLogic, actorID:Int, targetID:Int) {
    this.type       = type;
    this.actorID    = actorID;
    this.targetID   = targetID;
    this.bWaitQuick = false;
  }

  /**
   * コピーする
   **/
  public function copy(src:BtlLogicData):Void {
    type       = src.type;
    actorID    = src.actorID;
    targetID   = src.targetID;
    bWaitQuick = src.bWaitQuick;
  }

  /**
   * デバッグ出力
   **/
  public function dump():Void {
    trace('${type} actor=${actorID} target=${targetID} bWaitQuick=${bWaitQuick}');
  }
}
