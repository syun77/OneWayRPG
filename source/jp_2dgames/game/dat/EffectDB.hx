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
      case EffectType.EftFire:  EffectsKind.EftPhysics;
      case EffectType.EftIce:   EffectsKind.EftPhysics;
      case EffectType.EftShock: EffectsKind.EftPhysics;
      case EffectType.EftWind:  EffectsKind.EftPhysics;
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
}
