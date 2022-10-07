# OneWayRPG

## ライセンス
* MIT License
* Copyright: [2dgames.jp](http://2dgames.jp) (syun)


## 謝辞

### 使用素材

#### フォント

* [Pixel M plus（ピクセル・エムプラス）](http://itouhiro.hatenablog.com/entry/20130602/font)

#### 背景・モンスター画像・エフェクト

* [ぴぽや](http://piposozai.blog76.fc2.com/)

## ソースコード説明

### モジュール階層

    game
     +-- actor
     |    +-- Actor.hx: キャラクター
     |    +-- ActorMgr.hx: キャラクター管理
     |    +-- BadStatusList.hx: バッドステータスの定義
     |    +-- BadStatusUtil.hx: バッドステータスのユーティリティ (型変換や有効ターン数など)
     |    +-- BtlGroupUtil.hx: グループ(側)の定義
     |    +-- BtlParams.hx: 命中率・回避率パラメータの管理
     |    +-- Shield.hx: 攻撃を無効化するシールドの管理
     |    +-- TempActorMgr.hx: キャラクター管理 (計算用のテンポラリ)
     |
     +-- dat
     |    +-- AttributeUtil.hx: 武器の属性
     |    +-- ClassDB.hx: クラス (職業) 情報
     |    +-- EffectDB.hx: エフェクト情報
     |    +-- EnemyDB.hx: 敵情報
     |    +-- EnemyEncountDB.hx: 敵とのエンカウント情報
     |    +-- FloorInfoDB.hx: フロア情報
     |    +-- ItemDB.hx: アイテム情報
     |    +-- ItemLotteryDB.hx: アイテム抽選状況
     |    +-- LotteryGenerator.hx: 抽選処理の実行
     |    +-- MyDB.cdb: データベース
     |    +-- MyDB.hx: データベースへのアクセスモジュール
     |    +-- MyDB.img: データベースで使用している画像
     |    +-- MyDBUtil.hx: データベースの読み込み
     |    +-- ResistData.hx: 耐性情報
     |    +-- UpgradeDB.hx: アップグレード情報
     |
     +-- global
     |    +-- BtlGlobal.hx: バトルのグローバル変数
     |    +-- Global.hx: ゲーム内グローバル変数
     |    +-- ItemLottery.hx: アイテム出現の抽選情報
     |
     +-- gui
     |    +-- message
     |    |    +-- Message.hx: ログテキスト
     |    |    +-- Msg.hx: テキスト定数
     |    |    +-- UIMsg.hx: テキスト操作ユーティリティ
     |    |
     |    +-- BadStatusIcon.hx: バッドステータスアイコンUI
     |    +-- BadStatusUI.hx: バッドステータスUI (アイコンを並べる)
     |    +-- BattleResultPopupUI.hx: バトルリザルトUI
     |    +-- BattleUI.hx: バトルUI管理
     |    +-- DialogPopupUI.hx: リザルトUIの報酬テキスト
     |    +-- GameoverUI.hx: ゲームオーバー画面
     |    +-- GameUI.hx: (未使用？)
     |    +-- MyButton.hx: FlxTypedButtonの独自拡張
     |    +-- StageClearUI.hx: ステージクリア画面 (未使用？)
     |
     +-- item
     |    +-- ItemData.hx: アイテムデータ
     |    +-- ItemDetail.hx: アイテムの詳細効果
     |    +-- ItemList.hx: インベントリ
     |    +-- ItemUtil.hx: アイテム操作のユーティリティ
     |
     +-- particle
     |    +-- Particle.hx: パーティクル
     |    +-- ParticleAnim.hx: 連番画像の再生
     |    +-- ParticleBmpFont.hx: BMPフォントエフェクト
     |    +-- ParticleMessage.hx: テキストエフェクト
     |    +-- ParticleSmoke.hx: 煙エフェクト (未使用？)
     |    +-- ParticleStartLevel.hx: レベル開始演出 (未使用？)
     |    +-- ParticleUtil.hx: その他のエフェクト（お金増減、食料増減）
     |
     +-- save
     |    +-- Save.hx: セーブデータ
     |
     +-- sequence
     |    +-- btl
     |    |    +-- BtlCalc.hx: バトルの数値計算 (命中率・回避率・ダメージ量)
     |    |    +-- BtlLogic.hx: 
     |    |    +-- BtlLogicBegin.hx
     |    |    +-- BtlLogicData.hx
     |    |    +-- BtlLogicFactory.hx
     |    |    +-- BtlLogicMgr.hx
     |    |    +-- BtlLogicPlayer.hx
     |    |
     |    +-- Btl.hx
     |    +-- Dg.hx
     |    +-- DgEventMgr.hx
     |
     +-- shop
     |    +-- Shop.hx
     |
     +-- state
     |    +-- BootState.hx
     |    +-- EndingState.hx
     |    +-- InventorySubState.hx
     |    +-- MakeCharacterState.hx
     |    +-- PlayInitState.hx
     |    +-- PlayState.hx
     |    +-- ResultState.hx
     |    +-- ShopSubState.hx
     |    +-- TitleState.hx
     |    +-- UpgradeSubState.hx
     |
     +-- token
     |    +-- Token.hx
     |    +-- TokenMgr.hx
     |
     +-- AssetPaths.hx
     +-- Bg.hx
     +-- Params.hx
     +-- SeqMgr.hx

### 定数関連

#### BtlGroup (バトルの側)

* Player: プレイヤー側
* Enemy: 敵側
* Both: 両方

#### BadStatus (バッドステータス)

* None:     // なし
* Death:    // 死亡 (※使用しない)
* Poison:   // 毒
* Confuse:  // 混乱 (※使用しない)
* Close:    // 封印 (※使用しない)
* Paralyze: // 麻痺
* Sleep:    // 眠り (※使用しない)
* Blind:    // 盲目
* Curse:    // 呪い (※使用しない)
* Weaken:   // 弱体化 (※使用しない)
* Stan:     // スタン

#### Resists (耐性)

* Weak:        // 弱点
* Normal:      // 通常
* Resistance:  // 耐性
* Invalid:     // 無効

#### ItemCategory (アイテムカテゴリ)

* Portion: ポーション
* Weapon: 武器

### パラメータ関連

#### Params (Actor共通パラメータ)

* id: 敵ID (プレイヤーは0番)
* kind: 職業 (プレイヤーのみ有効)
* hp: HP
* hpmax: 最大HP
* food: 食料
* str: 力
* vit: 体力
* dex: 器用さ (命中率)
* agi: 素早さ
* shield: シールドの枚数
* shieldMax: シールドの最大数

#### BadStatusParams (バッドステータスパラメータ)

* bst: バッドステータスの種類 (BadStatus)
* bAdhere: 付着しているかどうか
* cntAdhere: 付着回数
* turn: 有効ターン数

#### BtlParams (パトル補正パラメータ)

* cntAttackEvade: 攻撃を回避された回数
* dexVal: 命中率上昇値
* dexTurn: 命中率上昇の有効ターン数
* evaVal: 回避率上昇値
* evaTurn: 回避率上昇の有効ターン数

#### ResistData (耐性データ)

* attr:Attribute; // 属性
* resist:Resists; // 耐性
* value:Float;    // 割合

#### BtlLogicAttackParam (攻撃時のパラメータ)

* power:Int;      // ダメージ量
* ratio:Int;      // 命中率
* ratioRaw:Int;   // 主体者・対象者による補正がな状態の命中率
* attr:Attribute; // 属性
* bst:BadStatus;  // 付着するバステ

#### BtlLogicRecoverParam (回復行動のパラメータ)

* hp:Int; // HP回復量

#### BtlLogic (行動種別)

*   // ■行動開始
*  BeginAttack (attr:攻撃属性, bMsg:メッセージ表示フラグ)  // 通常攻撃
*  BeginLastAttack (引数なし)                        // 最後の一撃

*  // ■行動終了
*  EndAction (bHit:攻撃が命中したかどうか)

*  // ■アイテム消費
*  UseItem (item:アイテム情報)

*  // ■メッセージ表示
*  MessageDisp (msgID:メッセージID, args:メッセージ引数)

*  // ■効果反映
*  HpDamage (val:ダメージ量, bSeq:連続ダメージかどうか) // HPダメージ
*  HpRecover (val:回復量)          // HP回復
*  Badstatus(bst:BadStatus);      // バッドステータス
*  ChanceRoll (bst:付着するバッドステータス) // 成功 or 失敗
*  AddFood (val:増加した食料の値)    // 食糧増加
*  ShieldDamage (val:シールドへのダメージ量, bSeq:連続かどうか) // シールドダメージ
*  // ■ステータスアップ
*  DexUp (val:命中率上昇値) // 命中率アップ
*  EvaUp (val:回避率上昇値) // 回避率アップ

*  // ■その他
*  DecayItem (item:劣化するアイテム) // アイテム壊れる
*  Dead (引数なし。targetが死亡する) // 死亡
*  TurnEnd (引数なし。targetのターン終了) // ターン終了
*  BtlEnd (bWin:勝利かどうか) // バトル終了

## ソースコード個別解説

### BtlLogicPlayer.hx

BtlLogicData を再生するモジュール。BtlLogicDataは以下のデータを持つ

* type:BtlLogic;   // 演出種別
* actorID:Int;     // 行動主体者
* targetID:Int;    // 対象者
* bWaitQuick:Bool; // 演出時間を短縮するかどうか
_updateMain()で、BtlLogicのパラメータに対応する処理を行う。
もし演出完了待ちがあれば、_checkWait() で待ちが発生する。
_state が State.End になると処理が終了となる。

### BtlLogicMgr.x

バトルの計算や演出を管理するモジュール。以下状態遷移について

* State.Init: BtlLogicDataを先頭から取り出す。データがある場合は BtlLogicPlayer.start() で再生して State.Main へ遷移。存在しない場合は State.End へ遷移
* State.Main: BtlLogicPlayer.update() で更新。BtlLogicPlayer.isEnd() が true を返したら終了なので、 State.Init に戻る
* State.End: 終了

_createLogic() で BtlLogicData を作成する

1. ActorMgr から TempActorMgr に actor情報 をコピーする
2. 行動順ソートをする
3. 行動順に _createActionActor() で BtlLogicData を作成する。もしバトルが終了していたらここで中断
4. 行動順にバステ処理とターン終了処理を行う。もしバトルが終了していたらここで中断

_createActionActor() は BtlLogicData を生成する関数

1. actorの死亡チェック。死亡していたら何もせず終了
2. actorのバステチェック。麻痺していたら何もせず終了
3. actorの側が BltGroup.Player の場合は BtlLogicFactory.createPlayerLogic() を呼び出す。側が BtlGroup.Enemy の場合は BtlLogicFactory.createEnemyLogic() を呼び出す
4. 