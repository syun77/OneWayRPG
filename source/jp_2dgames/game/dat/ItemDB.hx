package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテム特殊効果
 **/
enum ItemExt {
  None;    // なし
  DexUp;   // 命中率上昇
  EvaUp;   // 回避率上昇
}

/**
 * アイテムDB
 **/
class ItemDB {

  public static function get(id:ItemsKind):Items {
    return MyDB.items.get(id);
  }

  public static function getCategory(id:ItemsKind):Items_category {
    return get(id).category;
  }
  // 武器かどうか
  public static function isWeapon(id:ItemsKind):Bool {
    return getCategory(id) == Items_category.Weapon;
  }

  public static function getName(id:ItemsKind):String {
    return get(id).name;
  }

  public static function getPower(id:ItemsKind):Int {
    return get(id).power;
  }

  public static function getHit(id:ItemsKind):Int {
    return Std.int(get(id).hit * 100);
  }

  public static function getAttribute(id:ItemsKind):AttributesKind {
    return get(id).attr.id;
  }

  public static function getBadStatus(id:ItemsKind):BadstatusesKind {
    return get(id).bst.id;
  }

  public static function getCoolDown(id:ItemsKind):Int {
    return get(id).cd;
  }

  public static function getDetail(id:ItemsKind):String {
    return get(id).detail;
  }
  public static function getDetailLast(id:ItemsKind):String {
    return get(id).detail_last;
  }

  public static function getMin(id:ItemsKind):Int {
    return get(id).min;
  }

  public static function getMax(id:ItemsKind):Int {
    return get(id).max;
  }

  public static function getHp(id:ItemsKind):Int {
    return get(id).hp;
  }

  // 攻撃回数
  public static function getCount(id:ItemsKind):Int {
    return get(id).count;
  }

  // 拡張パラメータの値を取得する
  public static function getExt(id:ItemsKind):ItemExt {
    return switch(get(id).ext) {
      case Items_ext.none:  ItemExt.None;
      case Items_ext.dexup: ItemExt.DexUp;
      case Items_ext.evaup: ItemExt.EvaUp;
    }
  }

  // 拡張パラメータを取得する
  public static function getExtVal(id:ItemsKind):Int {
    return get(id).extval;
  }

  public static function getBuy(id:ItemsKind):Int {
    return get(id).buy;
  }
}
