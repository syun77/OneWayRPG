package jp_2dgames.game.state;

import jp_2dgames.game.global.ItemLottery;
import flixel.addons.ui.FlxUIButton;
import flixel.util.FlxColor;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.gui.BattleUI;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import jp_2dgames.game.dat.EnemyDB;
import jp_2dgames.game.dat.ResistData.ResistList;
import flixel.addons.ui.FlxUIText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import jp_2dgames.game.dat.AttributeUtil;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.item.ItemList;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUISubState;

enum InventoryMode {
  Battle;         // バトル
  ItemDrop;       // アイテム捨てる
  ItemDropAndGet; // アイテムを捨てて拾う
  ShopBuy;        // ショップでアイテム購入
}

/**
 * インベントリSubState
 **/
class InventorySubState extends FlxUISubState {

  // ----------------------------------------
  // ■定数
  public static var BTN_IGNORE = "ignore"; // "あきらめる" を選んだ


  // ----------------------------------------
  // ■フィールド
  var _mode:InventoryMode;
  var _owner:SeqMgr;

  var _btnItems:Map<String, FlxUIButton>;
  var _txtDetail:FlxUIText;

  /**
   * コンストラクタ
   **/
  public function new(owner:SeqMgr, mode:InventoryMode) {
    super();
    _owner = owner;
    _mode = mode;
  }

  /**
   * 生成
   **/
  public override function create():Void {

    // レイアウト読み込み
    _xml_id = "inventory";
    super.create();

    // モード設定
    _ui.setMode(_modeToName());

    // アイテム表示を更新
    _btnItems = new Map<String, FlxUIButton>();

    var idx:Int = 0;
    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "txtdetail":
          _txtDetail = cast widget;
        default:
          if(widget.name.indexOf("item") != -1) {
            if(Std.is(widget, FlxUIButton)) {
              // アイテムボタン
              var btn:FlxUIButton = cast widget;
              _btnItems[widget.name] = btn;
            }
          }
      }

      if(Std.is(widget, FlxUIButton)) {
        // スライドイン表示
        var px = widget.x;
        widget.x = -widget.width*2;
        FlxTween.tween(widget, {x:px}, 0.5, {ease:FlxEase.expoOut, startDelay:idx*0.05});
        idx++;
      }
    });

    // 表示項目を更新
    _updateItems();

  }

  /**
   * 破棄
   **/
  public override function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  public override function update(elapsed:Float):Void {
    super.update(elapsed);
    PlayState.forceUpdate(elapsed);
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    var widget:IFlxUIWidget = cast sender;
    if(widget != null && Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          // ボタンパラメータを判定
          if(fuib.params != null) {
            var key = fuib.params[0];
            _cbClick(key);
          }
      #if mobile
        case FlxUITypedButton.DOWN_EVENT: // ボタン押下時に反応させる
      #else
        case FlxUITypedButton.OVER_EVENT:
      #end
          // マウスが上に乗った
          if(fuib.params != null) {
            var key = fuib.params[0];
            _cbOver(key);
          }
      }
    }
  }

  /**
   * ボタンクリックのコールバック
   **/
  function _cbClick(name:String):Void {

    // 選択したアイテムを格納
    _owner.setButtonClick(name);

    var idx = Std.parseInt(name);
    if(idx != null) {
      // アイテムを選んだ
      switch(_mode) {
        case InventoryMode.Battle:
          // アイテム使う
        case InventoryMode.ItemDrop:
          // アイテム捨てる
        case InventoryMode.ItemDropAndGet:
          // 捨てて拾う
          if(idx >= ItemList.getLength()) {
            // あきらめる
            _owner.setButtonClick(BTN_IGNORE);
          }
        case InventoryMode.ShopBuy:
          // ショップ購入
      }

      // 設定したボタン番号をアイテム情報に変換
      _owner.trySetClickButtonToSelectedItem();
    }

    // 何か押したら閉じる
    close();
  }

  /**
   * マウスオーバーのコールバック
   **/
  function _cbOver(name:String):Void {
    var idx = Std.parseInt(name);
    if(idx != null) {
      // 説明文の更新
      var item = _getItemFromIdx(idx);
      // 耐性情報を表示するかどうか
      var resists:ResistList = null;
      if(_mode == InventoryMode.Battle) {
        var enemy = _owner.enemy;
        resists = EnemyDB.getResists(enemy.id);
      }
      var detail = ItemUtil.getDetail(item);
      if(ItemUtil.getCategory(item) == ItemCategory.Weapon) {
        detail = ItemUtil.getDetail2(_owner, item, resists);
      }
      _setDetailText(detail);
    }
  }

  /**
   * アイテムデータの取得
   **/
  function _getItemFromIdx(idx:Int):ItemData {
    if(idx >= ItemList.getLength()) {
      // 入手したアイテム
      return ItemLottery.getLastLottery();
    }
    return ItemList.getFromIdx(idx);
  }

  /**
   * アイテムの最大数
   **/
  function _getItemMax():Int {
    return ItemList.MAX;
  }

  /**
   * 表示アイテムを更新
   **/
  function _updateItems():Void {
    for(i in 0..._getItemMax()) {
      var item = _getItemFromIdx(i);
      var key = 'item${i}';
      var btn:FlxUIButton = _btnItems[key];
      if(item == null) {
        // 所持していないので非表示
        btn.visible = false;
        continue;
      }
      // 表示する
      _setButtonInfo(btn, item, _isItemLockFromIdx(i));
    }

    // 入手したアイテム
    var btn:FlxUIButton = _btnItems['item6'];
    btn.visible = false;
    if(_mode == InventoryMode.ItemDropAndGet) {
      // 表示する
      var item = ItemLottery.getLastLottery();
      _setButtonInfo(btn, item, false);
    }
  }

  /**
   * ボタン情報を設定
   **/
  function _setButtonInfo(btn:FlxUIButton, item:ItemData, bLock:Bool):Void {
    btn.visible = true;
    var name = _getItemLabel(item);
    btn.label.text = name;
    // 属性アイコンを設定
    var attr = ItemUtil.getAttribute(item);
    var icon = AttributeUtil.getIconPath(attr);
    btn.removeIcon();
    if(icon != "") {
      var spr = new FlxSprite(0, 0, icon);
      btn.addIcon(spr, -8, -6, false);
    }
    if(item.now == 1) {
      var spr2 = new FlxSprite(0, 0, AssetPaths.IMAGE_LASTATTACK);
      btn.addIcon(spr2, Std.int(btn.width-18), 4, false);
    }

    // ロックするかどうか
    if(bLock) {
      // ロックする
      btn.skipButtonUpdate = true;
      btn.color = FlxColor.GRAY;
      btn.label.color = FlxColor.GRAY;
    }
    else {
      // ロックしない
      btn.skipButtonUpdate = false;
      btn.color = FlxColor.WHITE;
      btn.label.color = FlxColor.WHITE;
    }
  }

  function _getItemLabel(item:ItemData):String {
    var name = ItemUtil.getName(item);
    return name;
  }

  function _isItemLockFromIdx(idx:Int):Bool {
    return false;
  }

  /**
   * アイテム説明文のテキストを設定
   **/
  function _setDetailText(msg:String):Void {
    _txtDetail.text = msg;
  }

  /**
   * モードに対応する名前を取得する
   **/
  function _modeToName():String {
    return switch(_mode) {
      case InventoryMode.Battle: "battle";
      case InventoryMode.ItemDrop: "drop";
      case InventoryMode.ItemDropAndGet: "dropandget";
      case InventoryMode.ShopBuy: "shopbuy";
    }
  }
}
