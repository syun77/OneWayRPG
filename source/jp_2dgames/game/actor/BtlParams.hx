package jp_2dgames.game.actor;

/**
 * バトル用パラメータ
 **/
class BtlParams {

  public var cntAttackEvade:Int = 0; // 攻撃を回避された回数
  public var dexVal:Int   = 0; // 命中率上昇値
  public var dexTurn:Int  = 0; // 命中率上昇の有効ターン数
  public var evaVal:Int  = 0; // 回避率上昇値
  public var evaTurn:Int = 0; // 回避率上昇の有効ターン数

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
    dexVal  = 0;
    dexTurn = 0;
    evaVal  = 0;
    evaTurn = 0;
  }

  /**
   * コピー
   **/
  public function copy(src:BtlParams):Void {
    cntAttackEvade = src.cntAttackEvade;
    dexVal         = src.dexVal;
    dexTurn        = src.dexTurn;
    evaVal         = src.evaVal;
    evaTurn        = src.evaTurn;
  }

  /**
   * 命中率設定
   **/
  public function setDex(val:Int, turn:Int=4):Void {
    dexVal  = val;
    dexTurn = turn;
  }

  /**
   * 回避率設定
   **/
  public function setEva(val:Int, turn:Int=4):Void {
    evaVal  = val;
    evaTurn = turn;
  }

  /**
   * ターン終了
   **/
  public function turnEnd():Void {
    if(dexTurn > 0) {
      dexTurn--;
      if(dexTurn == 0) {
        dexVal = 0;
      }
    }
    if(evaTurn > 0) {
      evaTurn--;
      if(evaTurn == 0) {
        evaVal = 0;
      }
    }
  }
}
