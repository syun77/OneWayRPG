package jp_2dgames.game.actor;

import jp_2dgames.game.actor.BadStatusUtil.BadStatus;

/**
 * バッドステータスのパラメータ
 **/
class BadStatusParams {
  public var bst:BadStatus; // バッドステータスの種類
  public var bAdhere:Bool;  // 付着しているかどうか
  public var cntAdhere:Int; // 付着回数
  public var turn:Int;      // 有効ターン数

  // コンストラクタ
  public function new() {
    bst = BadStatus.None;
    reset();
  }

  // 付着回数をリセット
  public function reset():Void {
    bAdhere = false;
    cntAdhere = 0;
  }

  public function adhere(Bst:BadStatus):Void {
    bAdhere = true;
    bst = Bst;
    cntAdhere++;
    turn = BadStatusUtil.getTurn(bst);
  }
}

/**
 * バッドステータスリスト
 **/
class BadStatusList {

  // マップ
  var _map:Map<BadStatus,BadStatusParams>;

  /**
   * コンストラクタ
   **/
  public function new() {
    _map = new Map<BadStatus,BadStatusParams>();
    var arr = [
      BadStatus.Poison,
      BadStatus.Paralyze,
      BadStatus.Blind,
    ];
    for(bst in arr) {
      var prm = new BadStatusParams();
      prm.bst = bst;
      _map[bst] = prm;
    }
  }

  /**
   * リセット
   **/
  public function reset():Void {
    for(prm in _map) {
      prm.reset();
    }
  }

  /**
   * バッドステータスのパラメータを取得する
   **/
  public function getParams(bst:BadStatus):BadStatusParams {
    if(_map.exists(bst) == false) {
      throw 'Error: BadStatusList.getParams() Not exists bst = ${bst}';
    }
    return _map[bst];
  }

  /**
   * バッドステータスのパラメータを連続して取得する
   **/
  public function forEach(func:BadStatusParams->Void):Void {
    for(prm in _map) {
      func(prm);
    }
  }

  /**
   * バッドステータスを付着する
   **/
  public function adhere(bst:BadStatus):Void {
    var prm = getParams(bst);
    prm.adhere(bst);
  }

  /**
   * バッドステータスが付着しているかどうか
   **/
  public function isAdhere(bst:BadStatus):Bool {
    var prm = getParams(bst);
    return prm.bAdhere;
  }

  /**
   * バッドステータスを回復する
   **/
  public function recover(bst:BadStatus):Void {
    var prm = getParams(bst);
    prm.bAdhere = false;
  }

  /**
   * デバッグ出力
   **/
  public function dump():Void {
    for(prm in _map) {
      trace(prm);
    }
  }
}
