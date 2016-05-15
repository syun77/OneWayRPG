package jp_2dgames.game.actor;

/**
 * バッドステータスの種類
 **/
enum BadStatus {
  None;     // なし
  Death;    // 死亡 (※使用しない)
  Poison;   // 毒
  Confuse;  // 混乱  (※使用しない)
  Close;    // 封印 (※使用しない)
  Paralyze; // 麻痺
  Sleep;    // 眠り (※使用しない)
  Blind;    // 盲目
  Curse;    // 呪い (※使用しない)
  Weaken;   // 弱体化 (※使用しない)
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {
  public function new() {
  }
}
