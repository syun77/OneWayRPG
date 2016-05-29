package jp_2dgames.game.actor;
import jp_2dgames.lib.StatusBar;
import flash.display.BlendMode;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

/**
 * シールド
 **/
class Shield extends FlxSpriteGroup {

  // タイマー
  static inline var TIMER_SHAKE:Int = 120; // 揺れタイマー

  // ---------------------------------------------
  // ■フィールド
  var _spr:FlxSprite;
  var _bar:StatusBar;
  var _tAnim:Int = 0; // アニメタイマー
  var _tShake:Float = 0.0; // 揺れ用のタイマー

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
    _spr = new FlxSprite(0, 0, AssetPaths.IMAGE_SHIELD);
    _spr.color = MyColor.LIME;
    this.add(_spr);

    _bar = new StatusBar(80, 32, 48, 4, true);
    this.add(_bar);

    FlxTween.tween(_spr, {angle:360}, 30, {type:FlxTween.LOOPING});
    _spr.blend = BlendMode.ADD;
    _spr.alpha = 0.2;
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnim++;

    // 揺れの更新
    _updateShake(elapsed);

  }

  public function setPercent(v:Float):Void {
    _bar.setPercent(100 * v);
  }

  /**
   * 揺れ開始
   **/
  public function startShake(ratio:Float=1.0):Void {
    _tShake = Std.int(TIMER_SHAKE * ratio);
    _spr.alpha = 1.0;
    FlxTween.tween(_spr, {alpha:0.2}, 0.5);
  }

  /**
   * 揺れの更新
   **/
  function _updateShake(elapsed:Float):Void {
    if(_tShake > 0) {
      _tShake *= 0.9;
      if(_tShake < 1) {
        _tShake = 0;
      }
      var xsign = if(_tAnim%4 < 2) 1 else -1;
      _spr.x =  x + (_tShake * xsign * 0.2);
    }
  }
}
