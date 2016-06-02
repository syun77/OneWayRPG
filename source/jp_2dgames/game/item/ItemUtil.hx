package jp_2dgames.game.item;

import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.sequence.btl.BtlLogic;
import jp_2dgames.game.sequence.btl.BtlLogicFactory;
import jp_2dgames.game.SeqMgr;
import jp_2dgames.game.sequence.btl.BtlCalc;
import jp_2dgames.game.dat.ResistData.ResistList;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.ItemDB;
import jp_2dgames.lib.TextUtil;
import flixel.FlxG;
import jp_2dgames.game.dat.MyDB;

/**
 * アイテムの分類
 **/
enum ItemCategory {
  Portion;
  Weapon;
}

/**
 * アイテム操作のユーティリティ
 **/
class ItemUtil {

  // 名前を取得 (使用回数付与)
  public static function getName(item:ItemData):String {
    var name = getName2(item);
    if(item.isSpecial()) {
      // スペシャルは使用回数を付与しない
      return name;
    }
    return '${name} (${item.now}/${item.max})';
  }
  public static function getName2(item:ItemData):String {
    var name = ItemDB.getName(item.id);
    if(item.buff > 0) {
      // 強化ポイント表示
      name = '${name}+${item.buff}';
    }
    return name;
  }
  public static function getName3(item:ItemData):String {
    var name = getName(item);
    // 価格を付与
    var cost = ItemDB.getBuy(item.id);
    name += ' ${cost}G';
    return name;
  }

  // 威力を取得
  public static function getPower(item:ItemData):Int {
    return ItemDB.getPower(item.id) + item.buff;
  }

  // 命中率を取得
  public static function getHit(item:ItemData):Int {
    return ItemDB.getHit(item.id);
  }

  // 属性を取得
  public static function getAttribute(item:ItemData):Attribute {
    return AttributeUtil.fromKind(ItemDB.getAttribute(item.id));
  }

  // 付着するバステを取得
  public static function getBadStatus(item:ItemData):BadStatus {
    return BadStatusUtil.fromKind(ItemDB.getBadStatus(item.id));
  }

  /**
   * 無効なアイテムかどうか
   **/
  public static function isNone(id:ItemsKind):Bool {
    return id == ItemsKind.None;
  }

  /**
   * カテゴリを取得
   **/
  public static function getCategory(item:ItemData):ItemCategory {
    switch(ItemDB.getCategory(item.id)) {
      case Items_category.Portion:
        return ItemCategory.Portion;
      case Items_category.Weapon:
        return ItemCategory.Weapon;
    }
  }


  // ダメージ値取得
  public static function calcDamage(owner:SeqMgr, item:ItemData, bMultiple:Bool, resists:ResistList):Int {

    var power  = ItemUtil.getPower(item);
    var attr   = ItemUtil.getAttribute(item);
    var actor  = owner.player;
    var target = owner.enemy;
    if(resists == null) {
      target = null;
    }
    if(item.isLast()) {
      // 最後の一撃
      power *= BtlCalc.LAST_MULTI;
    }
    var val = BtlCalc.damage(power, attr, actor, target);
    var count = 1;
    if(bMultiple) {
      // 複数回攻撃を含める
      count = getCount(item);
    }
    var sum = (val * count);

    return sum;
  }

  public static function getMin(item:ItemData):Int {
    return ItemDB.getMin(item.id);
  }

  public static function getMax(item:ItemData):Int {
    return ItemDB.getMax(item.id);
  }

  public static function getCount(item:ItemData):Int {
    var count = ItemDB.getCount(item.id);
    if(count == 0) {
      return 1;
    }
    return count;
  }

  public static function getHp(item:ItemData):Int {
    return ItemDB.getHp(item.id);
  }

  public static function getExt(item:ItemData):ItemExt {
    return ItemDB.getExt(item.id);
  }

  public static function getExtVal(item:ItemData):Int {
    return ItemDB.getExtVal(item.id);
  }
  public static function getExtVal2(item:ItemData):Int {
    var val = getExtVal(item);
    if(item.isLast()) {
      return val * 3;
    }
    return val;
  }

  /**
   * アイテムを生成
   **/
  public static function add(itemid:ItemsKind):ItemData {
    var item = new ItemData();
    item.id = itemid;
    var min = getMin(item);
    var max = getMax(item);
    item.max = FlxG.random.int(min, max);
    item.now = item.max;

    return item;
  }

  /**
   * スペシャルアイテムを生成
   **/
  public static function addSpecial(itemid:ItemsKind):ItemData {
    var item = new ItemData();
    item.id = itemid;
    item.bSpecial = true;
    item.max = ItemDB.getCoolDown(itemid);
    item.now = item.max;

    return item;
  }
}
