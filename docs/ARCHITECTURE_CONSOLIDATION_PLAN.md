# Farm Loop — Architecture Consolidation Plan

Last updated: 2026-08-24
Status: READY FOR STAGED REFACTOR
Goal: remove version-chain architecture debt without changing gameplay behavior.

## 1. Current problem

The active entry point is `main_v16.gd`, which extends `main_v15.gd`, and recent feature layers continue backward through v14, v13, v12 and earlier `main_vXX` scripts.

This was useful for rapid productization, but it is no longer appropriate as the long-term product architecture.

Observed risks:
- initialization order depends on multiple `super._ready()` calls
- active rules are replaced by later layers
- screen builders are overridden in separate versions
- UI state can be rebuilt multiple times during boot
- behavior ownership is hard to locate
- tests may validate historical implementation assumptions instead of current product behavior
- future save/analytics/FTUE work would become harder to reason about

No current feature is considered invalid merely because it lives in a version layer. The objective is consolidation, not redesign.

---

## 2. Hard non-goals

During consolidation do NOT:
- add new gameplay features
- change economy values
- change progression requirements
- redesign the visual language
- remove existing player-facing functionality
- change save meaning without migration
- change current public URL/deployment workflow

---

## 3. Target ownership

### App shell
`MainController`
- boot
- state load
- tab navigation
- shared header/navigation
- commit/result orchestration

### Screens
`FarmScreen`
- farm map
- selected facility panel
- farm interaction presentation

`WorkScreen`
- route choice
- mountain work
- recipes
- facility upgrades/projects

`MarketScreen`
- channel selection
- basket preview
- batch sale presentation

`VillageScreen`
- village requests
- relationships
- codex/settings presentation

### Domain/services
`GameRules`
- canonical domain behavior
- no UI ownership

`SaveService`
- persistence only

`AudioService`
- SFX/music/ambience policy

`FeedbackService`
- visual reward feedback

`AnalyticsService`
- event emission adapter; no game rules

### Rendering
`FarmMap`
- world rendering/input

Farm overlays
- asset layer
- polish/target guidance
- facility action effects
- all input-transparent unless explicitly interactive

---

## 4. Staged migration

### B1 — Dependency map and behavior freeze
- document effective methods owned by main/v041/v05...v16
- identify active rule class
- freeze current tests as behavior baseline
- add a boot/version assertion for current product

Exit: no player-facing change.

### B2 — Extract screen builders
Move effective `_build_farm`, `_build_work`, `_build_market`, `_build_village` behavior into dedicated screen components/helpers.

Exit:
- all existing UI regression tests pass
- no save change
- screenshots should be visually equivalent

### B3 — Flatten main chain
Create a new single product entry controller that directly owns current effective behavior.

Historical `main_vXX` files remain temporarily for rollback/reference but are no longer in the runtime inheritance chain.

Exit:
- main scene points to flattened controller
- boot has a single rules initialization path
- no repeated screen construction during initialization
- all CI passes

### B4 — Consolidate rules chain
Only after UI/main flattening is stable:
- compare `game_rules.gd`, v05/v06/v07/v12/v13/v14
- merge effective behavior into one canonical rules implementation or a small explicit composition
- preserve data-driven tables

Exit:
- every existing domain regression passes
- route/market/village behavior matches current v1.6

### B5 — Retire historical runtime files
After two successful deployed builds + physical iPhone regression:
- move old runtime version scripts to archive or delete only if rollback history is safely preserved in Git
- rename tests by behavior/capability rather than version where practical

---

## 5. Acceptance criteria

Consolidation is complete only when:
- one active main controller path
- one explicit current GameRules path
- Farm/Work/Market/Village ownership is obvious
- Save/Audio/Feedback are services, not screen logic
- no boot-time rule swapping
- no duplicate first-screen construction
- all existing automated tests pass
- Web export succeeds
- GitHub Pages deployment succeeds
- physical iPhone PWA shows no visual/input regression

---

## 6. Rollback strategy

Every stage is a separate small commit.
Do not delete old version scripts until the flattened build has passed:
1. Godot parse/import
2. all regression tests
3. Web export
4. Pages deploy
5. physical iPhone smoke

If a stage fails, revert only that stage; do not repair by stacking another runtime version layer.

---

## 7. Commercial Proof relationship

Architecture work is justified only because it reduces risk for the proof vertical slice.

After consolidation, engineering priority immediately returns to:
- first 10–15 minute FTUE
- harvest/compost/sell/mission/season feel
- external alpha telemetry

No scope expansion occurs between consolidation and external proof-of-fun.
