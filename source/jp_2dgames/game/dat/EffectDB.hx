package jp_2dgames.game.dat;
import jp_2dgames.game.dat.MyDB;

/**
 * エフェクトの種類
 **/
enum EffectType {
  EftBst;   // バッドステータス
  EftPhys;  // 物理攻撃
  EftGun;   // 銃攻撃
  EftFire;  // 炎攻撃
  EftIce;   // 氷攻撃
  EftShock; // 雷攻撃
  EftWind;  // 疾風攻撃
  EftLastAttack; // 最後の一撃
}

/**
 * エフェクトDB
 **/
class EffectDB {

  static function typeToKind(type:EffectType):EffectsKind {
    return switch(type) {
      case EffectType.EftBst:   EffectsKind.EftBadStatus;
      case EffectType.EftPhys:  EffectsKind.EftPhysics;
      case EffectType.EftGun:   EffectsKind.EftGun;
      case EffectType.EftFire:  EffectsKind.EftFire;
      case EffectType.EftIce:   EffectsKind.EftIce;
      case EffectType.EftShock: EffectsKind.EftPhysics;
      case EffectType.EftWind:  EffectsKind.EftPhysics;
      case EffectType.EftLastAttack: EffectsKind.EftLastAttack;
    }
  }

  public static function get(id:EffectsKind):Effects {
    return MyDB.effects.get(id);
  }

  public static function getFile(type:EffectType):String {
    var id = typeToKind(type);
    var file = get(id).file;
    return StringTools.replace(file, "../../../../", "");
  }
  public static function getSpeed(type:EffectType):Int {
    var id = typeToKind(type);
    return get(id).speed;
  }
  public static function getSe(type:EffectType):String {
    var id = typeToKind(type);
    return get(id).se;
  }
  public static function getWidth(type:EffectType):Int {
    var id = typeToKind(type);
    return get(id).width;
  }
  public static function getHeight(type:EffectType):Int {
    var id = typeToKind(type);
    return get(id).height;
  }
}
