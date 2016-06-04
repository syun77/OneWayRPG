package jp_2dgames.game.state;

import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIRadioGroup;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.dat.ItemDB;
import flixel.addons.ui.FlxUIText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import jp_2dgames.game.dat.ClassDB;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIState;
import jp_2dgames.game.dat.MyDB;

/**
 * キャラメイク画面
 **/
class MakeCharacterState extends FlxUIState {

  var _txtDetail:FlxUIText;
  var _txtHp:FlxUIText;
  var _txtVit:FlxUIText;
  var _txtDex:FlxUIText;
  var _txtAgi:FlxUIText;
  var _txtItems:Map<String, FlxUIText>;
  var _txtSkill:FlxUIText;

  /**
   * 生成
   **/
  override public function create():Void {

    // レイアウト読み込み
    _xml_id = "makecharacter";
    super.create();

    // アイテムマップの生成
    _txtItems = new Map<String, FlxUIText>();

    var idx:Int = 0;
    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "txtdetail": _txtDetail = cast widget;
        case "txthp":     _txtHp     = cast widget;
        case "txtvit":    _txtVit    = cast widget;
        case "txtdex":    _txtDex    = cast widget;
        case "txtagi":    _txtAgi    = cast widget;
        case "txtskill":  _txtSkill  = cast widget;
        case "radio_classes":
          var radioGroup:FlxUIRadioGroup = cast widget;
          // 0番目を選択する
          radioGroup.selectedIndex = 0;
          // ラベル更新
          for(i in 0...radioGroup.numRadios) {
            var kind = ClassDB.idxToKind(i);
            var name = ClassDB.getName(kind);
            radioGroup.updateLabel(i, name);
          }
        default:
          if(widget.name.indexOf("item") != -1) {
            if(Std.is(widget, FlxUIText)) {
              // 所持アイテムテキスト
              _txtItems[widget.name] = cast widget;
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

    // 0番目を選択
    _cbClickRadioButton(0);
  }

  /**
   * 破棄
   **/
  override public function destroy():Void {
    super.destroy();
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  /**
   * UIWidgetのコールバック受け取り
   **/
  public override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {

    if(sender == null) {
      return;
    }

    var widget:IFlxUIWidget = cast sender;
    if(Std.is(widget, FlxUIRadioGroup)) {
      // 項目を選択した
      var radio:FlxUIRadioGroup = cast widget;
      _cbClickRadioButton(radio.selectedIndex);
      return;
    }

    if(Std.is(widget, FlxUIButton)) {

      var fuib:FlxUIButton = cast widget;
      switch(id) {
        case FlxUITypedButton.CLICK_EVENT:
          // クリックされた
          if(fuib.params != null) {
            var key = fuib.params[0];
            _cbClick(key);
          }
      }
    }
  }

  /**
   * ボタンクリックのコールバック
   **/
  function _cbClick(name:String):Void {

  }

  /**
   * 職業ボタン選択
   **/
  function _cbClickRadioButton(idx:Int):Void {

    var kind = ClassDB.idxToKind(idx);
    // 詳細
    {
      var name = ClassDB.getName(kind);
      var detail = ClassDB.getDetail(kind);
      _txtDetail.text = '${name}: ${detail}';
    }

    // ステータス
    {
      _txtHp.text  = 'HP: ${ClassDB.getHp(kind)}';
      _txtVit.text = 'VIT: ${ClassDB.getVit(kind)}';
      _txtDex.text = 'DEX: ${ClassDB.getDex(kind)}';
      _txtAgi.text = 'AGI: ${ClassDB.getAgi(kind)}';
    }

    // 所持アイテム
    var items = ClassDB.getItems(kind);
    for(i in 0...ItemList.MAX) {
      var txt:FlxUIText = _txtItems['txtitem${i}'];
      if(i >= items.length) {
        txt.text = "";
        continue;
      }
      var itemid = items[i];
      var name = ItemDB.getName(itemid);
      txt.text = name;
    }

    // スキル
    {
      var skill = ClassDB.getSpecial(kind);
      var name = ItemDB.getName(skill);
      _txtSkill.text = name;
    }
  }
}

