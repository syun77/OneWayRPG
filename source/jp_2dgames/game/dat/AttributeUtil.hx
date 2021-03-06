package jp_2dgames.game.dat;

import jp_2dgames.game.dat.EffectDB.EffectType;
import jp_2dgames.game.dat.MyDB;

/**
 * 属性情報
 **/
enum Attribute {
  None;   // なし
  Phys;   // 物理
  Gun;    // 銃
  Fire;   // 炎
  Ice;    // 氷
  Shock;  // 雷
  Wind;   // 風
}

class AttributeUtil {
  public static function fromKind(kind:AttributesKind):Attribute {
    return switch(kind) {
      case AttributesKind.None:  Attribute.None;
      case AttributesKind.Phys:  Attribute.Phys;
      case AttributesKind.Gun:   Attribute.Gun;
      case AttributesKind.Fire:  Attribute.Fire;
      case AttributesKind.Ice:   Attribute.Ice;
      case AttributesKind.Shock: Attribute.Shock;
      case AttributesKind.Wind:  Attribute.Wind;
    }
  }

  /**
   * 属性アイコン画像のパスを取得する
   **/
  public static function getIconPath(attr:Attribute):String {
    var base = "assets/gfx/ui/icon/";
    return switch(attr) {
      case Attribute.None:  "";
      case Attribute.Phys:  base + "phys.png";
      case Attribute.Gun:   base + "gun.png";
      case Attribute.Fire:  base + "fire.png";
      case Attribute.Ice:   base + "ice.png";
      case Attribute.Shock: base + "shock.png";
      case Attribute.Wind:  base + "wind.png";
    }
  }

  /**
   * 属性に対応するエフェクトに変換
   **/
  public static function toEffectType(attr:Attribute):EffectType {
    return switch(attr) {
      case Attribute.None:  EffectType.EftPhys;
      case Attribute.Phys:  EffectType.EftPhys;
      case Attribute.Gun:   EffectType.EftGun;
      case Attribute.Fire:  EffectType.EftFire;
      case Attribute.Ice:   EffectType.EftIce;
      case Attribute.Shock: EffectType.EftShock;
      case Attribute.Wind:  EffectType.EftWind;
    }
  }
}