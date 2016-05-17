package jp_2dgames.game.sequence.btl;

import flixel.FlxG;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.sequence.btl.BtlCalc;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.sequence.btl.BtlLogic;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.actor.BtlGroupUtil;

/**
 * BtlLogicDataの生成
 **/
class BtlLogicFactory {

  /**
   * 行動回数を計算
   **/
  static function _getActionCount(group:BtlGroup, item:ItemData):Int {
    switch(group) {
      case BtlGroup.Both:
        return 1;

      case BtlGroup.Player:
        if(ItemList.isEmpty()) {
          // 自動攻撃
          return 1;
        }

        return ItemUtil.getCount(item);

      case BtlGroup.Enemy:
        return 1;
    }
  }

  /**
   * プレイヤーのBtlLogicDataを生成
   **/
  public static function createPlayerLogic(player:Actor, enemy:Actor, item:ItemData):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    if(ItemList.isEmpty()) {
      // 自動攻撃
      ret = _createAutoAttack(ret, player, enemy);
      return ret;
    }

    // 通常の処理
    {
      // アイテムを使う
      var data = new BtlLogicData(BtlLogic.UseItem(item), player.uid, enemy.uid);
      ret.add(data);
    }

    var count = _getActionCount(BtlGroup.Player, item);
    while(count > 0) {
      count--;

      switch(ItemUtil.getCategory(item)) {
        case ItemCategory.Portion:
          // ■回復
          var hp = ItemUtil.getHp(item);
          if(item.now == 1) {
            // 最後の1回
            hp *= 3;
          }
          var data = new BtlLogicData(BtlLogic.HpRecover(hp), player.uid, player.uid);
          ret.add(data);
          player.recover(hp);

        case ItemCategory.Weapon:
          // 武器
          var power = ItemUtil.getPower(item);
          if(item.now == 1) {
            // 最後の一撃
            power *= 3;
          }
          var ratioRaw = ItemUtil.getHit(item);
          var attr  = ItemUtil.getAttribute(item);
          var bst   = ItemUtil.getBadStatus(item);
          var bSeq  = (count > 0);
          ret.add(_createDamage(player, enemy, power, ratioRaw, attr, bSeq));
      }
    }

    return ret;
  }

  /**
   * 自動攻撃
   **/
  static function _createAutoAttack(ret:List<BtlLogicData>, actor:Actor, target:Actor):List<BtlLogicData> {

    /*
    {
      // 攻撃開始
      var type = BtlLogic.BeginAtttack;
      var data = new BtlLogicData(type, actor, target);
      ret.add(data);
    }
    */

    // 1回攻撃・命中率100%・物理
    var power    = 1;
    var attr     = Attribute.Phys;
    var ratioRaw = 100;
    ret.add(_createDamage(actor, target, power, ratioRaw, attr, false));
    return ret;
  }

  /**
   * ダメージのLogicDataを作成
   **/
  static function _createDamage(actor:Actor, target:Actor, power:Int, hit:Int, attr:Attribute, bSeq:Bool):BtlLogicData {
    var ratio = BtlCalc.hit(hit, actor, target);
    if(FlxG.random.bool(ratio)) {
      // 命中
      var damage = BtlCalc.damage(power, attr, actor, target);
      var type = BtlLogic.HpDamage(damage, bSeq);
      var data = new BtlLogicData(type, actor.uid, target.uid);
      data.bWaitQuick = bSeq;
      target.damage(damage);
      return data;
    }
    else {
      // 外れ
      var data = new BtlLogicData(BtlLogic.ChanceRoll(false), actor.uid, target.uid);
      data.bWaitQuick = bSeq;
      return data;
    }
  }

  /**
   * 敵のBtlLogicDataを生成
   **/
  public static function createEnemyLogic(player:Actor, enemy:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    var count = 1;
    var actor  = enemy;
    var target = player;
    {
      // 攻撃開始
      var type = BtlLogic.BeginAttack;
      var data = new BtlLogicData(type, actor.uid, target.uid);
      ret.add(data);
    }

    // 1回攻撃・命中率100%・物理
    var power = enemy.str;
    var attr  = Attribute.Phys;
    var bst   = BadStatus.None;
    var ratioRaw = EnemyDB.getHit(enemy.id);
    ret.add(_createDamage(actor, target, power, ratioRaw, attr, false));
    return ret;
  }
}
