【アプリ名：Farm Loop / 雪里】

# Farm Loop 引き継ぎ書 — KILL / FROZEN

更新日：2026-09-17 JST

## 1. PRODUCTION_DECISION

**KILL**

Farm Loop / 雪里の現企画は制作継続を停止した。

これは一時保留ではなく、現在の企画・Core Loop・Vertical Sliceを前提としたProductionを継続しないという判断。

正本：
- `docs/PRODUCTION_DECISION_KILL_2026_09_17.md`

## 2. 開発状態

新規機能追加・Visual polish・FTUE改善・External Alpha準備を停止する。

旧V3 Restore Loop、V4 Circulation Puzzleのどちらにも戻らない。

再開する場合は、ユーザーが新企画を明示採用したうえで、Context Lock / Core Loop / Success Definitionから新規にやり直す。

## 3. 保持するもの

削除しない。

- GitHub repository / commit history
- Godot実装
- 3D里山ジオラマ
- Save / migration
- Web Export / GitHub Pages pipeline
- iPhone向けUI / Safe Area知見
- procedural audio / haptic hooks
- app icon / branding
- V3 / V4 docs / tests
- 企画失敗から得たLearning

これらは次企画の再利用候補だが、タイトル固有仕様を自動で横展開しない。

## 4. Frozen Baseline

KILL判断直前の最終確認済み実装HEAD：

`d3277a65dc2436ecda797338cba4959f13e111d4`

その時点で：

- Farm Loop V4 Core CI: SUCCESS
- Farm Loop Mobile Web CI: SUCCESS
- Web Export: SUCCESS
- GitHub Pages deploy: SUCCESS

このHEADは完成品ではない。
**KILL時点の復旧可能な最終実装状態**として扱う。

KILL判断記録コミット以降はdocumentation-only。

## 5. Release状態

- External Alpha: 未開始
- App Store申請: 未開始
- 課金: 未開始
- 外部Analytics SaaS: 未導入
- RELEASE_APPROVAL: なし

公開・申請・契約・費用・課金開始・データ破壊は行わない。

## 6. 過去企画

履歴としてのみ保持：

- V3 Restore Loop
- V4 Circulation Puzzle
- Vertical Slice 3 / 4
- FTUE V2 / V3
- External Alpha readiness docs

これらは現在のActive Product Specではない。

## 7. 次にFarm Loopを触る場合

ユーザーから明示的な再開指示がない限り、実装を続けない。

再開指示が出た場合も、まず「何を残すか」を決め、旧Core Loopの続きを自動再開しない。
