【アプリ名：Farm Loop】

# Farm Loop 開発引き継ぎ書 — External Alpha RC

更新日：2026-09-16 JST

この文書だけで次チャットから開発を再開できるようにする。実装判断では必ず **GitHub `48wr9f4wgp-lab/farm-loop` の `main` 最新コードを最優先**する。この文書とコードが矛盾した場合はGitHub上の実コードを正とする。プロジェクト全体では `GAME_DEV_MASTER_RULES` をCanonical Ruleとして適用する。

---

## 1. 現在の判断

Farm Loop は **採用継続**。

現在は新機能を増やす段階ではなく、**External Alpha開始直前のRelease Candidate（Alpha RC）**。

ただし、物理iPhoneで最新版のfresh FTUEを完走する最終Hard Gateはまだ未確認。この実機Gateを通すまでは外部10〜20人テストを開始しない。

商業判断は引き続き **CONDITIONAL GO**。External Alphaの結果で以下を正式判定する。

- FULL GO
- RE-SCOPE
- KILL / PIVOT

一般公開、App Store申請、課金開始、外部Analytics SaaS契約、費用発生はユーザー明示承認なしに行わない。

---

## 2. Product Vision

Farm Loop は、雪国・里山を舞台にしたモバイル向け Cozy Management Game。

Positioning：

> **雪国の里山を循環させて育てる、Cozy Management Game。**

現在の最重要Product Fantasy：

> **荒れた雪国の里山へ人の手と循環を戻し、土地が目に見えて蘇る景色を育てる。**

差別化の核：

1. 雪国・里山
2. 循環生態系
3. 山仕事
4. 村との関係
5. 月・季節を進めたくなる期待

Hay Day / Townshipの縮小コピーにはしない。大量コンテンツ量ではなく、

- 触った瞬間の気持ちよさ
- 次の行動の明確さ
- 土地が蘇る視覚的Payoff
- 次の月を見たくなる理由

を優先する。

---

## 3. Canonical Visual Direction

旧2D Farm Mapを商品完成形にはしない。

現在の正本Visual Direction：

- Portrait mobile-first
- Stylized 3D
- 固定斜め見下ろし
- Orthographic Camera
- 小さな立体ジオラマ
- 日本の雪国里山
- 柔らかい自然光
- muted sage / ivory / forest green / earth tone
- Cozyだが幼すぎないPremium UI

完成系の価値は、UIカードではなく**農場・地形・沢・植生・季節・生命の変化**で出す。

新アプリアイコンもこの方向で統一済み。

Art Target：
- `docs/ART_TARGET_3D_VERTICAL_SLICE.md`

---

## 4. 現在のRuntime

### Engine

- Godot 4.7.2 stable
- GDScript
- Renderer: `gl_compatibility`
- Logical viewport: `390 x 844`
- Stretch: `canvas_items + expand`
- Portrait mobile-first
- Main Scene: `res://main.tscn`

### Current Runtime Chain

`main.tscn`
→ `scripts/ui/main_v29.gd`
→ `scripts/ui/screens/farm_screen_v14.gd`
→ `scripts/ui/farm_diorama_v14.gd`

Current domain rules：
- `scripts/core/game_rules_current.gd`

Current FTUE：
- `scripts/core/ftue_service_v3.gd`

Save：
- `scripts/core/save_service.gd`
- schema_version = 4

重要：

旧 `main_vXX` / `farm_diorama_vXX` / `GameRulesVXX` はshared helper、rollback、contract test参照が残っているため、古いという理由だけで一括削除しない。

---

## 5. Current Proof Loop — FTUE V3 / 6 Steps

現在のProof-of-Fun FTUEは6段階。

### Step 1 — 鶏舎

雪国鶏舎で卵と鶏糞を回収。

### Step 2 — 循環資材

仕事タブで落ち葉・籾殻を集める。

### Step 3 — 堆肥舎

鶏糞＋落ち葉を使って堆肥を仕込む。

### Step 4 — 月送り

`今月を終える` 専用CTAで月を進め、堆肥を完成させる。

### Step 5 — 土へ還す

山菜区画へ完成堆肥を還す。

ここがFarm Loopの最重要Payoff Beat。

### Step 6 — 山菜収穫

回復した区画から旬の山菜を収穫し、最初のRestore Loopを完成させる。

現在のProof Loopでは、旧Vertical Slice 2の山道・村・販売Beatを必須導線から外している。まず**循環→回復**が単独で面白いかを証明する。

---

## 6. Guided UXのCurrent Rules

FTUE中は一度にprimary objectiveを1つだけ出す。

- Step 1：鶏舎のみ3Dフォーカス＋操作可能
- Step 3：堆肥舎のみ3Dフォーカス＋操作可能
- Step 5〜6：山菜区画を3Dフォーカス
- 関係ない施設は見えるが、進行上危険なタップは無効
- Guided中は3D Hero高さを約400〜420pxに制限
- 早いStepでは不要な「里山の回復」カードを隠す
- Safe AreaとBottom Navを侵食しない
- 主CTAとObjectiveと実際の操作対象を一致させる
- Energyなし
- 強制待ちなし
- 資源枯渇による進行停止なし

FTUE testは通常Saveと分離する。

Main：
- `user://farm_loop_save.json`

FTUE test：
- `user://farm_loop_ftue_test_save.json`

通常saveをFTUE検証のために削除しない。

---

## 7. 3D Alpha RC Visual

Current renderer：
- `scripts/ui/farm_diorama_v14.gd`
- visual_pass = 12
- visual_target_id = `satoyama-premium-2026-09-16-alpha-rc`

実装済み主要素：

- 浮島状の里山地形
- 雪山背景
- 森ライン
- 沢
- 道
- 雪国鶏舎
- 堆肥舎
- 山菜区画
- 原木きのこ
- 養蜂箱
- 春植生
- 石 / 草 / 花 / 生活小物
- 水面の微動
- Guided world-space focus
- 他Ready marker抑制
- Reduced Motion対応

### Restoration Payoff

山菜区画は最低3状態を視覚的に区別する。

- 荒地
- 回復中
- 繁茂

V14ではAlpha用Payoffを追加。

- 植生密度増加
- 花
- 生命mote
- 花びら
- 戻ってくる鳥の小さなシルエット
- living soilの色差

目的は装飾量ではなく、**「自分の行動で里山が蘇った」ことをスマホ画面で即認識できること**。

---

## 8. Audio / Game Feel

### SFX

`scripts/audio/sfx_player.gd`

Runtime生成AudioStreamWAVを使用。

主カテゴリ：
- collect
- work
- craft
- loop
- sell
- mission
- upgrade
- major
- hazard
- month
- season

### Ambience

Current：
- `scripts/audio/ambience_player.gd`

外部音源契約なしで、Alpha RCではprocedural ambienceを実装。

季節・天候に応じて以下を薄く生成：

- 風
- 沢
- 鳥
- 夏の蜂
- 秋の葉音
- 雪時の静けさ

Sound OFF時はAmbienceも停止。

本番商品化時には、外部テスト結果を見て録音素材/購入素材へ置換するか判断する。

### Haptics

既存 `_haptic()` を維持。
Restore Beat / FTUE completionで強弱を使い分ける。

---

## 9. Analytics — External Alpha準備

外部Analytics SaaSはまだ導入していない。

データは端末内：

`state["analytics"]["events"]`

へ記録。

Current主要イベント：

- `session_start`
- `session_end`
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
- `village_request_completed`
- `market_channel_selected`
- `market_sell`
- `ftue_complete`
- `full_loop_complete`
- `telemetry_exported`

### Local Export

村 → `Alpha テスト` → `テストデータをコピー`

で、外部送信せずにJSONをクリップボードへコピーする。

同時に：

`user://farm_loop_alpha_telemetry.json`

へ保存。

Schema：
- `farm_loop_alpha_telemetry_v1`

External Alpha前はこのlocal export方式を使う。外部SaaSへ送信する場合はユーザーの明示承認が必要。

---

## 10. App Icon

新しい正本アイコンへ差替え済み。

方向：

- cream rounded-square
- simple circular ecology loop
- leaf
- snow mountain
- field
- stream
- textなし
- 小サイズでも認識できるシンプル構成

Source asset：
- `assets/branding/farm_loop_app_icon_180.png.b64`

CIがWeb export時にapple-touch-icon / favicon / manifestへmaterializeする。

iOS側に旧アイコンcacheが残る場合は、ホーム画面から旧追加分を削除しSafariから再追加して確認する。

---

## 11. CI / Deployment

Workflow：
- `.github/workflows/mobile-web.yml`

Current Hard Gates：

- Import / Parse
- Japanese font
- Core Loop
- Save / migration
- GameRules Current equivalence
- Current runtime contract
- legacy FTUE v2 contract
- FTUE v3 restore contract
- 3D diorama / month gate contract
- External Alpha readiness contract
- legacy product regressions
- iPhone Web UI contract
- Work / Market / Village / Farm
- Motion / Audio
- Boot / UI
- Web Export
- App Icon install
- Manifest
- Artifact
- GitHub Pages

Live：
- `https://48wr9f4wgp-lab.github.io/farm-loop/`

CI SUCCESSは物理iPhone成功を意味しない。

---

## 12. 次のHard Gate

**External Alpha開始前に、物理iPhoneで最新版をfresh FTUE完走する。**

確認項目：

1. ホーム画面から完全終了→再起動
2. 新アイコン確認
3. 村 → 開発テスト → 初回体験を最初から試す
4. FTUE V3 1/6〜6/6を完走
5. 次に触る対象が1秒で分かる
6. CTAとObjectiveが一致
7. 関係ない施設へ誤移動しない
8. 文字切れ / 黒帯 / Safe Area / Bottom Nav重なりなし
9. Step 4月送りが止まらない
10. Step 5堆肥還元が止まらない
11. 回復前後の違いが明確
12. SFX / Ambience / Hapticが不快でない
13. Reduced Motionで不要Motionが止まる
14. FTUE完了後Free Playへ戻れる
15. 通常saveへ戻してmain saveが保持されている
16. `テストデータをコピー` が動く

このGateをPASSして初めてExternal Alpha開始候補。

---

## 13. External Alpha Gate

対象：10〜20人。

プロジェクトを知らない人を優先。

Current qualitative targets：

- >=70% がRestore Loopを自分の言葉で説明
- >=60% が差別化要素を2つ以上自発的に言及
  - 雪国
  - 里山
  - 循環
  - 土地再生
  - 季節
- >=60% が「もう1ヶ月 / 次の変化を見たい」
- >=30%に共通する重大navigation confusionを残さない

Behavioral directional targets：

- first meaningful action median <= 60秒
- FTUE Restore Loop completion >= 70%
- progression blocker = 0%

旧Vertical Slice 2の `mountain choice reach / market payoff reach / village purpose reach` はFTUE V3では必須Beatではないため、現在のProof Gate主要指標から外す。Full GO後に別途再評価する。

結果で：

- FULL GO
- RE-SCOPE
- KILL / PIVOT

を正式判定する。

---

## 14. External Alpha後、FULL GOの場合のみ

- Retention tuning
- Progression tuning
- 四季拡張
- 土地成長
- 設備成長
- Village arc
- 図鑑
- Content expansion
- 本格Audio assets
- Accessibility
- Performance
- QA
- Native iOS
- signing
- device matrix
- Store assets
- ASO
- privacy
- Release Candidate
- App Store申請

App Store公開、課金開始、外部サービス契約、費用発生はユーザー明示承認必須。

---

## 15. 禁止 / 再発防止

明確な再検討理由がない限り行わない。

- 旧2Dを商品正本へ戻す
- 巨大single-file HTMLへ戻す
- スマホしかないことを理由にWeb技術へ本番ゲームを固定
- PC Godot / ZIP / batを通常テスト導線にする
- External Alpha前に大量コンテンツ追加
- Energy / staminaでCore Loopを止める
- forced ads / gacha / battle pass / 高頻度FOMO
- FTUEに強制待ちを入れる
- 資源枯渇で何もできなくする
- 旧main_vXX / RulesVXXを一括削除
- CIだけで「iPhoneで直った」と断言
- HTTP 200だけでruntime正常扱い
- FTUE testのためmain saveを削除
- visual強調のためSafe Areaや画面端を犠牲にする
- 企画価値より機能数を優先する

---

## 16. 開発フロー

標準：

ChatGPT
→ GitHub main
→ GitHub Actions
→ Godot tests / Web Export
→ GitHub Pages
→ iPhoneホーム画面
→ 実機Feedback

変更後は可能な限り：

build → automated test → Web export → Pages → physical iPhone verify → regression

を行う。

未確認を完成済みと言わない。

---

## 17. 現在の停止地点

コード上のAlpha RC準備は完了方向。

**次の停止地点はExternal Alpha開始直前。**

物理iPhoneのfresh FTUEをユーザーが1回完走してPASS判定するまでは、外部ユーザーへの配布開始・外部Analytics導入・一般公開拡大をしない。
