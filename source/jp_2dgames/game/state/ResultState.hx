package jp_2dgames.game.state;
import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.global.Global;
import flixel.addons.ui.FlxUIText;
import flixel.FlxG;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIState;

/**
 * リザルト画面
 **/
class ResultState extends FlxUIState {

  // ------------------------------------------
  // ■定数
  // スコア倍率
  var RATIO_KILL:Int  = 10;  // 敵を倒した数
  var RATIO_MONEY:Int = 50;  // お金
  var RATIO_FOOD:Int  = 10;  // 食糧
  var RATIO_ITEM:Int  = 30;  // アイテム
  var RATIO_BONUS:Int = 500; // クリアボーナス

  // ------------------------------------------
  // ■フィールド
  var _txtKill:FlxUIText;  // 敵を倒した数
  var _txtMoney:FlxUIText; // 所持金
  var _txtFood:FlxUIText;  // お金
  var _txtItem:FlxUIText;  // アイテム
  var _txtCompleted:FlxUIText; // クリアボーナス
  var _txtTotal:FlxUIText; // トータルスコア

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "result";
    super.create();

    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "txtkill":      _txtKill  = cast widget;
        case "txtmoney":     _txtMoney = cast widget;
        case "txtfood":      _txtFood  = cast widget;
        case "txtitem":      _txtItem  = cast widget;
        case "txtcompleted": _txtCompleted = cast widget;
        case "txttotal":     _txtTotal = cast widget;
      }
    });

    // スコアを設定
    _setScore();
  }

  /**
   * スコアを設定
   **/
  function _setScore():Void {

    var total:Int = 0;
    // 敵を倒した数
    {
      var kills:Int = Global.killEnemies;
      var ratio:Int = RATIO_KILL;
      var score:Int = kills * ratio;
      _txtKill.text = 'Kill Enemies: ${kills} x ${ratio} = ${score}pt';
      total += score;
    }
    // お金
    {
      var money:Int = Global.money;
      var ratio:Int = RATIO_MONEY;
      var score:Int = money * ratio;
      _txtMoney.text = 'Money: ${money} x ${ratio} = ${score}pt';
      total += score;
    }
    // 食糧
    {
      var food:Int = Global.getPlayerParam().food;
      var ratio:Int = RATIO_FOOD;
      var score:Int = food * ratio;
      _txtFood.text = 'Food: ${food} x ${ratio} = ${score}pt';
      total += score;
    }
    // アイテム
    {
      var item:Int = ItemList.calcTotalScore();
      var ratio:Int = RATIO_ITEM;
      var score:Int = item * ratio;
      _txtItem.text = 'Item: ${item} x ${ratio} = ${score}pt';
      total += score;
    }
    // クリアボーナス
    {
      var bonus:Int = Global.level;
      var ratio:Int = RATIO_BONUS;
      var score:Int = bonus * ratio;
      _txtCompleted.text = 'Bonus: ${bonus} x ${ratio} = ${score}pt';
      total += score;
    }

    _txtTotal.text = 'Total: ${total}pt';
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);
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
            if(key == "close") {
              _cbClick();
            }
          }
      }
    }
  }

  function _cbClick():Void {
    // タイトル画面に戻る
    FlxG.switchState(new TitleState());
  }
}
