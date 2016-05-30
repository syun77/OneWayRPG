package jp_2dgames.game.save;

import jp_2dgames.game.item.ItemList;
import jp_2dgames.game.shop.Shop;
import jp_2dgames.game.item.ItemData;
import jp_2dgames.game.global.Global;
import flixel.util.FlxSave;
import haxe.Json;

// グローバル
private class _Global {
  public var level:Int;       // フロア数
  public var money:Int;       // 所持金
  public var step:Int;        // 歩いた歩数
  public var killEnemies:Int; // 倒した敵の数
  public function new() {
  }
  // セーブ
  public function save() {
    level       = Global.level;
    money       = Global.money;
    step        = Global.step;
    killEnemies = Global.killEnemies;
  }
  // ロード
  public function load(data:Dynamic) {
    Global.setLevel(data.level);
    Global.setMoney(data.money);
    Global.setStep(data.step);
    Global.setKillEnemies(data.killEnemies);
  }
}

// アクター情報
private class _Actors {
  public var player:Params;
  public var enemy:Params;
  public function new() {
    player = new Params();
    enemy = new Params();
  }
  // セーブ
  public function save():Void {
    player.copy(Global.getPlayerParam());
    enemy.copy(Global.getEnemyParam());
  }
  // ロード
  public function load(data:Dynamic):Void {
    Global.getPlayerParam().copy(data.player);
    Global.getEnemyParam().copy(data.enemy);
  }
}

// アイテム情報
private class _ItemList {
  public var array:Array<ItemData>;
  public function new() {
    array = new Array<ItemData>();
  }
  // セーブ
  public function save():Void {
    for(i in 0...ItemList.getLength()) {
      var item = ItemList.getFromIdx(i);
      var it = new ItemData();
      it.copy(item);
      array.push(it);
    }
  }
  // ロード
  public function load(data:Dynamic):Void {
    ItemList.set(data.array);
  }
}

// ショップ情報
private class _Shop {
  public var array:Array<ItemData>;
  public function new() {
    array = new Array<ItemData>();
  }
  // セーブ
  public function save() {
    var items = Shop.get();
    for(item in items) {
      var it = new ItemData();
      it.copy(item);
      array.push(it);
    }
  }
  // ロード
  public function load(data:Dynamic) {
    Shop.set(data.array);
  }
}

/**
 * セーブデータ
 **/
private class SaveData {
  public var global:_Global;
  public var shop:_Shop;
  public var actors:_Actors;
  public var itemlist:_ItemList;

  public function new() {
    global = new _Global();
    shop = new _Shop();
    actors = new _Actors();
    itemlist = new _ItemList();
  }

  // セーブ
  public function save() {
    global.save();
    shop.save();
    actors.save();
    itemlist.save();
  }

  // ロード
  public function load(data:Dynamic) {
    global.load(data.global);
    shop.load(data.shop);
    actors.load(data.actors);
    itemlist.load(data.itemlist);
  }
}

/**
 * セーブ処理
 **/
class Save {
  public function new() {
  }

  /**
   * セーブする
   * @param bToText テキストへの保存を行うかどうか
   * @param bLog    ログ出力を行うかどうか
   **/
  public static function save(bToText:Bool, bLog:Bool):Void {

    var data = new SaveData();
    data.save();

    var str = Json.stringify(data);

    if(bToText) {
      // テキストへ保存する
#if neko
      sys.io.File.saveContent(AssetPaths.PATH_SAVE, str);
      if(bLog) {
        trace("save ----------------------");
        trace(data);
      }
#end
    }
    else {
      // セーブ領域へ書き込み
      var saveutil = new FlxSave();
      saveutil.bind("SAVEDATA");
      saveutil.data.playdata = str;
      saveutil.flush();
    }
  }

  /**
   * ロードする
   * @param bFromText テキストから読み込みを行うかどうか
   * @param bLog      ログ出力を行うかどうか
   **/
  public static function load(bFromText:Bool, bLog:Bool):Void {
    var str = "";
#if neko
    str = sys.io.File.getContent(AssetPaths.PATH_SAVE);
    if(bLog) {
      trace("load ----------------------");
      trace(str);
    }
#end

    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(bFromText) {
      // テキストファイルからロードする
      var data = Json.parse(str);
      var s = new SaveData();
      s.load(data);
    }
    else {
      var data = Json.parse(saveutil.data.playdata);
      var s = new SaveData();
      s.load(data);
    }
  }

  /**
   * セーブデータを消去する
   **/
  public static function erase():Void {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    saveutil.erase();
  }

  public static function isContinue():Bool {
    var saveutil = new FlxSave();
    saveutil.bind("SAVEDATA");
    if(saveutil.data == null) {
      return false;
    }
    if(saveutil.data.playdata == null) {
      return false;
    }

    return true;
  }
}
