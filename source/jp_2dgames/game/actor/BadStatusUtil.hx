package jp_2dgames.game.actor;

import jp_2dgames.game.gui.message.Msg;
import flixel.util.FlxColor;
import jp_2dgames.game.dat.MyDB;

/**
 * バッドステータスの種類
 **/
enum BadStatus {
  None;     // なし
  Death;    // 死亡 (※使用しない)
  Poison;   // 毒
  Confuse;  // 混乱 (※使用しない)
  Close;    // 封印 (※使用しない)
  Paralyze; // 麻痺
  Sleep;    // 眠り (※使用しない)
  Blind;    // 盲目
  Curse;    // 呪い (※使用しない)
  Weaken;   // 弱体化 (※使用しない)
}

/**
 * バッドステータスユーティリティ
 **/
class BadStatusUtil {
  public static function fromKind(kind:BadstatusesKind):BadStatus {
    return switch(kind) {
      case BadstatusesKind.None:     BadStatus.None;
      case BadstatusesKind.Poison:   BadStatus.Poison;
      case BadstatusesKind.Paralyze: BadStatus.Paralyze;
      case BadstatusesKind.Blind:    BadStatus.Blind;
    }
  }

  /**
   * 有効ターン数を取得する
   **/
  public static function getTurn(bst:BadStatus):Int {
    return switch(bst) {
      case BadStatus.Poison:   3; // 毒は3ターン
      case BadStatus.Paralyze: 3; // 麻痺は3ターン
      case BadStatus.Blind:    3; // 盲目は3ターン
      default: 0; // それ以外
    }
  }

  public static function getColor(bst:BadStatus):Int {
    return switch(bst) {
      case BadStatus.Poison:   FlxColor.GREEN;  // 毒
      case BadStatus.Paralyze: FlxColor.YELLOW; // 麻痺
      case BadStatus.Blind:    FlxColor.PURPLE; // 盲目
      default: throw 'Error: Invalid bst = ${bst}'; // それ以外はエラー
    }
  }

  public static function getMessage(bst:BadStatus):Int {
    return switch(bst) {
      case BadStatus.Poison: Msg.BST_POISON;
      case BadStatus.Paralyze: Msg.BST_PARALYZE;
      case BadStatus.Blind: Msg.BST_BLIND;
      default: throw 'Error: Invalid bst = ${bst}'; // エラー
    }
  }
}
