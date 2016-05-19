package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.dat.AttributeUtil.Attribute;
import jp_2dgames.game.actor.BadStatusUtil.BadStatus;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.sequence.btl.BtlLogic;
import flixel.FlxG;
import jp_2dgames.game.actor.Actor;

/**
 * バトルの数値計算
 **/
class BtlCalc {

  // 最後の一撃の倍率
  public static inline var LAST_MULTI:Int = 3;

  // 回避時のダメージ量
  public static inline var VAL_EVADE:Int = -1;

  // 回避率補正値
  public static inline var HIT_EVADE:Int = 3; // 回避ごとに上昇する値
  public static inline var HIT_BLIND:Int = -10; // 盲目補正
  public static inline var HIT_PARALYZE:Int = 10; // 麻痺補正
  public static inline var HIT_DEX:Int = 2; // DEX補正
  public static inline var HIT_AGI:Int = 2; // AGI補正

  public static function hit(ratio:Int, actor:Actor, target:Actor):Int {

    // 回避回数に応じて命中率変化
    ratio += actor.btlPrms.cntAttackEvade * HIT_EVADE;

    if(actor.isAdhereBadStatus(BadStatus.Blind)) {
      // 盲目なので命中率低下
      ratio += HIT_BLIND;
    }
    if(target.isAdhereBadStatus(BadStatus.Paralyze)) {
      // 麻痺なので回避率低下
      ratio += HIT_PARALYZE;
    }

    // DEX / AGI の値に応じて2%ずつ補正
    ratio += (actor.dex * HIT_DEX);
    ratio -= (target.agi * HIT_AGI);
    if(ratio < 0) {
      ratio = 0;
    }

    return ratio;
  }

  /**
   * 命中確率の取得
   **/
  public static function hitFromParam(prm:BtlLogicAttackParam, actor:Actor, target:Actor):Int {

    // 補正値なしの命中率を取得
    var ratio:Int = prm.ratioRaw;

    return hit(ratio, actor, target);
  }

  /**
   * 攻撃命中判定
   **/
  public static function isHit(prm:BtlLogicAttackParam, actor:Actor, target:Actor):Bool {
    var hit = hitFromParam(prm, actor, target);
    return FlxG.random.bool(hit);
  }

  /**
   * ダメージ量計算
   **/
  public static function damage(power:Int, attr:Attribute, actor:Actor, target:Actor):Int {

    // ダメージ量
    var damage = power;
    // 属性ボーナス
    var value:Float = 1;
    if(target != null) {
      var resisits = EnemyDB.getResists(target.id);
      value = resisits.getValue(attr);
    }
    damage = Math.ceil(damage * value);

    return damage;
  }
}

