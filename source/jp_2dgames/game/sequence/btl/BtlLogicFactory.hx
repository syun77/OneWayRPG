package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.gui.message.Msg;
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
      var attr = ItemUtil.getAttribute(item);
      var data = new BtlLogicData(BtlLogic.UseItem(item), player.uid, enemy.uid);
      ret.add(data);
    }
    if(ItemUtil.getCategory(item) == ItemCategory.Weapon) {
      if(item.now == 1) {
        // 最後の一撃
        ret.add(new BtlLogicData(BtlLogic.BeginLastAttack, player.uid, enemy.uid));
      }
    }

    // 一度でも攻撃が命中したかどうか
    var bHit:Bool = false;
    var count = _getActionCount(BtlGroup.Player, item);
    while(count > 0) {
      count--;

      switch(ItemUtil.getCategory(item)) {
        case ItemCategory.Portion:
          // ■回復
          var hp = ItemUtil.getHp(item);
          if(item.now == 1) {
            // 最後の1回
            hp *= BtlCalc.LAST_MULTI;
          }
          var data = new BtlLogicData(BtlLogic.HpRecover(hp), player.uid, player.uid);
          ret.add(data);
          player.recover(hp);
          // 命中したことにする
          bHit = true;

        case ItemCategory.Weapon:
          // 武器
          var power = ItemUtil.getPower(item);
          if(item.now == 1) {
            // 最後の一撃
            power *= BtlCalc.LAST_MULTI;
          }
          var prm = new DamageParam(player, enemy, power, ItemUtil.getHit(item));
          prm.attr  = ItemUtil.getAttribute(item);
          prm.bst   = ItemUtil.getBadStatus(item);
          prm.bSeq  = (count > 0);
          if(_createDamage(ret, prm)) {
            // 命中した
            bHit = true;
          }
      }
    }

    // アイテム使用回数減少
    ret.add(new BtlLogicData(BtlLogic.DecayItem(item), player.uid, enemy.uid));

    // 行動終了
    ret.add(new BtlLogicData(BtlLogic.EndAction(bHit), player.uid, player.uid));

    return ret;
  }

  /**
   * 自動攻撃
   **/
  static function _createAutoAttack(ret:List<BtlLogicData>, actor:Actor, target:Actor):List<BtlLogicData> {

    // 自動攻撃開始メッセージ表示
    var data = new BtlLogicData(BtlLogic.MessageDisp(Msg.AUTO_ATTACK, null), actor.uid, target.uid);
    data.bWaitQuick = true;
    // 攻撃開始
    var attr = Attribute.Phys;
    ret.add(new BtlLogicData(BtlLogic.BeginAttack(attr), actor.uid, target.uid));

    // 1回攻撃・命中率100%・物理
    var prm = new DamageParam(actor, target, 1, 100);
    prm.attr = attr;
    _createDamage(ret, prm);
    return ret;
  }

  /**
   * ダメージのLogicDataを作成
   **/
  static function _createDamage(ret:List<BtlLogicData>, prm:DamageParam):Bool {
    var ratio = BtlCalc.hit(prm.hit, prm.actor, prm.target);
    if(FlxG.random.bool(ratio)) {
      // 命中
      var damage = BtlCalc.damage(prm.power, prm.attr, prm.actor, prm.target);
      var type = BtlLogic.HpDamage(damage, prm.bSeq);
      var data = new BtlLogicData(type, prm.actor.uid, prm.target.uid);
      data.bWaitQuick = prm.bSeq;
      prm.target.damage(damage);
      ret.add(data);

      if(prm.target.isDead() == false) {
        // バステ付着
        if(prm.bst != BadStatus.None) {
          ret.add(new BtlLogicData(BtlLogic.Badstatus(prm.bst), prm.actor.uid, prm.target.uid));
          prm.target.adhereBadStatus(prm.bst);
        }
      }
      return true;
    }
    else {
      // 外れ
      var data = new BtlLogicData(BtlLogic.ChanceRoll(false), prm.actor.uid, prm.target.uid);
      data.bWaitQuick = prm.bSeq;
      ret.add(data);
      return false;
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
    var attr   = Attribute.Phys;
    {
      // 攻撃開始
      var data = new BtlLogicData(BtlLogic.BeginAttack(attr), actor.uid, target.uid);
      ret.add(data);
    }

    // 命中したかどうか
    var bHit = false;
    // 1回攻撃・命中率100%・物理
    {
      var prm = new DamageParam(actor, target, enemy.str, EnemyDB.getHit(enemy.id));
      prm.attr = attr;
      if(_createDamage(ret, prm)) {
        // 命中した
        bHit = true;
      }
    }

    // 行動終了
    ret.add(new BtlLogicData(BtlLogic.EndAction(bHit), actor.uid, actor.uid));

    return ret;
  }

  /**
   * ターン終了演出の生成 (バッドステータス)
   **/
  public static function createTurnEndBadStatus(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();

    if(actor.isAdhereBadStatus(BadStatus.Poison)) {
      // 毒ダメージ
      // 最大HPの5%ダメージ
      var v = Std.int(actor.hpmax * 0.05);
      if(v < 1) {
        v = 1;
      }
      var type = BtlLogic.HpDamage(v, false);
      ret.add(new BtlLogicData(type, actor.uid, actor.uid));
    }

    return ret;
  }

  /**
   * ターン終了演出の生成
   **/
  public static function createTurnEnd(actor:Actor):List<BtlLogicData> {

    var ret = new List<BtlLogicData>();
    ret.add(new BtlLogicData(BtlLogic.TurnEnd, actor.uid, actor.uid));

    return ret;
  }
}

/**
 * ダメージパラメータ
 **/
private class DamageParam {
  public var actor:Actor;    // 主体者
  public var target:Actor;   // 対象者
  public var power:Int;      // 威力
  public var hit:Int;        // 命中率
  public var attr:Attribute; // 属性
  public var bst:BadStatus;  // 付着するバステ
  public var bSeq:Bool;      // 連続攻撃かどうか

  /**
   * コンストラクタ
   **/
  public function new(actor:Actor, target:Actor, power:Int, hit:Int) {
    this.actor  = actor;
    this.target = target;
    this.power  = power;
    this.hit    = hit;
    attr = Attribute.Phys;
    bst  = BadStatus.None;
    bSeq = false;
  }
}
