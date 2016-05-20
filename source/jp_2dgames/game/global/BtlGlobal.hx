package jp_2dgames.game.global;

/**
 * バトル用グローバル変数
 **/
class BtlGlobal {
  static var _turn:Int; // 経過ターン数

  //---------------------------------------------
  // ■アクセサ
  public static var turn(get, never):Int;

  /**
   * 初期化
   **/
  public static function init():Void {
    _turn = 1;
  }

  /**
   * 経過ターン数を増やす
   **/
  public static function addTurn():Void {
    _turn++;
  }


  // --------------------------------------------
  // ■アクセサメソッド
  static function get_turn() { return _turn; }
}
