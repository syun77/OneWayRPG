package jp_2dgames.game.sequence;
import flixel.math.FlxMath;
import jp_2dgames.game.gui.message.UIMsg;
import jp_2dgames.game.gui.DialogPopupUI;
import jp_2dgames.game.shop.Shop;
import flixel.util.FlxColor;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.lib.MyColor;
import jp_2dgames.game.particle.ParticleBmpFont;
import jp_2dgames.game.state.ShopSubState;
import jp_2dgames.game.state.InventorySubState;
import jp_2dgames.game.state.UpgradeSubState;
import flixel.FlxG;
import jp_2dgames.game.SeqMgr.SeqItemFull;
import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.sequence.DgEventMgr.DgEvent;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.gui.BattleUI;
import flixel.addons.util.FlxFSM;

/**
 * ダンジョン入力待ち
 **/
class Dg extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();

    // UIを表示
    BattleUI.setVisibleGroup("field", true);

    // 休憩ボタンチェック
    if(owner.player.food <= 0 || owner.player.isHpMax()) {
      // 押せない
      BattleUI.lockButton("field", "rest");
    }

    // アイテム捨てるボタンチェック
    if(ItemList.isEmpty()) {
      // 押せない
      BattleUI.lockButton("field", "itemdel");
    }

    // ショップボタンチェック
    if(Shop.isAppear() == false) {
      // 押せない
      BattleUI.lockButton("field", "shop");
    }

    // 強化チェック
    if(UpgradeSubState.isAppear() == false) {
      // 押せない
      BattleUI.lockButton("field", "upgrade");
    }


    // 次のフロアに進めるかどうか
    if(DgEventMgr.isFoundStair()) {
      // 次のフロアに進む以外のボタンを無効にする
      BattleUI.lockButton("field", "search");
      BattleUI.lockButton("field", "rest");
      BattleUI.lockButton("field", "itemdel");
      BattleUI.lockButton("field", "upgrade");
      BattleUI.lockButton("field", "shop");
    }
    else {
      // 次のフロアにはまだ進めない
      BattleUI.lockButton("field", "nextfloor");
    }
  }

  override public function exit(owner:SeqMgr):Void {
    // UIを非表示
    BattleUI.setVisibleGroup("field", false);
  }

}

/**
 * ダンジョン - 探索
 **/
class DgSearch extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 歩数を減らす
    Global.subStep();

    Snd.playSe("foot");

    Message.push2(Msg.SEARCHING);

    var player = owner.player;

    // 食糧を減らす
    if(player.food == 1) {
      // 食糧がなくなるメッセージ表示
      Message.push2(Msg.FOOD_NOTHING);
    }
    if(player.subFood(1) == false) {
      // 空腹ダメージ
      // 残りHPの30%ダメージ
      var hp = player.hp;
      var v = Std.int(hp * 0.3);
      if(v < 1) {
        v = 1;
      }
      player.damage(v);
      // 画面揺らす
      {
        var ratio = v / player.hpmax;
        var val = FlxMath.lerp(0.01, 0.05, ratio);
        FlxG.camera.shake(val, 0.1 + (val * 10));
      }
      var px = player.xcenter;
      var py = player.ycenter;
      // ダメージエフェクト
      Particle.start(PType.Ball, px, py, FlxColor.RED);
      ParticleBmpFont.startNumber(px, py, v);
      Snd.playSe("hit");
      Message.push2(Msg.HUNGRY_DAMAGE, [v]);
    }
    else {
      // 10%回復
      var hpmax = player.hpmax;
      var v = Std.int(hpmax * 0.1);
      if(v < 1) { v = 1; }
      player.recover(v);
      var px = player.xcenter;
      var py = player.ycenter;
      ParticleBmpFont.startNumber(px, py, v, MyColor.LIME);
    }

    owner.startWait();
  }
}

/**
 * ダンジョン - 探索実行
 **/
class DgSearch2 extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // イベントを抽選する
    DgEventMgr.lottery();
  }
}

/**
 * ダンジョン - 休憩
 **/
class DgRest extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    Message.push2(Msg.REST);
    // HP回復 (30%回復)
    var player = owner.player;
    var v = Std.int(player.hpmax * 0.3);
    player.recover(v);
    var px = player.xcenter;
    var py = player.ycenter;
    ParticleBmpFont.startNumber(px, py, v, MyColor.LIME);
    Message.push2(Msg.RECOVER_HP, [player.getName(), v]);
    Snd.playSe("recover");
    // 食糧を減らす
    player.subFood(1);

    owner.startWait();

  }
}

/**
 * ダンジョン - 次のフロアに進む
 **/
class DgNextFloor extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
  }
}

/**
 * ダンジョン - ショップ
 **/
class DgShop extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    FlxG.state.openSubState(new ShopSubState(owner));
  }
}

/**
 * ダンジョン - アイテム捨てる
 **/
class DgDrop extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // インベントリ表示
    FlxG.state.openSubState(new InventorySubState(owner, InventoryMode.ItemDrop));
  }
  override public function exit(owner:SeqMgr):Void {
    if(owner.lastClickButton == "cancel") {
      // キャンセルした
      return;
    }

    var item = owner.getSelectedItem();
    if(item != null) {
      // アイテム捨てる
      ItemList.del(item.uid);
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_DEL, [name]);
      // 食糧が増える
      owner.addFood(item.now);
      owner.startWait();
    }
  }
}

/**
 * ダンジョン - 強化
 **/
class DgUpgrade extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    FlxG.state.openSubState(new UpgradeSubState());
  }
}

/**
 * ダンジョン - アイテム獲得
 */
class DgGain extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // アイテムを抽選
    var item = ItemLottery.exec();
    var name = ItemUtil.getName(item);
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
}

/**
 * ダンジョン - ボス出現前警告
 **/
class DgBossNotice extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // ボス出現前メッセージ
    var prm = new DialogPopupUIParam();
    prm.body = UIMsg.get(UIMsg.BOSS_NOTICE);
    FlxG.state.openSubState(new DialogPopupUI(owner, prm));
  }
}

/**
 * ダンジョン - ショップ発見
 **/
class DgShopFind extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // ショップアイテム生成
    Shop.create(Global.level);

    // ショップ発見メッセージ
    var prm = new DialogPopupUIParam();
    prm.body = UIMsg.get(UIMsg.SHOP_FIND);
    FlxG.state.openSubState(new DialogPopupUI(owner, prm));
  }
}

/**
 * ダンジョン - 強化発見
 **/
class DgUpgradeFind extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    // 強化発見メッセージ
    var prm = new DialogPopupUIParam();
    prm.body = UIMsg.get(UIMsg.UPGRADE_FIND);
    FlxG.state.openSubState(new DialogPopupUI(owner, prm));
  }
}

/**
 * アイテムが一杯のメニュー
 **/
class DgItemFull extends SeqItemFull {
}