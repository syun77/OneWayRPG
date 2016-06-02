package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * クラスの初期パラメータ
 **/
class ClassDB {

  public static function get(id:ClassesKind):Classes {
    return MyDB.classes.get(id);
  }

  public static function getName(id:ClassesKind):String {
    return get(id).name;
  }

  public static function getDetail(id:ClassesKind):String {
    return get(id).detail;
  }

  public static function getItems(id:ClassesKind):Array<ItemsKind> {
    var ret = new Array<ItemsKind>();
    for(item in get(id).items) {
      ret.push(item.item.id);
    }
    return ret;
  }

  public static function getSpecial(id:ClassesKind):ItemsKind {
    return get(id).special.id;
  }

  public static function getHp(id:ClassesKind):Int {
    return get(id).hp;
  }

  public static function getFood(id:ClassesKind):Int {
    return get(id).food;
  }

  public static function getVit(id:ClassesKind):Int {
    return get(id).vit;
  }

  public static function getDex(id:ClassesKind):Int {
    return get(id).dex;
  }

  public static function getAgi(id:ClassesKind):Int {
    return get(id).agi;
  }
}
