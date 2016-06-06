package jp_2dgames.game.shop;
import jp_2dgames.game.dat.FloorInfoDB;
import jp_2dgames.game.global.Global;
import jp_2dgames.game.item.ItemUtil;
import jp_2dgames.game.dat.ItemLotteryDB;
import jp_2dgames.game.item.ItemData;

/**
 * ショップ
 **/
class Shop {

  static var _instance:Shop = null;
  public static function create(level:Int):Void {
    _instance = new Shop();
    _instance._create(level);
  }
  public static function destroy():Void {
    _instance = null;
  }
  public static function get():Array<ItemData> {
    return _instance._items;
  }
  public static function isAppear():Bool {
    if(isEmpty()) {
      return false;
    }
    if(FloorInfoDB.isAppearShop(Global.level, Global.step) == false) {
      return false;
    }
    return true;
  }
  public static function isEmpty():Bool {
    return _instance._isEmpty();
  }
  public static function set(items:Array<ItemData>):Void {
    _instance._set(items);
  }

  // -------------------------------------------
  // ■フィールド
  var _items:Array<ItemData>;

  /**
   * コンストラクタ
   **/
  public function new() {
    _items = null;
  }

  /**
   * アイテムの生成
   **/
  function _create(level:Int):Void {
    _items = new Array<ItemData>();
    var kind = Global.getPlayerParam().kind;
    var gen = ItemLotteryDB.createGenerator(level, kind);
    for(i in 0...5) {
      var id = gen.exec();
      var item = ItemUtil.add(id);
      _items.push(item);
    }
  }

  function _isEmpty():Bool {
    return _items.length == 0;
  }

  function _set(items:Array<ItemData>):Void {
    _items = new Array<ItemData>();
    for(item in items) {
      var it = new ItemData();
      it.copy(item);
      _items.push(it);
    }
  }
}
