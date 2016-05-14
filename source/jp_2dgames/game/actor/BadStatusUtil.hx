package jp_2dgames.game.actor;

/**
 * バッドステータスの種類
 **/
enum BadStatus {
  None;     // なし
  Death;    // 死亡
  Poison;   // 毒
  Confuse;  // 混乱
  Close;    // 封印
  Paralyze; // 麻痺
  Sleep;    // 眠り
  Blind;    // 盲目
  Curse;    // 呪い
  Weaken;   // 弱体化
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {
  public function new() {
  }
}
