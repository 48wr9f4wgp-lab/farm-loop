# Farm Loop / 雪里 — PRODUCTION_DECISION

Date: 2026-09-17 JST

## Decision

**KILL**

Farm Loop / 雪里の現企画は、ここで制作継続を停止する。

これは一時保留ではなく、現在の企画・Core Loop・Vertical Sliceを前提としたProductionを継続しないという判断。

## Reason

企画会議とV4再設計を経ても、ユーザー評価として「この企画自体をボツ」と判断された。

Visual polishや追加コンテンツで補強する段階ではなく、Product Fantasy / Core Experienceそのものを継続投資対象から外す。

## Scope

KILL対象：

- Farm Loop / 雪里の現ゲーム企画
- V4 Circulation Puzzle Core Loop
- Vertical Slice 4
- External Alpha準備
- 現企画を前提とした追加Visual / Content / FTUE開発

## Preserve

削除はしない。

以下はRecovery / Learning資産として保持する。

- GitHub repository / history
- Godot 3D diorama implementation
- Save / migration / Web / iPhone test pipeline
- procedural audio / haptic hooks
- app icon / branding assets
- market / product / architecture docs
- V3 / V4 test suites
- production lessons and failed hypotheses

## Frozen Baseline

最終確認済みWorking Head:

`d3277a65dc2436ecda797338cba4959f13e111d4`

At this head:

- Farm Loop V4 Core CI: SUCCESS
- Farm Loop Mobile Web CI: SUCCESS
- Web Export: SUCCESS
- GitHub Pages deploy: SUCCESS

このbaselineは完成品ではなく、**KILL時点の復旧可能な最終実装状態**として扱う。

## Release Boundary

- External Alpha: NOT STARTED
- App Store submission: NOT STARTED
- Monetization: NOT STARTED
- External analytics SaaS: NOT STARTED
- RELEASE_APPROVAL: NOT GRANTED

## Restart Rule

Farm Loop / 雪里を再開する場合、旧Core Loopの続きをそのまま再開しない。

再開条件は、ユーザーによる明示的な新企画採用と、新しいContext Lock / Core Loop / Success Definitionの再設定。

それまではこのrepoへの機能追加を行わない。
