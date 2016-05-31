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
  public static inline var HIT_EVADE_MULTI:Float = 1.1; // 回避ごとに上昇する値 (10%)
  public static inline var HIT_BLIND:Float = 0.8; // 盲目補正
  public static inline var HIT_PARALYZE:Float = 1.2; // 麻痺補正
  public static inline var HIT_DEX:Float = 0.02;  // DEX補正
  public static inline var HIT_AGI:Float = -0.02; // AGI補正

  /**
   * 命中率補正(*)
   **/
  public static function hitMulti(actor:Actor):Float {
    var ret = hit(100, actor, null);
    return ret / 100;
  }

  /**
   * 回避率補正(+)
   **/
  public static function evadePlus(actor:Actor):Int {
    var ret = hit(100, null, actor);
    return Std.int(100 - ret);
  }

  public static function hit(ratio:Int, actor:Actor, target:Actor):Int {

    var ret:Float = ratio;

    if(actor != null) {
      // 回避回数に応じて命中率変化 (1.1^cnt)
      ret *= Math.pow(HIT_EVADE_MULTI, actor.btlPrms.cntAttackEvade);

      if(actor.isAdhereBadStatus(BadStatus.Blind)) {
        // 盲目なので命中率低下
        ret *= HIT_BLIND;
      }
    }
    if(target != null) {
      if(target.isAdhereBadStatus(BadStatus.Paralyze)) {
        // 麻痺なので回避率低下
        ret *= HIT_PARALYZE;
      }
    }

    // 命中率補正・回避率補正
    if(actor != null) {
      ret *= (1 + actor.dex * HIT_DEX);
      ret *= (1 + actor.btlPrms.dexVal/100);
    }
    if(target != null) {
      ret += 100 * (target.agi * HIT_AGI);
      ret += 100 * (-target.btlPrms.evaVal/100);
    }
    if(ret < 0) {
      ret = 0;
    }

    return Std.int(ret);
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
    // 防御力補正
    if(target != null) {
      damage -= target.vit;
    }
    // 属性ボーナス
    var value:Float = 1;
    if(target != null) {
      var resisits = EnemyDB.getResists(target.id);
      value = resisits.getValue(attr);
    }
    damage = Math.ceil(damage * value);

    if(damage <= 0) {
      // 1より小さくはならない
      damage = 1;
    }

    return damage;
  }
}

