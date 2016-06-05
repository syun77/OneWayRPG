package jp_2dgames.game.item;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテムデータ
 **/
class ItemData {

  // ----------------------------------------
  // ■フィールド
  public var uid:Int;       // ユニーク番号
  public var id:ItemsKind;  // アイテムID
  public var now:Int;       // 使用回数
  public var max:Int;       // 最大使用回数
  public var buff:Int;      // 強化値
  public var bSpecial:Bool; // スペシャルかどうか

  /**
   * コンストラクタ
   **/
  public function new() {
    uid  = 0;
    id   = ItemsKind.None;
    now  = 0;
    max  = 0;
    buff = 0;
    bSpecial = false;
  }

  /**
   * アイテム情報をコピー
   **/
  public function copy(src:ItemData):Void {
    uid  = src.uid;
    id   = src.id;
    now  = src.now;
    max  = src.max;
    buff = src.buff;
    bSpecial = src.bSpecial;
  }

  /**
   * アイテム摩耗
   **/
  public function wear():Void {

    if(bSpecial) {
      // スペシャルはクールダウンが必要
      resetCoolDown();
      // スキル使用ターンはクールダウンしない
      now++;
      return;
    }

    now--;
    if(now < 0) {
      now = 0;
    }
  }

  /**
   * 次で消滅するかどうか
   **/
  public function isLast():Bool {
    if(isSpecial()) {
      // スペシャルはなくならない
      return false;
    }
    return now == 1;
  }

  /**
   * クールダウン中かどうか
   **/
  public function isCoolDown():Bool {
    if(isSpecial()) {
      // クールダウン中かどうか
      return now > 0;
    }

    return false;
  }

  /**
   * クールダウンする
   **/
  public function coolDown():Void {
    if(isSpecial()) {
      now--;
      if(now < 0) {
        now = 0;
      }
    }
  }

  /**
   * クールダウンをリセットする
   **/
  public function resetCoolDown():Void {
    now = max;
  }

  /**
   * 武器強化
   **/
  public function upgrade():Bool {
    if(isSpecial()) {
      // 強化できない
      return false;
    }

    buff++;
    return true;
  }

  /**
   * スペシャルかどうか
   **/
  public function isSpecial():Bool {
    return bSpecial;
  }

  public function toString():String {
    return '${id}+${buff} [${uid}+${buff}] (${now}/${max}) special=${bSpecial}';
  }
}
