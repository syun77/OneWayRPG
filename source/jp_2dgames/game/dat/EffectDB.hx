package jp_2dgames.game.dat;
import jp_2dgames.game.dat.MyDB;

/**
 * エフェクトの種類
 **/
enum EffectType {
  EftBst; // バッドステータス
}

/**
 * エフェクトDB
 **/
class EffectDB {

  static function typeToKind(type:EffectType):EffectsKind {
    return switch(type) {
      case EftBst: return EffectsKind.EftBadStatus;
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
