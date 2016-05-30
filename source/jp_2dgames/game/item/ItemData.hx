package jp_2dgames.game.item;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテムデータ
 **/
class ItemData {

  // ----------------------------------------
  // ■フィールド
  public var uid:Int;      // ユニーク番号
  public var id:ItemsKind; // アイテムID
  public var now:Int;      // 使用回数
  public var max:Int;      // 最大使用回数
  public var buff:Int;     // 強化値

  /**
   * コンストラクタ
   **/
  public function new() {
    id = ItemsKind.None;
    now = 0;
    max = 0;
    buff = 0;
  }

  /**
   * アイテム情報をコピー
   **/
  public function copy(src:ItemData):Void {
    id   = src.id;
    now  = src.now;
    max  = src.max;
    buff = src.buff;
  }

  public function toString():String {
    return '${id}+${buff} [${uid}+${buff}] (${now}/${max})';
  }
}
