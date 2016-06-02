package jp_2dgames.game.state;

import flixel.addons.ui.FlxUIState;

/**
 * キャラメイク画面
 **/
class MakeCharacterState extends FlxUIState {

  /**
   * 生成
   **/
  override public function create():Void {

    _xml_id = "makecharacter";

    super.create();
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }
}
