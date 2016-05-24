package jp_2dgames.game.sequence;
import jp_2dgames.game.global.BtlGlobal;
import jp_2dgames.game.sequence.btl.BtlLogicMgr;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.gui.BattleResultPopupUI;
import jp_2dgames.game.state.InventorySubState;
import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.game.SeqMgr.SeqItemFull;
import jp_2dgames.game.dat.FloorInfoDB;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.item.ItemList;
import flixel.FlxG;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.dat.EnemyEncountDB;
import jp_2dgames.game.global.Global;
import flixel.addons.util.FlxFSM;

/**
 * バトル開始
 **/
class BtlBoot extends FlxFSMState<SeqMgr> {

  /**
   * 属性アイコンの表示
   **/
  function _displayEnemyAttribute(enemy:Actor):Void {
    // 属性アイコン表示
    var setVisible = function(idx:Int, b:Bool) {
      BattleUI.setVisibleItem("enemyhud", BattleUI.getResistIconName(idx), b);
      BattleUI.setVisibleItem("enemyhud", BattleUI.getResistTextName(idx), b);
    }
    var setIcon = function(idx:Int, path:String) {
      BattleUI.setSpriteItem("enemyhud", BattleUI.getResistIconName(idx), path);
    }
    var setText = function(idx:Int, ratio:Float) {
      BattleUI.setTextItem("enemyhud", BattleUI.getResistTextName(idx), 'x ${ratio}');
    }

    // いったん非表示
    for(i in 0...2) {
      setVisible(i, false);
    }

    // 設定されている属性を表示
    var idx:Int = 0;
    var resists = EnemyDB.getResists(enemy.id);
    for(resist in resists.list) {
      // 表示
      setVisible(idx, true);
      // アイコン変更
      var path = AttributeUtil.getIconPath(resist.attr);
      setIcon(idx, path);
      // 倍率設定
      setText(idx, resist.value);
      idx++;
    }
  }

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // バトルグローバル変数初期化
    BtlGlobal.init();

    // バトルパラメータ初期化
    ActorMgr.forEachAlive(function(actor:Actor) actor.clearBtlParams() );

    // 敵UI表示
    BattleUI.setVisibleGroup("enemyhud", true);
    // 敵出現
    var e = new Params();
    if(Global.step >= 1) {
      // 通常の敵
      e.id = EnemyEncountDB.lottery(Global.level);
    }
    else {
      // ボス
      e.id = FloorInfoDB.getBoss(Global.level);
    }
    owner.enemy.init(e);
    Message.push2(Msg.ENEMY_APPEAR, [owner.enemy.getName()]);
    // 背景を暗くする
    Bg.darken();
    // 属性アイコンの表示
    _displayEnemyAttribute(owner.enemy);

    owner.startWait();
  }
}

/**
 * バトル入力待ち
**/
class Btl extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();

    if(ItemList.isEmpty() == false) {
      // インベントリ表示
      FlxG.state.openSubState(new InventorySubState(owner, InventoryMode.Battle));
    }
  }
}

/**
 * バトル演出再生中
 **/
class BtlLogicLoop extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 演出データ生成
    BtlLogicMgr.createLogic(owner);
  }

  override public function update(elapsed:Float, owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    BtlLogicMgr.update();
  }
}

/**
 * ターン終了
 **/
class BtlTurnEnd extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 経過ターン数を増やす
    BtlGlobal.addTurn();
  }
}

/**
 * 敵死亡
 **/
class BtlEnemyDead extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var enemy = owner.enemy;
    enemy.vanish();
    // 敵撃破数を増やす
    Global.addKillEnemies();
  }
}

/**
 * アイテム強化
 **/
class BtlPowerup extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    if(owner.enemy.hp != 0) {
      return;
    }

    // ジャストボーナス
    Message.push2(Msg.JUST_ZERO_BONUS);

    var item = owner.getSelectedItem();
    if(item != null) {
      // アイテム強化
      switch(ItemUtil.getCategory(item)) {
        case ItemCategory.Weapon:
          // 敵を倒した武器を強化
          item.buff++;
          var name = ItemUtil.getName2(item);
          Message.push2(Msg.WEAPON_POWERUP, [name]);
          Snd.playSe("powerup");
          owner.startWait();

        case ItemCategory.Portion:
      }
    }

  }
}

/**
 * 勝利
 **/
class BtlWin extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    var enemy = owner.enemy;

    // 勝利メッセージ表示
    Message.push2(Msg.DEFEAT_ENEMY, [enemy.getName()]);

    owner.startWait();
  }
}

/**
 * アイテム獲得
 **/
class BtlItemGet extends FlxFSMState<SeqMgr> {
 override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
   var enemy = owner.enemy;

   // リザルト画面起動パラメータ
   var prm = new BattleResultPopupUIParam();
   prm.money = EnemyDB.getMoeny(enemy.id);

   // 30%の確率でアイテムドロップ
   var rnd:Int = 30;
   if(enemy.hp == 0) {
     // ジャストボーナス
     rnd = 100;
     prm.bJustZero = true;
   }
   if(FlxG.random.bool(rnd)) {
     // アイテム獲得
     var item = ItemLottery.exec();
     var name = ItemUtil.getName(item);
     prm.item = name;
     if(ItemList.isFull()) {
       // アイテムを取得できない
       Message.push2(Msg.ITEM_FIND, [name]);
       Message.push2(Msg.ITEM_CANT_GET);
     }
     else {
       // アイテムを手に入れた
       ItemList.push(item);
       Message.push2(Msg.ITEM_GET, [name]);
       // 消しておく
       ItemLottery.clearLastLottery();
     }
   }

   // リザルト表示
   FlxG.state.openSubState(new BattleResultPopupUI(owner, prm));
 }
}

/**
 * アイテムが一杯のメニュー
 **/
class BtlItemFull extends SeqItemFull {
}

/**
 * 逃走
 **/
class BtlEscape extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.ESCAPE, [owner.player.getName()]);
    owner.startWait();
  }
}

/**
 * バトル終了
 **/
class BtlEnd extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // バトル用パラメータ初期化
    ActorMgr.forEachAlive(function(actor:Actor) actor.clearBtlParams() );

    // 背景を明るくする
    Bg.brighten();
    // 敵を消す
    owner.enemy.visible = false;
    // 敵UIを消す
    BattleUI.setVisibleGroup("enemyhud", false);
  }
}

