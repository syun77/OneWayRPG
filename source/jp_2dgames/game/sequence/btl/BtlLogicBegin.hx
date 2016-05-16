package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.actor.Actor;

/**
 * 行動開始演出
 **/
enum BtlLogicBegin {
  Attack;    // 通常攻撃
  PowerUp;   // パワーアップ
  PowerDown; // パワーダウン
}

class BtlLogicBeginUtil {

  public static function start(type:BtlLogicBegin, target:Actor):Void {
    // TODO: 未実装
  }
}
