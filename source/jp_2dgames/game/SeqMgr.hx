package jp_2dgames.game;

import jp_2dgames.game.dat.ClassDB;
import jp_2dgames.game.dat.ClassDB;
import jp_2dgames.game.global.Global;
import flixel.util.FlxColor;
import jp_2dgames.lib.MyShake;
import jp_2dgames.game.particle.ParticleUtil;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.sequence.btl.BtlLogicMgr;
import jp_2dgames.game.state.InventorySubState;
import jp_2dgames.game.global.ItemLottery;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.sequence.Btl;
import jp_2dgames.game.sequence.DgEventMgr;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.item.ItemList;
import flixel.util.FlxDestroyUtil;
import flixel.FlxG;
import jp_2dgames.game.sequence.Dg;
import jp_2dgames.game.actor.ActorMgr;
import jp_2dgames.game.actor.Actor;
import flixel.FlxBasic;
import flixel.addons.util.FlxFSM;


/**
 * シーケンス管理
 **/
class SeqMgr extends FlxBasic {

  public static inline var RET_NONE:Int    = 0;
  public static inline var RET_DEAD:Int    = 3; // プレイヤー死亡
  public static inline var RET_STAGECLEAR:Int  = 5; // ステージクリア

  // ■選んだアイテム
  public static inline var SELECTED_ITEM_NONE:Int = -1;
  public static inline var SELECTED_ITEM_SPECIAL:Int = -2;
  public static inline var BUTTON_ID_SPECIAL = "special";

  static inline var TIMER_WAIT:Int = 30;

  // -----------------------------------------
  // ■フィールド
  var _tWait:Int = 0;
  var _bDead:Bool = false;

  // FSM
  var _fsm:FlxFSM<SeqMgr>;
  var _fsmName:String = ""; // 名前(デバッグ用)

  // ダンジョンイベント
  var _event:DgEvent = DgEvent.None;

  // アクター
  var _player:Actor;
  var _enemy:Actor;

  // 選択したアイテム情報
  var _selectedItem:Int;

  // スペシャル
  var _specialWeapon:ItemData;

  // ボタン関連
  var _overlapedItem:Int = SELECTED_ITEM_NONE;
  var _lastOverlapButton:String = ""; // 最後にオーバーラップしたボタン
  var _lastClickButton:String = ""; // 最後にクリックしたボタン

  // -----------------------------------------
  // ■アクセサ
  public var player(get, never):Actor;
  public var enemy(get, never):Actor;
  public var lastOverlapButton(get, never):String;
  public var lastClickButton(get, never):String;
  public var specialWeapon(get, never):ItemData;

  /**
   * コンストラクタ
   **/
  public function new() {
    super();

    _player = ActorMgr.getPlayer();
    _enemy  = ActorMgr.getEnemy();
    _enemy.visible = false;

    _fsm = new FlxFSM<SeqMgr>(this);
    // 状態遷移テーブル
    _fsm.transitions
      // ■開始
      .add(Boot,       Dg,          Conditions.isEndWait)   // 開始 -> ダンジョン

      // ■ダンジョン
      .add(Dg,         DgSearch,    Conditions.isSearch)    // ダンジョン    -> 探索
      .add(Dg,         DgRest,      Conditions.isRest)      // ダンジョン    -> 休憩
      .add(Dg,         DgDrop,      Conditions.isItemDel)   // ダンジョン    -> アイテム捨てる
      .add(Dg,         DgUpgrade,   Conditions.isUpgrade)   // ダンジョン    -> 強化
      .add(Dg,         DgNextFloor, Conditions.isNextFloor) // ダンジョン    -> 次のフロアに進む
      .add(Dg,         DgShop,      Conditions.isShop)      // ダンジョン    -> ショップ
      // ダンジョン - 探索
      .add(DgSearch,   PlayerDead,  Conditions.isDead)      // 探索中...    -> プレイヤー死亡
      .add(DgSearch,   DgSearch2,   Conditions.isEndWait)   // 探索中...    -> 探索実行
      .add(DgSearch2,  BtlBoot,     Conditions.isAppearEnemy) // 探索中...  -> 敵に遭遇
      .add(DgSearch2,  DgGain,      Conditions.isItemGain)  // 探索中...    -> アイテム獲得
      .add(DgSearch2,  DgBossNotice,Conditions.isBossNotice)// 探索中...    -> ボス出現警告
      .add(DgSearch2,  DgShopFind,  Conditions.isShopFind)  // 探索中...    -> ショップを見つけた
      .add(DgSearch2,  DgUpgradeFind, Conditions.isUpgradeFind) // 探索中...-> 強化を見つけた
      .add(DgSearch2,  DgSearch,    Conditions.isEventNone) // 探索中...    -> 再び探索
      .add(DgSearch2,  Dg,          Conditions.isEndWait)   // 探索中...    -> ダンジョンに戻る
      // ダンジョン - 探索 - アイテム獲得
      .add(DgGain,     DgItemFull,  Conditions.isItemFull)  // アイテム獲得  -> アイテム一杯
      .add(DgGain,     Dg,          Conditions.isEndWait)   // アイテム獲得  -> ダンジョンに戻る
      // ダンジョン - 探索 - アイテム一杯
      .add(DgItemFull, Dg,          Conditions.isEndWait)   // アイテム一杯  -> ダンジョンに戻る
      // ダンジョン - 探索 - ボス出現警告
      .add(DgBossNotice, Dg,        Conditions.isEndWait)   // ボス出現警告  -> ダンジョンに戻る
      // ダンジョン - 探索 - ショップ発見
      .add(DgShopFind, DgShop,      Conditions.isEndWait)   // ショップ発見  -> ショップ
      // ダンジョン - 探索 - 強化発見
      .add(DgUpgradeFind, DgUpgrade, Conditions.isEndWait)  // 強化発見      -> 強化

      // ダンジョン - 休憩
      .add(DgRest,     Dg,          Conditions.isEndWait)   // 休憩         -> ダンジョン
      // ダンジョン - 強化
      .add(DgUpgrade,  Dg,          Conditions.isEndWait)   // 強化         -> ダンジョン
      // ダンジョン - アイテム捨てる
      .add(DgDrop,     Dg,          Conditions.isEndWait)   // アイテム破棄  -> ダンジョン
      // ダンジョン - ショップ
      .add(DgShop,     Dg,          Conditions.isEndWait);  // ショップ      -> ダンジョン

    _fsm.transitions
      // ■バトル
      .add(BtlBoot,        Btl,            Conditions.isEndWait)    // 敵出現        -> バトルコマンド入力
      .add(Btl,            BtlLogicLoop,   Conditions.isSelectItem) // コマンド      -> コマンド選択完了
      .add(Btl,            BtlLogicLoop,   Conditions.isSelectSpecial) // コマンド   -> コマンド選択完了 (スペシャル)
      .add(Btl,            BtlLogicLoop,   Conditions.isAutoAttack)  // コマンド     -> アイテムがないので自動攻撃
      .add(BtlLogicLoop,   BtlTurnEnd,     Conditions.isLogicEnd)   // 演出再生中     -> ターン終了
      .add(BtlTurnEnd,     BtlEnemyDead,   Conditions.isDeadEnemy)  // ターン終了     -> 敵死亡
      .add(BtlTurnEnd,     PlayerDead,     Conditions.isDead)       // ターン終了     -> 敗北 (※ゲームオーバー)
      .add(BtlTurnEnd,     Btl,            Conditions.isEndWait)    // ターン終了     -> バトルコマンド入力

      // バトル - 勝利
      .add(BtlEnemyDead,   BtlPowerup,     Conditions.isEndWait)    // 敵死亡        -> アイテム強化
      .add(BtlPowerup,     BtlWin,         Conditions.isEndWait)    // アイテム強化   -> 勝利
      .add(BtlWin,         BtlItemGet,     Conditions.isEndWait)    // 勝利          -> アイテム獲得
      // バトル - アイテム獲得
      .add(BtlItemGet,     BtlItemFull,    Conditions.isItemFull)   // アイテム獲得   -> アイテム一杯
      .add(BtlItemGet,     BtlEnd,         Conditions.isEndWait)    // アイテム獲得   -> バトル終了
      // バトル - アイテム一杯
      .add(BtlItemFull,    BtlEnd,         Conditions.isEndWait)    // アイテム一杯   -> バトル終了
      // バトル - 逃走
      .add(BtlEscape,      BtlEnd,         Conditions.isEndWait)    // 逃走          -> バトル終了
      // バトル - 敗北
      // ※ゲームオーバーなので遷移しない
      // バトル - 終了
      .add(BtlEnd,         Dg,             Conditions.isEndWait)    // バトル終了     -> ダンジョンに戻る

      // ここまで
      .start(Boot);
    _fsm.stateClass = Boot;

    // ボタンのコールバックを設定
    BattleUI.setButtonClickCB(_cbButtonClick);
    BattleUI.setButtonOverlapCB(_cbButtonOverlap);

    // スペシャルを設定
    _specialWeapon = ItemUtil.addSpecial(ClassDB.getSpecial(_player.params.kind));

    // 初期化処理
    // イベント初期化
    DgEventMgr.init();

    FlxG.watch.add(this, "_fsmName", "fsm");
    FlxG.watch.add(this, "_lastClickButton", "button");
    FlxG.watch.add(this, "_lastOverlapButton", "over");
    FlxG.watch.add(this, "_tWait", "tWait");

  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    _fsm = FlxDestroyUtil.destroy(_fsm); // FlxStateに登録しないので手動で破棄が必要
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(_tWait > 0) {
      _tWait--;
    }
    _fsm.update(elapsed);
    _fsmName = Type.getClassName(_fsm.stateClass);
  }

  /**
   * 少し待つ
   **/
  public function startWait():Void {
    _tWait = TIMER_WAIT;
  }

  public function startWaitHalf():Void {
    _tWait = Std.int(TIMER_WAIT/2);
  }

  /**
   * 待ちが終了したかどうか
   **/
  public function isEndWait():Bool {
    return _tWait <= 0;
  }

  /**
   * オーバーラップしたボタンのコールバック
   **/
  function _cbButtonOverlap(name:String):Void {
    _lastOverlapButton = name;
  }

  /**
   * クリックしたボタンのコールバック
   **/
  function _cbButtonClick(name:String):Void {
    _lastClickButton = name;
  }

  public function setButtonClick(name:String):Void {
    _cbButtonClick(name);
  }

  /**
   * 最後にクリックしたボタンをリセット
   **/
  public function resetLastClickButton():Void {
    _lastClickButton = "";
    _overlapedItem = SELECTED_ITEM_NONE;
  }

  /**
   * 自動攻撃するかどうか
   **/
  public function isAutoAttack():Bool {
    if(ItemList.isEmpty()) {
      if(_specialWeapon.isCoolDown()) {
        return true;
      }
    }

    // 何か選べる
    return false;
  }

  /**
   * 選択したアイテム
   **/
  public function getSelectedItem():ItemData {
    switch(_selectedItem) {
      case SELECTED_ITEM_NONE:
        // 何も選択していない (自動攻撃)
        return null;
      case SELECTED_ITEM_SPECIAL:
        // スペシャル
        return specialWeapon;
      default:
        // 何か選んだ
        return ItemList.getFromUID(_selectedItem);
    }
  }

  /**
   * クリックしたボタンをアイテムリストのUIに変換する
   **/
  public function trySetClickButtonToSelectedItem():Bool {
    var id = lastClickButton;
    var idx = Std.parseInt(id);
    if(idx != null) {
      // アイテムを選んだ
      var item = ItemList.getFromIdx(idx);
      _selectedItem = item.uid;
      return true;
    }
    // アイテム以外を選んだ
    _selectedItem = SELECTED_ITEM_NONE;
    return false;
  }

  /**
   * スペシャルを選んだ
   **/
  public function trySetSelectSpecial():Bool {
    var ret = (lastClickButton == BUTTON_ID_SPECIAL);
    if(ret) {
      // スペシャルに対応するアイテムを設定
      _selectedItem = SELECTED_ITEM_SPECIAL;
    }
    return ret;
  }

  /**
   * クールダウンタイムをリセットする
   **/
  public function resetCoolDownSpecial():Void {
    _specialWeapon.resetCoolDown();
  }

  /**
   * 更新
   **/
  public function proc():Int {
    return switch(_fsm.stateClass) {
      case PlayerDead:
        // 死亡
        return RET_DEAD;
      case DgNextFloor:
        // 次のフロアに進む
        return RET_STAGECLEAR;
      default:
        RET_NONE;
    }
  }

  /**
   * 食糧を増やす
   **/
  public function addFood(v:Int):Void {
    player.addFood(v);
    Message.push2(Msg.FOOD_ADD, [v]);
    ParticleUtil.startFood(v);
    Snd.playSe("pickup2", true);
  }

  /**
   * ターン終了
   **/
  public function turnEnd():Void {
    _specialWeapon.coolDown();
  }

  // ------------------------------------------------------
  // ■アクセサメソッド
  function get_player() { return _player; }
  function get_enemy()  { return _enemy;  }
  function get_lastOverlapButton() { return _lastOverlapButton; }
  function get_lastClickButton() { return _lastClickButton; }
  function get_specialWeapon() { return _specialWeapon; }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * FSMの遷移条件
 **/
private class Conditions {
  public static function isEndWait(owner:SeqMgr):Bool {
    return owner.isEndWait();
  }

  public static function isFoundStair(owner:SeqMgr):Bool {
    return DgEventMgr.isFoundStair();
  }

  public static function isSearch(owner:SeqMgr):Bool {
    return owner.lastClickButton == "search";
  }
  public static function isRest(owner:SeqMgr):Bool {
    return owner.lastClickButton == "rest";
  }
  public static function isItemDel(owner:SeqMgr):Bool {
    return owner.lastClickButton == "itemdel";
  }
  public static function isUpgrade(owner:SeqMgr):Bool {
    return owner.lastClickButton == "upgrade";
  }
  public static function isNextFloor(owner:SeqMgr):Bool {
    return owner.lastClickButton == "nextfloor";
  }
  public static function isShop(owner:SeqMgr):Bool {
    return owner.lastClickButton == "shop";
  }
  public static function isSelectItem(owner:SeqMgr):Bool {
    if(owner.trySetClickButtonToSelectedItem()) {
      // アイテム選んだ
      return true;
    }
    // 選んでない
    return false;
  }
  public static function isSelectSpecial(owner:SeqMgr):Bool {
    if(owner.trySetSelectSpecial()) {
      // スペシャルを選んだ
      return true;
    }
    // 選んでいない
    return false;
  }
  public static function isIgnore(owner:SeqMgr):Bool {
    // "あきらめる"を選んだ
    return owner.lastClickButton == InventorySubState.BTN_IGNORE;
  }
  public static function isAppearEnemy(owner:SeqMgr):Bool {
    // 敵に遭遇したかどうか
    return DgEventMgr.event == DgEvent.Encount;
  }
  public static function isItemGain(owner:SeqMgr):Bool {
    // アイテム獲得したかどうか
    return DgEventMgr.event == DgEvent.Itemget;
  }
  public static function isBossNotice(owner:SeqMgr):Bool {
    // ボス出現前メッセージ
    return DgEventMgr.event == DgEvent.BossNotice;
  }
  public static function isShopFind(owner:SeqMgr):Bool {
    // ショップ出現
    return DgEventMgr.event == DgEvent.ShopFind;
  }
  public static function isUpgradeFind(owner:SeqMgr):Bool {
    // 強化出現
    return DgEventMgr.event == DgEvent.UpgradeFind;
  }
  public static function isItemFull(owner:SeqMgr):Bool {
    // アイテムが一杯かどうか
    if(ItemList.isFull()) {
      if(ItemLottery.getLastLottery() != null) {
        return true;
      }
    }
    return false;
  }
  // イベントが発生していないかどうか
  public static function isEventNone(owner:SeqMgr):Bool {
    if(DgEventMgr.event != DgEvent.None) {
      // なんらかのイベントが発生
      return false;
    }

    if(owner.player.food == 0) {
      // 食糧がなくなった
      return false;
    }

    if(Global.step == 1) {
      // ボス出現直前
      return false;
    }

    // イベントなし
    return true;
  }

  public static function isLogicEnd(owner:SeqMgr):Bool {
    if(owner.isEndWait() == false) {
      return false;
    }
    return BtlLogicMgr.isEnd();
  }

  public static function isDeadEnemy(owner:SeqMgr):Bool {
    if(isEndWait(owner) == false) {
      return false;
    }
    return owner.enemy.isDead();
  }

  public static function isDead(owner:SeqMgr):Bool {
    if(isEndWait(owner) == false) {
      return false;
    }
    return owner.player.isDead();
  }

  // 自動攻撃するかどうか
  public static function isAutoAttack(owner:SeqMgr):Bool {
    if(owner.isAutoAttack()) {
      return true;
    }
    return false;
  }
}

// -----------------------------------------------------------
// -----------------------------------------------------------
/**
 * 各FSMの実装
**/
// ゲーム開始
private class Boot extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // ※ここの処理はなぜか呼ばれない
  }
}

// プレイヤー死亡
private class PlayerDead extends FlxFSMState<SeqMgr> {
  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {

    Snd.playSe("explosion");
    MyShake.high();
    FlxG.camera.flash(FlxColor.WHITE, 0.5);

    Message.push2(Msg.DEAD, [owner.player.getName()]);
    owner.startWait();
  }
}

// アイテム一杯のときの捨てるメニュー
class SeqItemFull extends FlxFSMState<SeqMgr> {

  override public function enter(owner:SeqMgr, fsm:FlxFSM<SeqMgr>):Void {
    // 入力を初期化
    owner.resetLastClickButton();
    // インベントリ表示
    FlxG.state.openSubState(new InventorySubState(owner, InventoryMode.ItemDropAndGet));
  }

  override public function exit(owner:SeqMgr):Void {

    var item = ItemLottery.getLastLottery();
    if(Conditions.isIgnore(owner)) {
      // あきらめたので拾ったアイテムを食糧に変換
      var name = ItemUtil.getName(item);
      Message.push2(Msg.ITEM_ABANDAN, [name]);
      // 食糧が増える
      owner.addFood(item.now);
    }
    else {
      // 指定のアイテムを捨ててアイテム獲得
      // アイテムを手に入れた
      var item2 = owner.getSelectedItem();
      var name = ItemUtil.getName(item2);
      ItemList.del(item2.uid);
      // 食糧が増える
      owner.addFood(item2.now);
      var name2 = ItemUtil.getName(item);
      ItemList.push(item);
      Message.push2(Msg.ITEM_DEL_GET, [name, name2]);
    }

    // 抽選したアイテムを消しておく
    ItemLottery.clearLastLottery();
  }

}
