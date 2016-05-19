package jp_2dgames.game.particle;

import jp_2dgames.lib.MyColor;
import flixel.util.FlxColor;
import jp_2dgames.lib.DirUtil;
import jp_2dgames.game.gui.BattleUI;

/**
 * パーティクルのユーティリティ
 **/
class ParticleUtil {

  /**
   * 食糧増える演出
   **/
  public static function startFood(val:Int):Void {
    var pt = BattleUI.getFoodPosition();
    var str = '+${val}';
    if(val < 0) {
      str = '-${val}';
    }
    ParticleBmpFont.start(pt.x, pt.y, str, MyColor.LIME, Dir.Down);
    pt.put();
  }

  /**
   * お金増える演出
   **/
  public static function startMoney(val:Int):Void {
    var pt = BattleUI.getMoneyPosition();
    var str = '+${val}';
    if(val < 0) {
      str = '-${val}';
    }
    ParticleBmpFont.start(pt.x, pt.y, str, FlxColor.LIME, Dir.Down);
    pt.put();
  }
}
