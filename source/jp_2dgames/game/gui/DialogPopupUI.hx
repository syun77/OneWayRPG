package jp_2dgames.game.gui;
import jp_2dgames.game.particle.ParticleUtil;
import jp_2dgames.game.state.PlayState;
import jp_2dgames.lib.Input;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.gui.message.Message;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIPopup;

/**
 * ダイアログ起動パラメータ
 **/
class DialogPopupUIParam {
  public var item:String    = null;
  public var food:Int       = 0;
  public var money:Int      = 0;
  public var body:String    = null;
  public function new() {}
}

/**
 * ダイアログ
 **/
class DialogPopupUI extends FlxUIPopup {

  // ------------------------------------
  // ■フィールド
  var _owner:SeqMgr;
  var _prm:DialogPopupUIParam;

  var _txtItem:FlxUIText;
  var _txtFood:FlxUIText;
  var _txtMoney:FlxUIText;
  var _txtBody:FlxUIText;

  /**
   * コンストラクタ
   **/
  public function new(owner:SeqMgr, prm:DialogPopupUIParam) {
    super();
    _owner = owner;
    _prm = prm;
  }

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "dialog";
    super.create();

    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "txtitem":
          _txtItem = cast widget;
          _txtItem.visible = false;
          if(_prm.item != null) {
            _txtItem.visible = true;
            _txtItem.text = _prm.item;
          }
        case "txtfood":
          _txtFood = cast widget;
          _txtFood.text = '${_prm.food}';
        case "txtmoney":
          _txtMoney = cast widget;
          _txtMoney.text = '${_prm.money}';
        case "body":
          _txtBody = cast widget;
          _txtBody.visible = false;
          if(_prm.body != null) {
            _txtBody.visible = true;
            _txtBody.text = _prm.body;
          }
        default:
      }
    });

    if(_prm.item == null) {
      _ui.setMode("nonitem");
    }
    if(_prm.food == 0) {
      _ui.setMode("nonfood");
    }
    if(_prm.money == 0) {
      _ui.setMode("nonmoney");
    }
    if(_prm.item == null && _prm.food == 0 && _prm.money == 0) {
      // 獲得アイテム非表示
      _ui.setMode("nontitle");
      // 本文を上にずらす
      _txtBody.y -= 80;
    }
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

    if(Input.press.B) {
      // 閉じる
      close();
    }
  }

  /**
   * イベントコールバック
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
    var widget:IFlxUIWidget = cast sender;
    if(widget != null && Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          if(fuib.params != null) {
            var key = fuib.params[0];
            if(key == "ok") {
              // 閉じる
              close();
            }
          }
      }
    }
  }

  /**
   * 画面を閉じる
   **/
  override public function close():Void {

    if(_prm.food > 0) {
      // 食糧を増やす
      _owner.addFood(_prm.food);
      ParticleUtil.startFood(_prm.food);
    }

    if(_prm.money > 0)  {
      // お金を増やす
      var text = '${_prm.money}G';
      Message.push2(Msg.ITEM_GET, [text]);
      Global.addMoney(_prm.money);
      ParticleUtil.startMoney(_prm.money);
    }

    super.close();
  }


}
