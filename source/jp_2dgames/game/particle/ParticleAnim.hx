package jp_2dgames.game.particle;

import flixel.FlxG;
import jp_2dgames.game.dat.EffectDB;
import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

/**
 * 指定の連番画像を再生する
 **/
class ParticleAnim extends FlxSprite {

  public static var parent:FlxTypedGroup<ParticleAnim> = null;
  public static function createParent(state:FlxState):Void {
    parent = new FlxTypedGroup<ParticleAnim>();
    state.add(parent);
  }
  public static function destroyParent():Void {
    parent = null;
  }
  public static function start(type:EffectType, X:Float, Y:Float, c:FlxColor=FlxColor.WHITE):ParticleAnim {
    var anim = parent.recycle(ParticleAnim);
    anim.init(type, X, Y, c);
    return anim;
  }

  // ----------------------------------------
  // ■フィールド
  var _type:EffectType;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();
  }

  /**
   * 初期化
   **/
  public function init(type:EffectType, X:Float, Y:Float, c:FlxColor):Void {

    _type = type;
    color = c;

    var path = EffectDB.getFile(type);
    var speed = EffectDB.getSpeed(type);
    loadGraphic(path, true);
    var cnt = frames.numFrames;
    animation.add("play", [for(i in 0...cnt) i], speed, false);
    animation.play("play");

    x = X - (origin.x - offset.x);
    y = Y - (origin.y - offset.y);
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(animation.finished) {
      // 再生が終わったら消す
      // 読み込んだ画像をキャッシュから削除
      var path = EffectDB.getFile(_type);
      var bmp = FlxG.bitmap.get(path);
      FlxG.bitmap.remove(bmp);
      kill();
    }
  }
}
