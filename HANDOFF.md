【アプリ名：Farm Loop】

# Farm Loop 開発引き継ぎ開始テキスト

この文書は、次のチャットが過去ログを読まずに開発を再開するための正本引き継ぎ。実装判断では必ず **GitHub `48wr9f4wgp-lab/farm-loop` の `main` 最新コードを最優先**し、この文書とコードが矛盾した場合はコードを採用する。プロジェクト全体では `GAME_DEV_MASTER_RULES` をCanonical Ruleとして扱う。

## 1. アプリの目的・完成形

**Farm Loop** は、南魚沼・雪国の里山をモチーフにしたモバイル向けCozy Management Game。

現在のPositioning：
> **雪国の里山を循環させて育てる、Cozy Management Game。**

プレイヤー体験の核：
- 鶏 → 鶏糞 → 堆肥 → 山菜
- 山仕事 → 山の恵み・珍品
- 原木きのこ / 蜂 / 受粉 / 加工
- 村人の依頼と関係性
- 販売と販路選択
- 月・季節の進行
- 里山ランク / 土地の成長

差別化5本柱：
1. 雪国・里山
2. 循環生態系
3. 山仕事
4. 村人との関係
5. 次の月・季節を見たくなる期待

商業判断は現在 **CONDITIONAL GO（内部32/50）**。まだFull GOではない。外部10〜20人のProof-of-Funを通すまで大量コンテンツ追加は禁止。

完成形は「Hay Day/Townshipの縮小コピー」ではなく、**日本の雪国里山 × 循環 × 山仕事 × 村 × 四季**に絞った小〜中規模Premium寄りゲーム。初期収益化仮説は買い切り＋将来の大型Expansion/DLC。価格は未確定。

## 2. 使用技術・主要ライブラリ・外部サービス

### Runtime
- Godot **4.7.2 stable**
- GDScript
- Renderer: `gl_compatibility`
- Portrait mobile baseline: viewport `390x844`
- Stretch: `canvas_items + expand`
- Main scene: `res://main.tscn`

### Web / iPhoneテスト
- Godot Web export
- GitHub Pages
- Live URL: `https://48wr9f4wgp-lab.github.io/farm-loop/`
- iPhone Safari → ホーム画面追加を日常実機テスト入口として使用
- `viewport-fit=cover` + full-screen Canvas CSSあり
- `progressive_web_app/enabled=false`。GodotのService Worker型PWAではなく、Apple mobile-web-app metaを使ったホーム画面Webアプリ運用。テスト名の「PWA」は歴史的名称。

### CI/CD
`.github/workflows/mobile-web.yml`
- `actions/checkout@v4`
- `actions/github-script@v8`
- `chickensoft-games/setup-godot@v2`
- `actions/upload-artifact@v4`
- `actions/configure-pages@v5`
- `actions/upload-pages-artifact@v4`
- `actions/deploy-pages@v4`
- Python `fonttools` + `brotli` をCI時のみ利用
- NotoSansJPをCIで取得し、日本語UI用WOFF2 subsetを生成

Vercelは使用していない。

## 3. 現在の主要な構成・重要ファイル

### 起動
- `project.godot`
  - `config/name="Farm Loop"`
  - main scene=`main.tscn`
- `main.tscn`
  - `scripts/ui/main_v16.gd` を直接ロード

### Current runtime
- `scripts/ui/main_v16.gd`
  - 現在のアクティブRuntime Controller
  - 旧versionごとの `_ready()` 連鎖は **実行時にバイパス**し、CurrentRules / Save / Shell / SFX / Current Screenを1回だけ初期化
  - ただしソース上は `main_v15.gd` を継承しており、共有helper/callback/rollback用途で旧チェーンはまだ存在する
- `scripts/core/game_rules_current.gd`
  - 現在のDomain正本
  - 旧 `GameRulesV05/V06/V07/V12/V13/V14` の現行挙動を統合済み
- `scripts/core/game_rules.gd`
  - Base Rules
- `scripts/core/game_state.gd`
  - schema v4初期状態
- `scripts/core/ftue_service.gd`
  - Vertical Slice 2.0 / FTUE V2（9段階）
- `scripts/core/save_service.gd`
  - checksum / temp / backup / migration / slot分離
- `scripts/core/game_data.gd`
  - `data/*.json` 読込

### Screen分離済み
- `scripts/ui/screens/farm_screen.gd`
- `scripts/ui/screens/work_screen.gd`
- `scripts/ui/screens/market_screen.gd`
- `scripts/ui/screens/village_screen.gd`

### Map / Art / Motion
- `scripts/ui/farm_map_v09.gd`
- `scripts/ui/product_map_overlay_v09.gd`
- `scripts/ui/farm_polish_overlay_v15.gd`
- `scripts/ui/facility_action_overlay_v16.gd`
- `assets/art/coop_v08.svg`
- `assets/art/compost_v08.svg`
- `assets/art/mushroom_v08.svg`
- `assets/art/sansai_v08.svg`
- `assets/art/bee_v08.svg`
- `assets/art/player_v08.svg`

### Audio
- `scripts/audio/sfx_player.gd`
  - 3 voice
  - Runtime生成AudioStreamWAV
  - collect/work/loop/sell/mission/major/hazard/month等を音質差分
  - 本物のBGM/環境音素材はまだ未実装

### Data-driven tables
- `data/products.json`
- `data/facilities.json`
- `data/channels.json`
- `data/requests.json`
- `data/villagers.json`
- `data/recipes.json`
- `data/projects.json`
- `data/sansai.json`
- `data/seasons.json`
- `data/milestones.json`

### 開発/商品判断資料
- `docs/COMMERCIAL_PROOF_GATE_2026_08.md`
- `docs/COMMERCIAL_PROOF_SIGNAL_PASS_2026_08_24.md`
- `docs/VERTICAL_SLICE_2_PROOF_OF_FUN.md`
- `docs/ARCHITECTURE_CONSOLIDATION_PLAN.md`
- `docs/ARCHITECTURE_DEPENDENCY_MAP_B1.md`
- `docs/B2_BASELINE_CONTRACT_AUDIT.md`
- `docs/ART_BIBLE_v0_4.md`

## 4. 実装済み機能

### Core loop / progression
- 鶏舎：卵＋鶏糞回収
- 落ち葉・籾殻採集
- 堆肥仕込み → 月送りで完成
- 完成堆肥を山菜区画へ還元
- 季節山菜の収穫
- 原木きのこ
- 蜂・採蜜・受粉
- 加工レシピ
- 販売 / 販路 / 価格倍率 / 手数料
- 収穫かご一括販売
- 農場Lv / XP / 評判 / 循環スコア
- 設備強化
- 里山整備プロジェクト
- 月 / 年 / 季節 / 天候
- 雪・熊・スズメバチ・防疫等のリスク
- 村人関係値 / 関係ランク
- 村の依頼
- 里山図鑑 / 発見
- 里山ランク / prosperity XP
- 里山手帳（日課）
- 循環チェイン

### 山仕事
3ルート選択：
- 沢沿い：採集量寄り
- ブナ林：バランス＋珍品寄り
- 尾根：珍品率最大、収量控えめ

全ルートで進行可能。ハズレ道・Energy制なし。

### UI/UX
Bottom tabs：農場 / 仕事 / 販売 / 村
- 農場：マップ＋施設クイックアクション
- 仕事：山道3択 / 山仕事 / 加工 / 成長 / 整備
- 販売：予想手取り / おすすめ販路 / 販路比較 / 一括出荷
- 村：今日の依頼 / 人物 / 関係 / 図鑑 / 設定
- YUKISATO / FARM LOOP branding
- facility motion / avatar movement / footstep guide / ready markers
- feedback overlay / reward tokens
- Sound / Haptics / Reduced Motion

### Save
- schema_version=4
- checksum
- temp write → verify → atomic rename
- previous save backup
- checksum failure時backup fallback
- v1→v4 migration
- release metadataをmigrationで勝手に古い値へ上書きしない

Save slots：
- `main` → `user://farm_loop_save.json`
- `ftue_test` → `user://farm_loop_ftue_test_save.json`

FTUE実機テストは通常セーブを壊さない独立slotで実行できる。

### Analytics（ローカル）
state内イベント配列に記録。
実装済み主イベント：
- `session_start`
- `ftue_step_started`
- `ftue_step_completed`
- `first_facility_action`
- `farm_harvest`
- `material_gather`
- `compost_create`
- `month_advance`
- `compost_use`
- `sansai_harvest`
- `mountain_route_selected`
- `mountain_result`
- `village_request_viewed`
- `market_channel_selected`
- `market_sell`
- `ftue_complete`
- `full_loop_complete`

外部Analytics送信は未実装。

### CI Hard Gates
現在CIで以下を通す：
- Import / Parse
- Japanese font
- Core loop
- Save + migration B2
- GameRules Current B3 equivalence
- Current runtime B5
- Vertical Slice FTUE V2
- v0.5〜v1.6回帰
- iPhone Web UI契約
- Boot/UI smoke
- Web export
- build manifest
- artifact
- GitHub Pages deploy

## 5. 現在実装中の機能と進捗

### 現在の主作業：Proof-of-Fun Vertical Slice 2.0
**コード実装と自動テストは通過済み。次は物理iPhoneでのfresh FTUE実機検証。**

FTUE V2は9段階：
1. 鶏舎 → 卵と鶏糞
2. 仕事 → 落ち葉・籾殻
3. 堆肥舎 → 堆肥仕込み
4. 今月を終える → 発酵完成
5. 山菜区画 → 堆肥還元
6. 山菜収穫
7. 仕事 → 沢沿い / ブナ林 / 尾根から山道選択
8. 村 → 今日のお願いを見る（納品は必須にしない）
9. 販売 → 販路比較 → 収穫かご一括出荷

完了後は自由プレイ。

安全策：
- FTUE中は関係ない施設actionを無効化して資源の先食いを防ぐ
- FTUE中の単品販売は禁止、一括出荷でPayoffを作る
- 早売りによる循環素材枯渇を防ぐ
- Village beatは「誰のために作るか」を理解するだけで進行
- starter依頼 `mio_eggs` を保証し、ラベルは「朝市の卵（雪国鶏舎で回収）」
- request hintも「入手先：農場の雪国鶏舎」を表示
- Recovery reconcileは起動/Load時のみ使い、live action中のstep飛ばしを防止
- 旧tutorial_stepをFTUE V2へ安全mapping

最新 `tests/test_ftue_v2.gd` は**実際の `GameRulesCurrent` を使って9段階を最初から最後まで通す**。疑似成功resultだけのテストではない。

### 実機テスト機能
Free playの村タブ下部「開発テスト」から：
- `初回体験を最初から試す`
- `初回体験を最初からやり直す`
- `通常セーブへ戻る`

`ftue_test` slotに分離されるため、本セーブは維持される。

## 6. 未実装機能・今後やること（優先順）

### P0 — 直ちにやる
1. **iPhoneホーム画面版でFTUE V2をfresh状態から実機完走**
2. 9 beatのUI/CTA/文字切れ/スクロール/タッチ/黒帯/音/演出を実機監査
3. `ftue_test`と`main`のslot切替で通常セーブが保持されることを実機確認
4. FTUE終了後に自発的にもう1ヶ月進めたくなるReturn Triggerを監査
5. 発見した blocker / confusion を修正しCI→Pages→再実機

### P1 — Vertical Slice品質
6. Slice-critical artを最終商品に近い品質へ上げる
7. BGM / 環境音（風、水、鶏、蜂、雪の静けさ等）を実装
8. 月/季節transitionを明確化
9. harvest / compost / sell / missionのGame FeelをTier目標まで引上げ
10. 初回15分で「雪国・循環・山・村・季節」の少なくとも2つが自発認識されるか確認

### P1 — Analytics / Alpha準備
11. `session_end` 明示イベント
12. `village_request_completed` 明示イベント（現状はbase feedbackの`mission`系で代替され得るが、Vertical Slice仕様上の専用名は未整備）
13. 外部テスト用First-party telemetry収集方法を決める
    - 外部Analytics SaaS導入は外部契約/データ送信になるためユーザー承認が必要
    - 承認前はローカル集計/エクスポート方式で進めてもよい
14. 外部10〜20人テスト
15. Qualitative + funnelでGO / RE-SCOPE / KILL判定

### P2 — Gate通過後のみ
16. Retention / Progression tuning
17. 四季・土地成長・設備成長・村人arc・図鑑の拡張
18. 本格Visual Pass
19. Performance / Accessibility / QA
20. Native iOS build / signing / device matrix
21. Store assets / ASO / privacy / RC
22. App Store申請（明示承認必須）

## 7. 現在のバグ・技術的課題

### 現時点で既知のRelease Blocker
- **自動テスト上の既知blockerなし。最新実装baselineのCIは全SUCCESS。**

### 未確認 / 技術負債
- 最新FTUE V2は**物理iPhoneでfresh完走未確認**。CI成功≠実機成功。
- `main_v16.gd` はactive bootを一本化済みだが、まだ `main_v15.gd` を継承して共有helperを利用している。旧 `main_vXX` を一括削除しないこと。
- `state["version"]` は現在 `godot-1.6-motion-audio` のままで、Vertical Slice 2.0の製品バージョン表記としては古い。今すぐ機能阻害はしない。
- `README.md` は `v0.3.2` 表記で古い。コード正本ではない。
- audioはRuntime生成SFXのみ。本番BGM/ambience未実装。
- artは専用SVGまで進んだが、全体として最終商用品質ではない。
- analyticsはlocal stateのみ。外部cohort分析不可。
- Godot Web presetはPWA無効。Service Worker/offline installable PWAではない。
- `main` branchは現在GitHub上でprotectedではない。

### 注意
HTTP 200 / CI successだけで「iPhoneで直った」「完成」と言わない。物理iPhoneの実動作を別Gateとして扱う。

## 8. 重要な設計判断と理由

### Godotを本体正本にした
旧Web単一HTML系は仕様/prototype参考のみ。人気ゲーム級の商品品質へ上げるため、ゲーム本体はGodot。

### Smartphone-first CI
PCを日常開発フローから外し、GitHub Actions → Web export → Pages → iPhoneホーム画面テストにした。ユーザーがPCを手元に持たない時間が長いため。

### CurrentRules統合
旧Rules多段継承は開発速度には効いたが商品化で危険だったため、`GameRulesCurrent`へ統合。旧V14とのseed固定同値テストを通してからactive runtimeを切替えた。

### Screen分離
Farm / Work / Market / Villageを独立Screenへ抽出。UI version chainの巨大化防止。

### Runtime boot一本化
`main_v16._ready()`で旧versionの`super._ready()`連鎖を通さず、Current runtimeを1回だけ初期化。旧Rules差替え・多重画面構築を防ぐ。

### Premium仮説
Farm Loopの価値はFOMO課金ではなく、世界・循環・季節・里山体験。小規模チームでTownship級LiveOpsを背負わないため。

### Batch sale
単品売り反復を減らし、Decision + Payoffを一回で強くするため。

### 山道3択は全て正解
知識クイズ/詰みを作らず、好みとTrade-offだけを残すため。

### FTUEでは納品を必須にしない
Village beatの目的は「生産に人間的な意味がある」と理解させること。依頼素材不足で初回体験を止めないため。

### FTUE test slotを分離
通常セーブを破壊せず、何度でも初回体験を検証するため。

## 9. 過去に却下した案・やってはいけない変更

- 巨大single-file HTMLへ戻さない
- 「スマホしかない」だけを理由に本番ゲームをWeb技術へ固定しない
- PC Godot/ZIP/.batを通常テスト導線に戻さない
- Farm LoopをHay Day/Townshipの模倣へ寄せない
- Township級LiveOpsを目指さない
- Energy / staminaをcore actionに入れない
- forced ads / gacha / battle pass / high-frequency FOMOイベントを初期版へ入れない
- 強制待ち時間でFTUEを引き延ばさない
- 単品反復作業を増やさない
- 資源を売ると何もできなくなるdeadlockを作らない
- 旧main_vXX / RulesVXXを「古いから」という理由だけで一括削除しない。rollback/test参照が残るため、削除は依存確認後
- CurrentRulesにbalance変更を混ぜながらlegacy equivalence testを書き換えない
- 外部テスト前に作物/施設/通貨等のscopeを増やさない
- CI未通過の変更を完成扱いしない
- CI通過だけで実機完成扱いしない
- `ftue_test`検証のためにmain saveを削除/初期化しない

## 10. UI/UXの方針

- Mobile portrait-first
- 390x844 logical baseline、縦長iPhoneはexpand
- 一目で次の行動が分かることを最優先
- Readability → Operability → Visual appeal
- 主CTAは原則50px以上
- Bottom navはスマホタップ領域を確保
- Farm mapはheroとして最低約385pxを維持
- FTUEは一度に1 primary objective
- modal説明壁ではなく行動で教える
- FTUE中は管理情報を隠す/弱める
- FTUE中でも不要な全面Tabロックは避ける。ただし資源破壊/進行不能を防ぐaction lockは許可
- feedback loop：input → acknowledgement → result → audio/haptic → reward recognition → next cue
- Reduced Motionを尊重
- Apple safe-area / viewport coverを考慮
- UIだけ豪華にするのでなく、マップ・施設・キャラが視覚的主役

## 11. DB・API・認証・環境変数など

### DB
なし。Backend DBなし。

### Save
Godot `user://` のJSON envelope。
- main: `farm_loop_save.json`
- backup: `farm_loop_save.backup.json`
- temp: `farm_loop_save.tmp.json`
- ftue_testは同名prefixで完全分離

### API
Runtimeで外部APIなし。

### 認証
なし。Single-player / local save。

### Analytics backend
なし。イベントはsave state内のlocal analyticsのみ。

### 環境変数
CIで `GODOT_VERSION=4.7.2`。
API key / production secretなし。
GitHub ActionsはGitHub提供tokenをworkflow権限内で使用。

### Hosting
GitHub Pages。Vercel未使用。

### Repo
Public repository: `48wr9f4wgp-lab/farm-loop`

## 12. 次に着手すべき具体的タスク

**最優先は新機能追加ではなく、Vertical Slice 2.0の物理iPhone検証。**

次チャット開始直後に：
1. GitHub `main` HEADと最新Actions statusを再取得
2. `HANDOFF.md` / `main_v16.gd` / `ftue_service.gd` / 4 Screens / `test_ftue_v2.gd` を再確認
3. 最新CIが緑なら、ユーザーへホーム画面版を完全終了→再起動してもらう
4. 通常セーブの村タブ → 「開発テスト」→ **「初回体験を最初から試す」**
5. 以下を順に実機完走：
   - 鶏舎
   - 仕事で落ち葉/籾殻
   - 堆肥舎
   - 今月を終える
   - 山菜区画へ堆肥還元
   - 山菜収穫
   - 山道3択
   - 村の依頼を見る
   - 販路比較＋一括出荷
6. 各beatで迷い/文字切れ/CTA不可視/黒帯/音/演出/進行不能を監査
7. FTUE完了後、村→開発テスト→通常セーブへ戻り、本セーブが保持されていることを確認
8. 問題があれば最小修正 → GitHub CI全回帰 → Pages → 同一iPhoneで再確認
9. 実機FTUEが通ったらSlice-critical Art/Audio/Game Feel改善
10. その後External Alpha 10〜20人へ進む

外部Analyticsサービス契約、Store申請、課金開始、費用発生はユーザー明示承認なしに実行しない。

## 13. 現在のブランチ名・最新コミット・作業状態

### Canonical branch
`main`

### この引き継ぎ作成時点の検証済み実装baseline
`67d7be2dd4dafc4641a38fc2acb15b8304dd62f3`
Commit message:
`Vertical Slice 2: test village hero at the intended guided beat`

### 最新検証済みGitHub Actions
Run ID: `32841049376`
結果：
- build-test: SUCCESS
- Vertical Slice FTUE v2 contract: SUCCESS
- 既存全回帰: SUCCESS
- Boot/UI: SUCCESS
- Web Export: SUCCESS
- deploy-pages: SUCCESS

したがって、`67d7be2...` の実装はCI/Pagesまで検証済み。

### 作業状態
- Vertical Slice 2.0のコード + 自動回帰は一旦green
- 次は物理iPhone fresh FTUE実機検証
- 外部alpha未開始
- Full GO未判定
- GitHub上で確認できる範囲では、実装baselineに未コミット差分なし
- ユーザーのローカルclone有無/未コミット状態は未確認だが、通常運用はGitHub-firstでローカルPCを正本にしていない

### 注意：このHANDOFF.md自体
このファイル追加はdocumentation-only commitを1つ作るため、**次チャットでは必ず`main`の最新HEADを再取得し、上記67d7be2を「最新実装baseline」として扱ったうえでdocs-only差分の有無を確認すること。**

### 非Canonical branchについて
引き継ぎ作業中に `handoff-temp` / `handoff-temp2` branchが作成されている可能性がある。**開発正本は必ず`main`。これらは使用しない。** 削除可能なら後で削除してよいが、削除のためにmainを変更しない。
