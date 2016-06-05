package jp_2dgames.game.dat;

import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.AttributeUtil.Attribute;
import jp_2dgames.game.dat.MyDB;

/**
 * クラスの初期パラメータ
 **/
class ClassDB {

  public static function get(id:ClassesKind):Classes {
    return MyDB.classes.get(id);
  }

  public static function count():Int {
    return MyDB.classes.all.length;
  }

  public static function idxToKind(idx:Int):ClassesKind {
    return MyDB.classes.all[idx].id;
  }

  public static function forEach(func:ClassesKind->Void):Void {
    for(info in MyDB.classes.all) {
      func(info.id);
    }
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

  public static function getHit(id:ClassesKind, attr:Attribute):Float {
    var hits = get(id).hits;
    for(hit in hits) {
      if(attr == AttributeUtil.fromKind(hit.attr.id)) {
        return hit.ratio;
      }
    }

    return 1.0;
  }

  public static function getDrop(id:ClassesKind, attr:AttributesKind):Float {
    var drops = get(id).drops;
    for(drop in drops) {
      if(attr == drop.attr.id) {
        return drop.ratio;
      }
    }

    // 見つからなかった
    return 0;
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
