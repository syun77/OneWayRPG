package jp_2dgames.game.state;

import jp_2dgames.game.global.Global;
import jp_2dgames.game.dat.FloorInfoDB;
import jp_2dgames.game.particle.ParticleUtil;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.actor.Actor;
import jp_2dgames.game.gui.message.Msg;
import jp_2dgames.game.gui.message.Message;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIButton;
import jp_2dgames.game.dat.UpgradeDB;
import jp_2dgames.game.actor.ActorMgr;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUISubState;

/**
 * メインゲーム強化メニュー
 **/
class UpgradeSubState extends FlxUISubState {

  /**
   * 出現するかどうか
   **/
  public static function isAppear():Bool {
    return FloorInfoDB.isAppearUpgrade(Global.level, Global.step);
  }

  // -------------------------------------------
  // ■フィールド
  var _btnHpMax:FlxUIButton;
  var _btnVit:FlxUIButton;
  var _btnDex:FlxUIButton;
  var _btnAgi:FlxUIButton;

  /**
   * 生成
   **/
  public override function create():Void {
    _xml_id = "upgrade";
    super.create();

    var idx:Int = 0;
    _ui.forEachOfType(IFlxUIWidget, function(widget:IFlxUIWidget) {
      switch(widget.name) {
        case "btnhp":  _btnHpMax = cast widget;
        case "btnvit": _btnVit   = cast widget;
        case "btndex": _btnDex   = cast widget;
        case "btnagi": _btnAgi   = cast widget;
      }
      if(Std.is(widget, FlxUIButton)) {
        // スライドイン表示
        var px = widget.x;
        widget.x = -widget.width*2;
        FlxTween.tween(widget, {x:px}, 0.5, {ease:FlxEase.expoOut, startDelay:idx*0.05});
        idx++;
      }
    });

    // 項目更新
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
   * 項目の更新
   **/
  function _updateItems():Void {
    var player = ActorMgr.getPlayer();
    // HP
    {
      var cost = _getHpMaxCost(player);
      _setBtnInfo(_btnHpMax, '最大HP', cost);
    }
    // VIT
    {
      var cost = UpgradeDB.getVit(player.vit);
      _setBtnInfo(_btnVit, 'VIT', cost);
    }
    // DEX
    {
      var cost = UpgradeDB.getDex(player.dex);
      _setBtnInfo(_btnDex, 'DEX', cost);
    }
    // AGI
    {
      var cost = UpgradeDB.getAgi(player.agi);
      _setBtnInfo(_btnAgi, 'AGI', cost);
    }
  }

  /**
   * ボタン情報を設定する
   **/
  function _setBtnInfo(btn:FlxUIButton, label:String, cost:Int):Void {

    var bBuy = true;
    var txt = '${label} +1 (${cost})';
    if(cost < 1) {
      // 最大レベルなので買えない
      txt = '${label} +1 (-)';
      bBuy = false;
    }
    btn.label.text = txt;

    if(bBuy) {
      // 購入可能
      btn.skipButtonUpdate = false;
      btn.color = FlxColor.WHITE;
      btn.label.color = FlxColor.WHITE;
    }
    else {
      // 購入できない
      btn.skipButtonUpdate = true;
      btn.color = FlxColor.GRAY;
      btn.label.color = FlxColor.GRAY;
    }
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
            if(key == "close") {
              // おしまい
              close();
            }
            else {
              // アップグレード実行
              _execUpgrade(key);
            }
          }
      }
    }
  }

  /**
   * 最大HP上昇に必要なコストを取得する
   **/
  function _getHpMaxCost(player:Actor):Int {
    var cost = UpgradeDB.getHpMax(player.hpmax - 10);
    if(player.hpmax < 10) {
      cost = UpgradeDB.getHpMax(0);
    }
    return cost;
  }

  /**
   * アップグレードを実行
   **/
  function _execUpgrade(key:String):Void {

    var player = ActorMgr.getPlayer();
    var cost = 0;
    var func:Void->Void = function() {};
    switch(key) {
      case "btnhp":
        cost = _getHpMaxCost(player);
        func = function() {
          player.addHpMax(1);
          Message.push2(Msg.UPGRADE_HPMAX, [1]);
        }
      case "btnvit":
        cost = UpgradeDB.getVit(player.vit);
        func = function() {
          player.addVit(1);
          Message.push2(Msg.UPGRADE_PARAM, ["VIT"]);
        }
      case "btndex":
        cost = UpgradeDB.getDex(player.dex);
        func = function() {
          player.addDex(1);
          Message.push2(Msg.UPGRADE_PARAM, ["DEX"]);
        }
      case "btnagi":
        cost = UpgradeDB.getAgi(player.agi);
        func = function() {
          player.addAgi(1);
          Message.push2(Msg.UPGRADE_PARAM, ["AGI"]);
        }
    }

    if(cost > player.food) {
      // 食糧が足りない
      Message.push2(Msg.NOT_ENOUGH_FOOD);
      Snd.playSe("error", true);
      return;
    }

    // パラメータ上昇・メッセージ表示
    func();

    // 食糧を減らす
    player.subFood(cost);
    ParticleUtil.startFood(-cost);
    Snd.playSe("powerup", true);
    // 項目更新
    _updateItems();
  }
}
