package jp_2dgames.game.gui.message;

import jp_2dgames.lib.CsvLoader;

/**
 * UIのメッセージ管理
 **/
class UIMsg {
  public static inline var BOSS_NOTICE:Int          = 1;  // ボス出現前メッセージ
  public static inline var SHOP_FIND:Int            = 2;  // ショップ発見メッセージ
  public static inline var UPGRADE_FIND:Int         = 3;  // 強化発見メッセージ

  private static var _csv:CsvLoader = null;
  /**
   * CSV読み込み
   **/
  public static function load():Void {
    _csv = new CsvLoader(AssetPaths.CSV_UI_MSG);
  }

  /**
   * メッセージテキスト取得
   **/
  public static function get(ID:Int):String {
    return StringTools.replace(_csv.getString(ID, "msg"), "<br>", "\n");
  }

  public static function get2(ID:Int, args:Array<Dynamic>):String {
    var msg = get(ID);
    if(args != null) {
      var idx:Int = 1;
      for(val in args) {
        msg = StringTools.replace(msg, '<val${idx}>', '${val}');
        idx++;
      }
    }

    return msg;
  }
}
