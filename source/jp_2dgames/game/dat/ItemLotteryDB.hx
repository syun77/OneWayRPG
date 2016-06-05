package jp_2dgames.game.dat;

import jp_2dgames.game.dat.MyDB;

/**
 * アイテム獲得の抽選DB
 **/
class ItemLotteryDB {

  public static function createGenerator(level:Int, classkind:ClassesKind):LotteryGenerator<ItemsKind> {
    var gen = new LotteryGenerator<ItemsKind>();
    for(lot in MyDB.itemlottery.all) {
      if(lot.start <= level && level <= lot.end) {
        // 出現レベルに該当
        var ratio:Int = lot.ratio;
        var attr = ItemDB.getAttribute(lot.item.id);
        var multipul = ClassDB.getDrop(classkind, attr);
        if(multipul > 0) {
          // 出現確率補正
          ratio = Std.int(ratio * multipul);
          if(ratio < 1) {
            ratio = 1;
          }
        }
        gen.add(lot.item.id, ratio);
      }
    }

    return gen;
  }
}
