package jp_2dgames.game.gui;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import flixel.FlxSprite;

/**
 * バッドステータスアイコン
 **/
class BadStatusIcon extends FlxSprite {

  var _bst:BadStatus;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);
    loadGraphic("assets/images/badstatus.png", true);
    _registerAnim();
    play(BadStatus.Poison);
  }

  /**
   * アニメーション再生
   **/
  public function play(bst:BadStatus):Void {
    _bst = bst;
    if(_bst == BadStatus.None) {
      visible = false;
    }
    else {
      animation.play('${_bst}');
      visible = true;
    }
  }

  /**
   * アニメーション登録
   **/
  function _registerAnim():Void {
    animation.add('${BadStatus.Death}',    [0], 0);
    animation.add('${BadStatus.Poison}',   [1], 0);
    animation.add('${BadStatus.Confuse}',  [2], 0);
    animation.add('${BadStatus.Close}',    [3], 0);
    animation.add('${BadStatus.Paralyze}', [4], 0);
    animation.add('${BadStatus.Sleep}',    [5], 0);
    animation.add('${BadStatus.Blind}',    [6], 0);
    animation.add('${BadStatus.Curse}',    [7], 0);
    animation.add('${BadStatus.Weaken}',   [8], 0);
    animation.add('${BadStatus.Stan}',     [9], 0);
  }
}
