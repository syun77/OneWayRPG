package jp_2dgames.game.actor;

/**
 * バトル用パラメータ
 **/
class BtlParams {

  public var cntAttackEvade:Int = 0; // 攻撃を回避された回数

  /**
   * コンストラクタ
   **/
  public function new() {
    clear();
  }

  /**
   * 初期化
   **/
  public function clear():Void {
    cntAttackEvade = 0;
  }

  /**
   * コピー
   **/
  public function copy(src:BtlParams):Void {
    cntAttackEvade = src.cntAttackEvade;
  }
}
