# Farm Loop — Architecture Dependency Map B1

Last updated: 2026-08-24
Status: BASELINE MAPPED / NO BEHAVIOR CHANGE
Purpose: freeze current behavior ownership before staged consolidation.

## 1. Active entry chain

Current scene entry:
`main.tscn -> scripts/ui/main_v16.gd`

Current UI inheritance chain:

`main_v16.gd`
-> `main_v15.gd`
-> `main_v14.gd`
-> `main_v13.gd`
-> `main_v12.gd`
-> `main_v11.gd`
-> `main_v102.gd`
-> `main_v101.gd`
-> `main_v10.gd`
-> `main_v09.gd`
-> `main_v08.gd`
-> `main_v07.gd`
-> `main_v06.gd`
-> `main_v05.gd`
-> `main_v041.gd`
-> earlier base UI / `main.gd`

This chain is the primary architecture debt to remove.

### Risk
Each layer can call `super._ready()`, rebuild a screen, change state version, replace rules, or add visual overlays. This makes boot order and behavior ownership non-local.

---

## 2. Current behavior ownership by layer

### Base / early layers
`main.gd`
- original shell/navigation/state binding
- base farm/work/market/village builders
- common button/section styles and callbacks

`main_v041.gd`
- SFX service creation
- sound setting
- six-step FTUE objective sequence
- commit-time sound/reward hooks
- season transition feedback

`main_v05.gd`
- installs Japanese UI font
- switches active rules to `GameRulesV05`
- entertainment/land-growth systems
- growth presentation layer

`main_v06.gd`
- productization shell / daily notebook integration
- daily action tracking

`main_v07.gd`
- quick farm action panel
- basket batch selling
- product interaction changes

`main_v08.gd`
- dedicated farm art asset overlay

`main_v09.gd`
- asset-first farm map replacement
- removes duplicate legacy location panels
- arrival and selected-facility behavior

### Product UI layers
`main_v10.gd`
- compact product shell
- hero metric compression
- farm map hero sizing
- work/market/village product layouts

`main_v101.gd`
- mobile touch target fixes
- dynamic farm map sizing
- daily notebook text readability

`main_v102.gd`
- iPhone/PWA content scaling policy
- minimum navigation/farm sizes

### Current screen-defining layers
`main_v11.gd`
- mountain exploration hero before route selection existed

`main_v12.gd`
- CURRENT work-screen structure
- three route choices: stream / beech / ridge
- mountain work / mushroom logs / recipes / growth / safety
- switches active rules to `GameRulesV12`

`main_v13.gd`
- CURRENT market-screen structure
- basket preview / best channel / selected channel / batch sell
- switches active rules to `GameRulesV13`

`main_v14.gd`
- CURRENT village-screen structure
- request readiness / missing items / relationship progress / settings
- switches active rules to `GameRulesV14`

### Final visual/polish layers
`main_v15.gd`
- farm minimum map size
- farm polish overlay / route-footprint and focus cues
- minimum farm CTA target

`main_v16.gd`
- tab transition fade
- facility action overlay
- current release version marker

---

## 3. Active GameRules inheritance chain

Current active rules after `main_v14._ready()`:

`GameRulesV14`
-> `GameRulesV13`
-> `GameRulesV12`
-> `GameRulesV07`
-> `GameRulesV06`
-> `GameRulesV05`
-> `GameRules`

### Ownership
`GameRules`:
- base state operations
- harvesting / compost / crafting / selling / upgrades / requests / month progression / hazards

`GameRulesV05`:
- satoyama prosperity and land rank
- mountain exploration
- rare finds
- six-step ecology chain

`GameRulesV06`:
- daily notebook state / targets / one-time reward

`GameRulesV07`:
- basket batch sale

`GameRulesV12`:
- route-specific exploration
- stream / beech / ridge risk/reward configuration

`GameRulesV13`:
- stable preview price
- basket preview
- best sales channel

`GameRulesV14`:
- village request readiness/missing-item projection
- relationship progress projection

### Consolidation target
One canonical `GameRules` implementation with explicit internal sections or small domain collaborators, not version inheritance.

---

## 4. Current presentation/rendering dependencies

### Farm world
- `farm_map.gd` — base terrain, input, movement, facility positions, weather/ambient world
- `farm_map_v09.gd` — asset-first base drawing variant
- `product_map_overlay_v08.gd` — dedicated facility/player SVG assets
- `product_map_overlay_v09.gd` — living asset motion / action flash
- `farm_polish_overlay_v15.gd` — selected/route/focus guidance
- `facility_action_overlay_v16.gd` — facility-specific action animation
- `feedback_overlay.gd` — reward popup, token flight, reward burst, season transition

### Audio
- `scripts/audio/sfx_player.gd` — generated SFX and play-kind policy

### Risk
Visual behavior is distributed across the farm map plus multiple overlays. Consolidation must preserve layer order and input transparency.

---

## 5. Behavior contracts that must survive consolidation

### Boot
- main scene loads without script/parse/runtime boot errors
- Japanese font loads
- current save loads without destructive reset
- public Web/PWA route remains unchanged

### Navigation
- four primary tabs remain available: farm / work / market / village
- touch targets stay >= current mobile Hard Gate
- safe-area / PWA scaling behavior remains

### Farm
- map remains primary visual object
- facilities are directly tappable
- player moves/arrives at selected facility
- selected facility has one obvious primary action
- ready/completed state remains legible without opening another screen
- batch/repeated work remains compressed where currently implemented

### Work
- route choice remains three meaningful options
- no energy gate
- no dead route
- route differences remain: quantity / rare / prosperity tradeoff
- mountain work, mushroom inoculation, processing, upgrades and safety remain reachable

### Market
- basket preview is deterministic for display
- best channel can be identified
- selected channel changes expected net
- one-tap batch sale remains

### Village
- requests show who wants what
- missing requirements are visible
- unavailable request CTA is disabled
- relationship tier/progress remains visible

### Feel/accessibility
- sound can be disabled
- reduced motion still works
- visual effects do not intercept input
- frequent actions stay short

---

## 6. State/save fields currently coupled to active features

Do not rename/remove without explicit schema migration:
- `version`
- `settings.sound`
- `settings.haptics`
- `settings.reduced_motion`
- `tutorial_step`
- `entertainment.prosperity_xp`
- `entertainment.explores_this_month`
- `entertainment.rare_finds`
- `entertainment.chain_stage`
- `entertainment.chains_completed`
- `entertainment.best_chain`
- `entertainment.route_counts`
- `entertainment.last_route`
- `entertainment.last_find`
- `daily.date`
- `daily.harvest`
- `daily.explore`
- `daily.sell`
- `daily.claimed`
- `daily.total_completed`
- `village_requests`
- `relation`
- `ready`
- `inventory`
- `facility_levels`
- `projects`
- `discovered`

B2 must produce an explicit Save Envelope/schema audit before any structural state migration.

---

## 7. Consolidation sequence

### B1 — COMPLETE
- dependency chain mapped
- active ownership mapped
- behavior contracts listed
- state coupling listed

### B2 — Baseline Contract Gate
Before code movement:
- classify current tests into behavior contracts vs historical implementation assumptions
- preserve behavior tests
- rewrite tests that assert old labels/version-layer internals
- add save fixture inventory

### B3 — Domain consolidation
- merge `GameRulesV05/V06/V07/V12/V13/V14` behavior into canonical rules implementation
- no economy/balance changes
- all domain tests must pass before UI migration

### B4 — Screen extraction
Extract presentation into:
- FarmScreen
- WorkScreen
- MarketScreen
- VillageScreen

No visual redesign in this step.

### B5 — Controller/service extraction
Create/normalize:
- MainController
- AudioService
- FeedbackService
- SaveService
- Analytics adapter placeholder/interface only

### B6 — Render consolidation
Reduce farm render/overlay layering where safe while preserving visual output and input behavior.

### B7 — Remove version chain
Only after all behavior/visual/physical-device gates pass:
- point `main.tscn` to canonical controller
- archive/deprecate old `main_vXX` and `game_rules_vXX`
- do not delete history until rollback confidence is established

---

## 8. B2 acceptance criteria

B2 is complete only if:
1. every existing CI behavior gate has an owner and purpose
2. no test depends on a historical version label unless it is a release/version test
3. save fields used by the first 15-minute slice are inventoried
4. current main scene passes boot regression
5. Farm/Work/Market/Village behavior contracts are executable tests or explicitly covered by existing tests
6. rollback point is documented

No new gameplay feature work before B2 is complete.