package jp_2dgames.game.actor;
import jp_2dgames.game.actor.BadStatusUtil;
import jp_2dgames.lib.MyShake;
import flixel.util.FlxTimer;
import jp_2dgames.game.global.Global;
import jp_2dgames.lib.Snd;
import jp_2dgames.game.actor.BtlGroupUtil.BtlGroup;
import jp_2dgames.game.particle.Particle;
import jp_2dgames.game.gui.BattleUI;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import jp_2dgames.game.dat.EnemyDB;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.FlxSprite;
import jp_2dgames.game.actor.BtlGroupUtil;
import flixel.addons.effects.chainable.FlxEffectSprite;
import jp_2dgames.game.dat.MyDB;

/**
 * アクター
 **/
class Actor extends FlxEffectSprite {

  // タイマー
  static inline var TIMER_SHAKE:Int = 120; // 揺れタイマー

  // -------------------------------------------
  // ■フィールド
  var _name:String;    // 名前
  var _params:Params;  // パラメータ
  var _group:BtlGroup; // 敵か味方か
  var _bstList:BadStatusList; // バッドステータス

  // バトル用パラメータ
  var _btlPrms:BtlParams;

  // 演出用
  var _spr:FlxSprite;       // もとのスプライト
  var _xstart:Float = 0.0;  // 出現時のX座標
  var _yofs:Int     = 0;    // 描画座標のオフセット(Y)
  var _tAnime:Float = 0.0;  // アニメーション用タイマー
  var _tShake:Float = 0.0;  // 揺れ用のタイマ
  // エフェクト
  var _eftWave:FlxWaveEffect;     // ゆらゆら
  var _eftGlitch:FlxGlitchEffect; // ゆがみ
  // シールド
  var _shield:Shield;


  // アクセサ
  public var uid(default, default):Int;
  public var group(get, never):BtlGroup;
  public var params(get, never):Params;
  public var id(get, never):EnemiesKind;
  public var hp(get, never):Int;
  public var hpmax(get, never):Int;
  public var hpratio(get, never):Float;
  public var str(get, never):Int;
  public var vit(get, never):Int;
  public var agi(get, never):Int;
  public var dex(get, never):Int;
  public var food(get, never):Int;
  public var btlPrms(get, never):BtlParams;
  public var bstList(get, never):BadStatusList;
  public var xcenter(get, never):Float;
  public var ycenter(get, never):Float;
  public var shield(get, never):Shield;


  /**
   * コンストラクタ
   **/
  public function new() {
    _spr = new FlxSprite();
    super(_spr);

    _eftWave = new FlxWaveEffect();
    _eftGlitch = new FlxGlitchEffect();
    _eftGlitch.strength = 0;
    _eftGlitch.direction = FlxGlitchDirection.VERTICAL;
    effects = [_eftWave, _eftGlitch];

    _params = new Params();
    _btlPrms = new BtlParams();
    _bstList = new BadStatusList();

    // 非表示にしておく
    visible = false;

    // シールドを生成
    _shield = new Shield();
    _shield.visible = false;
    _shield.kill();
  }

  /**
   * 初期化
   **/
  public function init(p:Params):Void {
    // 参照を保持する
    _params = p;
    if(p.id == EnemiesKind.Player) {
      // プレイヤー
      _initPlayer();
    }
    else {
      // 敵
      _initEnemy();
    }

    // 開始座標を保存
    _xstart = x;

    // バッドステータス初期化
    _bstList.reset();
  }

  /**
   * プレイヤーの初期化
   **/
  function _initPlayer():Void {
    _name = EnemyDB.getName(id);
    _group = BtlGroup.Player;
    visible = false;

    // 位置を調整
    var rect = BattleUI.getPlayerHpRect();
    x = rect.x;
    y = rect.y;
    width = rect.width;
    height = rect.height;
    y -= height;
    rect.put();
  }

  /**
   * 敵の初期化
   **/
  function _initEnemy():Void {
    var p = _params;
    _group = BtlGroup.Enemy;
    _name = EnemyDB.getName(p.id);
    _params.str = EnemyDB.getAtk(p.id);
    _params.setHpMax(EnemyDB.getHp(p.id));
    _params.setShield(EnemyDB.getShield(p.id));
    _yofs = EnemyDB.getYOfs(p.id);

    // 敵画像読み込み
    var path = EnemyDB.getImage(p.id);
    _spr.loadGraphic(path);
    visible = true;

    // 位置を調整
    x = FlxG.width/2 - _spr.width/2;
    y = FlxG.height/2 - _spr.height;

    // 出現エフェクト開始
    _eftGlitch.active = false;
    _eftWave.strength = 100;
    _eftWave.wavelength = 2;
    FlxTween.tween(_eftWave, {strength:0}, 0.5, {ease:FlxEase.expoOut});
    color = 0;
    FlxTween.color(this, 0.5, FlxColor.BLACK, FlxColor.WHITE);
    _spr.alpha = 0;
    FlxTween.tween(_spr, {alpha:1}, 0.5);
    if(Global.step <= 0) {
      // ボス出現演出
      _spr.color = FlxColor.BLACK;
      FlxTween.tween(_spr, {color:FlxColor.WHITE}, 1);
      // ズームイン
      FlxTween.tween(FlxG.camera, {zoom:1.1}, 0.3, {ease:FlxEase.expoOut});
      new FlxTimer().start(0.1, function(timer:FlxTimer) {
        Particle.start(PType.Ring, x+_spr.width/2, y+_spr.height/2, FlxColor.WHITE);
        if(timer.loopsLeft == 0) {
          // ズームアウト
          FlxTween.tween(FlxG.camera, {zoom:1}, 0.5, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
            // 揺らす
            MyShake.low();
          }});
        }
      }, 5);
      Snd.playSe("roar");
    }
    else {
      Snd.playSe("enemy");
    }

    // シールド表示
    _shield.revive();
  }

  /**
   * パラメータをコピーする
   **/
  public function copyTo(dst:Actor):Void {
    dst.uid   = uid;
    dst._name = _name;
    dst.params.copy(params); // 基本パラメータ
    dst._group = _group;
    dst.bstList.copy(bstList); // バッドステータス
    dst.btlPrms.copy(btlPrms); // バトル用パラメータ
  }

  /**
   * 更新
   **/
  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    _tAnime++;

    // 揺れの更新
    _updateShake();

    // シールドの更新
    _updateShield();
  }

  /**
   * 更新・揺らす
   **/
  function _updateShake():Void {
    if(_group != BtlGroup.Enemy) {
      return;
    }

    x = _xstart;
    if(_tShake > 0) {
      _tShake *= 0.9;
      if(_tShake < 1) {
        _tShake = 0;
      }
      var xsign = if(_tAnime%4 < 2) 1 else -1;
      x = _xstart + (_tShake * xsign * 0.2);
    }
  }

  /**
   * シールドの更新
   **/
  function _updateShield():Void {
    _shield.visible = false;
    if(params.isValidShield()) {
      _shield.visible = visible;
      _shield.x = xcenter-_shield.width/2;
      _shield.y = ycenter-_shield.height/2;
      _shield.setPercent(params.shield / params.shieldMax);
    }
  }

  /**
   * 名前を取得
   **/
  public function getName():String {
    return _name;
  }

  /**
   * 死亡したかどうか
   **/
  public function isDead():Bool {
    return hp <= 0;
  }

  /**
   * HPが最大かどうか
   **/
  public function isHpMax():Bool {
    return hp == hpmax;
  }

  /**
   * 警告状態かどうか
   **/
  public function isWarning():Bool {
    // 60%以下で警告とみなす
    return hpratio <= 0.6;
  }

  /**
   * 危険状態かどうか
   **/
  public function isDanger():Bool {
    // 40%以下で危険とみなす
    return hpratio <= 0.4;
  }

  /**
   * ダメージを与える
   **/
  public function damage(v:Int):Float {

    // HPを減らす
    _params.hp -= v;
    if(group == BtlGroup.Player) {
      if(_params.hp < 0) {
        _params.hp = 0;
      }
    }

    var ratio = v / hpmax;
    if(ratio < 0.2) {
      ratio = 0.2;
    }
    if(ratio > 1.0) {
      ratio = 1.0;
    }

    if(_group == BtlGroup.Player) {
      // プレイヤー
    }
    else {
      // 敵
      shake(ratio);
    }

    return ratio;
  }

  /**
   * バッドステータス付着
   **/
  public function adhereBadStatus(bst:BadStatus):Void {
    bstList.adhere(bst);
  }

  /**
   * 指定のバッドステータスが付着しているかどうか
   **/
  public function isAdhereBadStatus(bst:BadStatus):Bool {
    return bstList.isAdhere(bst);
  }

  /**
   * ターン終了
   **/
  public function turnEnd():Void {
    bstList.turnEnd();
    btlPrms.turnEnd();
  }

  /**
   * 消滅
   **/
  public function vanish():Void {

    // 死亡エフェクト
    _eftGlitch.active = true;
    FlxTween.tween(_eftGlitch, {strength:100}, 0.5, {ease:FlxEase.expoIn, onComplete:function(tween:FlxTween) {
      _eftGlitch.strength = 0;
      visible = false;
    }});
    Snd.playSe("destroy");

  }

  /**
   * HP回復
   **/
  public function recover(v:Int):Void {
    _params.hp += v;
    if(_params.hp > hpmax) {
      _params.hp = hpmax;
    }
  }

  /**
   * 食糧を増やす
   **/
  public function addFood(v:Int):Void {
    _params.food += v;
    if(_params.food > 99) {
      _params.food = 99;
    }
  }

  /**
   * 食糧を減らす
   **/
  public function subFood(v:Int):Bool {

    _params.food -= v;
    if(_params.food < 0) {
      _params.food = 0;
      // 食糧が足りない
      return false;
    }

    // 食糧が残っていた
    return true;
  }

  /**
   * 最大HPを増やす
   **/
  public function addHpMax(v:Int):Void {
    _params.hpmax += 1;
  }

  /**
   * VITを増やす
   **/
  public function addVit(v:Int):Void {
    _params.vit += v;
  }

  /**
   * DEXを増やす
   **/
  public function addDex(v:Int):Void {
    _params.dex += v;
  }

  /**
   * AGIを増やす
   **/
  public function addAgi(v:Int):Void {
    _params.agi += v;

  }

  /**
   * 揺らす
   **/
  public function shake(ratio:Float=1.0):Void {
    _tShake = Std.int(TIMER_SHAKE * ratio);
  }

  /**
   * バトルパラメータ初期化
   **/
  public function clearBtlParams():Void {
    btlPrms.clear();
  }

  /**
   * シールドが有効かどうか
   **/
  public function isValidShield():Bool {
    return  params.isValidShield();
  }

  /**
   * シールドダメージ
   **/
  public function subShield(v:Int):Void {
    params.subShield(v);
    _shield.startShake(0.5);
  }

  // -------------------------------------------
  // ■アクセサメソッド
  function get_group() { return _group; }
  function get_params() { return _params; }
  function get_id() { return _params.id; }
  function get_hp() { return _params.hp; }
  function get_hpmax() { return _params.hpmax; }
  function get_hpratio() { return hp / hpmax; }
  function get_str() { return _params.str; }
  function get_vit() { return _params.vit; }
  function get_agi() { return _params.agi; }
  function get_dex() { return _params.dex; }
  function get_food() { return _params.food; }
  function get_btlPrms() { return _btlPrms; }
  function get_bstList() { return _bstList; }
  function get_xcenter() {
    var w = width;
    if(_group == BtlGroup.Enemy) {
      // 敵
      w = _spr.width;
    }
    var px = x + w/2;
    return px;
  }
  function get_ycenter() {
    var h = height;
    if(_group == BtlGroup.Enemy) {
      // 敵
      h = _spr.height;
    }
    var py = y + _yofs + h/2;
    return py;
  }
  function get_shield() { return _shield; }

}
