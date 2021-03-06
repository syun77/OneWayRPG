package jp_2dgames.game.dat;

/**
 * アイテム抽選のジェネレーター
 **/
import flixel.FlxG;
class LotteryGenerator<T> {

  // ----------------------------------------------
  // ■フィールド
  var _idxs:Array<T>;     // 出現するIDの配列
  var _ratios:Array<Int>; // 出現確率の配列
  var _sum:Int;           // 確率の合計

  public function new() {
    _idxs = new Array<T>();
    _ratios = new Array<Int>();
    _sum = 0;
  }

  /**
   * 出現情報の追加
   * @param idx 番号
   * @param ratio 出現確率(1〜)
   **/
  public function add(idx:T, ratio:Int):Void {
    if(ratio <= 0) {
      // 発生しないので追加不要
      return;
    }

    _idxs.push(idx);
    _ratios.push(ratio);
    _sum += ratio;
  }

  /**
   * 抽選を行う
   **/
  public function exec():T {
    var rnd = FlxG.random.int(0, _sum-1);
    var idx:Int = 0;
    for(ratio in _ratios) {
      if(rnd < ratio) {
        // マッチした
        return _idxs[idx];
      }

      // 次を調べる
      rnd -= ratio;
      idx++;
    }

    // 見つからなかった
    dump();
    throw "Error: Can't lot.";
  }

  /**
   * デバッグ出力
   **/
  public function dump():Void {
    trace('sum: ${_sum}');
    for(i in 0..._idxs.length) {
      var idx = _idxs[i];
      var ratio = _ratios[i];
      trace('[${i}] ${idx}(${ratio})');
    }
  }
}
