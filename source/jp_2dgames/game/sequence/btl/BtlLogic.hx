package jp_2dgames.game.sequence.btl;

import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.game.dat.AttributeUtil;

/**
 * 攻撃行動のパラメータ
 **/
class BtlLogicAttackParam {
  public var power:Int;      // ダメージ量
  public var ratio:Int;      // 命中率
  public var ratioRaw:Int;   // 主体者・対象者による補正がな状態の命中率
  public var attr:Attribute; // 属性
  public var bst:BadStatus;  // 付着するバステ

  /**
   * コンストラクタ
   **/
  public function new(power:Int, ratio:Int, ratioRaw:Int, attr:Attribute, bst:BadStatus) {
    this.power    = power;
    this.ratio    = ratio;
    this.ratioRaw = ratioRaw;
    this.attr     = attr;
    this.bst      = bst;
  }
}

/**
 * 回復行動のパラメータ
 **/
class BtlLogicRecoverParam {
  public var hp:Int; // HP回復量

  /**
   * コンストラクタ
   **/
  public function new(hp:Int) {
    this.hp = hp;
  }
}

/**
 * バトル行動タイプ
 **/
enum BtlLogic {

  // ■行動開始
  BeginEffect(eft:BtlLogicBegin); // 攻撃開始エフェクト
  BeginAttack;                    // 通常攻撃
  BeginItem(item:ItemData);       // アイテムを使う

  // ■行動終了
  EndAction(bHit:Bool);

  // ■アイテム消費
  UseItem(item:ItemData);

  // ■メッセージ表示
  MessageDisp(msgID:Int, args:Array<Dynamic>);

  // ■効果反映
  HpDamage(val:Int, bSeq:Bool); // HPダメージ
  HpRecover(val:Int);           // HP回復
  Badstatus(bst:BadStatus);     // バッドステータス
  ChanceRoll(b:Bool);           // 成功 or 失敗

  // ■その他
  Dead; // 死亡
  TurnEnd; // ターン終了
  BtlEnd(bWin:Bool); // バトル終了
}

/**
 * バトル演出種別ユーティリティ
 **/
class BtlLogicUtil {
  /**
   * 開始演出かどうか
   **/
  public static function isBegin(type:BtlLogic):Bool {
    switch(type) {
      case BtlLogic.BeginEffect, BtlLogic.BeginAttack, BtlLogic.BeginItem:
        return true;
      default:
        return false;
    }
  }
}
