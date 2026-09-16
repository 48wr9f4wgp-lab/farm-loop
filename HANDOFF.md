【アプリ名：Farm Loop】

# Farm Loop 開発引き継ぎ書 — Product Reset v4

更新日：2026-09-16 JST

この文書だけで次チャットから開発を再開できるようにする。実装判断では **GitHub `48wr9f4wgp-lab/farm-loop` の `main` 最新コードを最優先**する。プロジェクト全体では `ゲーム開発共通ルール_v1.7` / GAME_DEV_MASTER_RULES v1.7 をCanonical Ruleとして適用する。

---

## 1. 現在の判断

Farm Loopは継続。ただし、2026-09-16に旧Restore Loopを**ゲームとして弱い**と判断し、Core Loopを再設計した。

Current decision:

- Theme/IP: KEEP
- 3D Diorama: KEEP
- old CTA-driven Restore Loop: KILL
- new Core Loop: ADOPT

新しい商品方向：

> **雪国の里山を、限られた手数で手入れし、循環の連鎖を組み上げて蘇らせる Cozy Restoration Puzzle / Management Game。**

Canonical product docs:

- `docs/PRODUCT_RESET_V4_2026_09_16.md`
- `docs/GDD_V4_CIRCULATION_PUZZLE.md`
- `docs/VERTICAL_SLICE_4_CIRCULATION_PUZZLE.md`

旧 `PRODUCT_RESET_V3` / `VERTICAL_SLICE_3_ALPHA_RC` / FTUE V3は履歴・rollback用。新規商品判断の正本には使わない。

---

## 2. 新Core Loop

各月3 Action Points。

1. 里山の状態を見る
2. Interventionを選ぶ
3. 適用するZoneを選ぶ
4. 直接効果＋予測ChainをPreview
5. 1 AP消費してCommit
6. 最大3回まで手入れ
7. `今月を終える`
8. 水→土→植物→虫/生き物などのChainが一斉解決
9. Recovery / 景観 / Harvest opportunityが変化
10. 次月の改善を考える

`今月を終える`は待ち時間ではなく**答え合わせボタン**。

---

## 3. Vertical Slice 4

Proof target:

> 新規プレイヤーが少なくとも2回意味のある選択をし、月送り後の生態連鎖を理解し、別の順番/手を試すために次月へ進みたくなる。

Initial Zones:

- Sansai Patch
- Stream Bank
- Meadow Edge
- Coop Yard
- Forest Edge optional

Initial Interventions:

- Compost
- Restore Stream
- Plant Flowering Shrub
- Deadwood / Mushroom Log optional after proof

No visible square grid. Internallyは小さなGraphとして扱う。

---

## 4. Success Definition

### Repeat
毎月、限られた手数をどこへ使うか選び、相乗効果を組む。

### Delight
月末に自分の選択が複数の景観変化として連鎖する。

### Progress
里山のZoneが回復し、新しい生態関係と景観が開く。

### Return
次月/次季節に計画したChainがどう育つか見たい。

### Revenue
Premium base game + optional major-region expansion/DLC hypothesis. No forced ads/gacha/battle pass/FOMO.

### Convention
Touchで分かる、Previewが明快、Commit前は戻せる、短時間、低ストレス。

### Differentiation
日本の雪国里山 + 生態連鎖パズル + 月3手 + 3Dで見える再生。

---

## 5. Market Check 2026-09-16

Current adjacent references:

- ISLANDERS: Mobile — minimalist mobile adjacency puzzle
- Terra Nil — restoration itself as objective/reward
- Preserve — ecosystem symbiosis as puzzle rule
- Dorfromantik — calm placement strategy + board evolution
- ISLANDERS: New Shores — small-rule 3D strategy / strong visual world-building

1作品を模倣せず、抽象原理だけ採用する。

---

## 6. Technology

Keep Godot 4.7.2.

Reason:
- existing 3D diorama / input / save / Web/iPhone test pipeline is useful
- new system is graph/state driven
- engine migration does not solve the product problem

New V4 architecture should be cleanly separated from V3 FTUE inheritance chains.

Suggested modules:

- `scripts/core/circulation_rules_v4.gd`
- V4 board state helper
- `scripts/ui/circulation_board_v4.gd`
- `scripts/ui/screens/farm_screen_v4_puzzle.gd`
- `tests/test_circulation_rules_v4.gd`
- `tests/test_ftue_v4.gd`

Do not dump V4 logic into `main_v30.gd` / `farm_diorama_v15.gd`.

---

## 7. Current Runtime Before V4 Migration

Current deployed implementation is still the old proof runtime:

`main.tscn`
→ `scripts/ui/main_v30.gd`
→ `FarmScreenV15`
→ `FarmDioramaV15`

This runtime is functional but **not the adopted product Core Loop**.

Keep it as a rollback/baseline while Vertical Slice 4 is built incrementally.

Do not call the project Alpha-ready until V4 replaces the proof flow and passes physical-device testing.

---

## 8. V4 Development Order

1. Rules-only deterministic simulation
2. Save / migration block `circulation_v4`
3. World Zone selection
4. Intervention tray
5. Chain preview
6. Month resolution
7. FTUE V4 with two valid opening routes
8. Game Feel / Audio / Haptic
9. Regression
10. Web Export / Pages
11. Physical iPhone two-month proof

No visual-only polishing detour before the new interaction loop works.

---

## 9. FTUE V4 Principle

Tutorial teaches by choice.

Opening prompt:

> **最初にどこから手を入れる？**

At minimum allow two valid choices:

- Compost -> Sansai
- Restore Stream -> Stream

Both orders must succeed and produce understandable but different outcomes.

Player gets 3 AP, then advances the month. Month-end resolution must explain itself visually.

FTUE ends at Month 2 start.

---

## 10. Proof Metrics

Directional targets:

- first meaningful choice <= 45 sec median
- >=80% understand `3 actions -> month end -> chain`
- >=70% complete FTUE V4 without explanation
- >=60% voluntarily start Month 2
- >=50% try a different intervention/order in Month 2
- blocker = 0%

Qualitative failure signal:

> `ただボタンを押しているだけ`

If this remains common, redesign rules again instead of adding content.

---

## 11. Scope Cut Until V4 Proof

Do not expand:

- market selling
- village relationship system
- mountain route system
- large crafting
- multiple currencies
- facility catalog
- hazards
- collection depth
- story volume
- LiveOps
- monetization implementation

Legacy code may remain temporarily for rollback and dependency safety.

---

## 12. Visual Direction

Keep the current practical 3D target only as presentation baseline:

- portrait
- fixed orthographic 3D diorama
- snow-country satoyama
- clear water / soil / vegetation state
- no visible grid
- zone selection visible
- world larger than instruction UI

The next visual work must serve V4 gameplay readability, not decoration for its own sake.

---

## 13. Save / Safety

Do not destroy current save.

New V4 state should be introduced as a separate block, e.g.:

```text
state["circulation_v4"] = {
  board_version,
  action_points,
  zones,
  unlocked_interventions,
  last_resolution
}
```

Legacy state remains until migration/regression is proven.

---

## 14. External / Irreversible Boundary

User explicit approval required before:

- External Alpha invitations/distribution
- App Store submission
- monetization launch
- external analytics transmission/service contract
- paid services
- public release expansion

Current next action is internal Vertical Slice 4 implementation only.

---

## 15. Next

Start `M1 — Rules-Only Simulation` from `docs/VERTICAL_SLICE_4_CIRCULATION_PUZZLE.md`.

Do not return to old FTUE visual polishing unless required to support the new puzzle.