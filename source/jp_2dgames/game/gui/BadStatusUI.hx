package jp_2dgames.game.gui;
import jp_2dgames.game.actor.BadStatusUtil;
import flixel.group.FlxSpriteGroup;

/**
 * バッドステータスUI
 **/
class BadStatusUI extends FlxSpriteGroup {

  static inline var MAX:Int = 5;
  // 1つのアイコンのサイズ
  static inline var ICON_WIDTH:Int = 16;

  // --------------------------------------------
  // ◆フィールド
  var _list:Array<BadStatusIcon>;

  /**
   * コンストラクタ
   **/
  public function new(X:Float, Y:Float) {
    super(X, Y);

    _list = new Array<BadStatusIcon>();
    for(i in 0...MAX) {
      var px = i * ICON_WIDTH;
      var icon = new BadStatusIcon(px, 0);
      icon.play(BadStatus.None);
      _list.push(icon);
      this.add(icon);
    }
  }

  /**
   * 表示内容を設定
   **/
  public function set(array:Array<BadStatus>):Void {
    for(i in 0...MAX) {
      var bst = BadStatus.None;
      if(i < array.length) {
        bst = array[i];
      }
      _list[i].play(bst);
    }
  }
}
