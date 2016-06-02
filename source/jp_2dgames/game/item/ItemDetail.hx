package jp_2dgames.game.item;

import flixel.FlxG;
import jp_2dgames.lib.TextUtil;
import jp_2dgames.game.sequence.btl.BtlCalc;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.dat.ItemDB;
import jp_2dgames.game.item.ItemUtil.ItemCategory;
import jp_2dgames.game.dat.ResistData.ResistList;
import jp_2dgames.game.SeqMgr;

/**
 * アイテム詳細情報
 **/
class ItemDetailData {
  public var power:Int;        // 1: 基本攻撃力(攻: N)
  public var bLastAttack:Bool; // 1: 最後の一撃かどうか(x 3)
  public var count:Int;        // 2: 攻撃回数(回数: x N)
  public var resists:Float;    // 3: 属性倍率(属性: x N)
                               // 4: ---------- \n
  public var sum:Int;          // 5: 計 or 最大(計: Nダメージ)
  public var hit:Int;          // 6: 命中率(命中率: N%)

  public function new() {
    power       = 0;
    bLastAttack = false;
    count       = 1;
    resists     = 1;
    sum         = 0;
    hit         = 100;
  }
}

class ItemDetail {

  /**
   * 武器の詳細情報を取得
   **/
  public static function getWeapon(owner:SeqMgr, item:ItemData, resists:ResistList):ItemDetailData {

    var ret = new ItemDetailData();

    var player = owner.player;
    var enemy = owner.enemy;

    var str = player.str;
    ret.power = ItemUtil.getPower(item) + str;
    ret.count = ItemUtil.getCount(item);
    var attr  = ItemUtil.getAttribute(item);
    ret.hit   = BtlCalc.hit(ItemUtil.getHit(item), player, enemy);
    ret.sum   = ItemUtil.calcDamage(owner, item, true, resists);
    if(item.isLast()) {
      // 最後の一撃
      ret.bLastAttack = true;
    }
    if(resists != null) {
      ret.resists = resists.getValue(attr);
    }

    return ret;
  }

  /**
   * 通常の詳細説明文
   **/
  public static function getDetail(item:ItemData):String {
    if(item.isLast()) {
      // 最後に一回用の説明文
      return ItemDB.getDetailLast(item.id);
    }
    return ItemDB.getDetail(item.id);
  }

  public static function build(data:ItemDetailData):String {
    var ret = "";
    var cntBR:Int = 0;
    var power = TextUtil.fillSpace(data.power, 2); // flash対応
    ret += '攻: ${power} \n';
    if(data.resists != 1.0) {
      var val = '${data.resists}';
      if(val.length%2 == 1) {
        val = ' ${val}'; // flash対応
      }
      ret += '属性: x ${val}\n';
    }
    else {
      cntBR++;
    }
    if(data.count > 1) {
      var count = TextUtil.fillSpace(data.count, 2); // flash対応
      ret += '回数: x ${count}\n';
    }
    else {
      cntBR++;
    }
    for(i in 0...cntBR) {
      // 改行を入れる
      ret += '\n';
    }
    var sum = TextUtil.fillSpace(data.sum, 2); // flash対応
    ret += '---------- \n';
    ret += '        ダメージ\n';
    //ret += ': ${sum}ダメージ\n';
    var hitratio = TextUtil.fillSpace(data.hit, 3); // flash対応
    ret += '(命中率: ${hitratio}%)';


    return ret;
  }
}
