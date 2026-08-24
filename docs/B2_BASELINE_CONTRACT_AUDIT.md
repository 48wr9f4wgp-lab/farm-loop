# Farm Loop — B2 Baseline Contract Audit

Last updated: 2026-08-24
Status: IMPLEMENTED / awaiting final CI for latest commit
Purpose: make current product behavior safe to refactor without preserving historical version-layer implementation details.

## 1. Test classification

### Domain behavior contracts — KEEP
- `tests/test_game_rules.gd`
  - core circulation: coop -> manure -> compost -> month -> compost use -> sansai -> sale
- `tests/test_entertainment_v05.gd`
  - satoyama growth / mountain exploration / ecology chain
- `tests/test_product_v06.gd`
  - daily notebook one-time completion/reward
- `tests/test_product_ui_v07.gd`
  - basket batch-sale behavior
- `tests/test_work_v12.gd`
  - three route differences and route exploration contract
- `tests/test_market_v13.gd`
  - stable preview / channel economics / market behavior
- `tests/test_village_v14.gd`
  - request readiness / missing items / relationship progression

These tests may be renamed later, but their behavioral assertions survive consolidation.

### Platform / accessibility contracts — KEEP
- `tests/font_smoke.gd`
- `tests/test_pwa_v101.gd`

The filenames are historical, but the assertions are current product requirements:
- Japanese font support
- `canvas_items + expand`
- adaptive Web canvas
- no fixed Web width/height override
- touch-target minimums
- readable daily notebook contrast
- farm minimum visual area

### Art/resource contracts — KEEP UNTIL FINAL ART REPLACEMENT
- `tests/test_art_v08.gd`

Current SVG paths are implementation/assets, but this test prevents accidental missing product art during consolidation. Replace with final Art Bible asset checks when final production assets supersede v08 SVGs.

### UI product contracts — KEEP, REBASE TEXT WHEN PRODUCT COPY CHANGES
- `tests/test_product_ui_v09.gd`
- `tests/test_product_ui_v10.gd`

These protect hierarchy, current tabs, major CTA presence and current product flow. Exact text should only remain when the copy itself is a product requirement; historical version names are not requirements.

### Boot contract — KEEP
- `tests/boot_smoke.gd`

This is the minimum runtime gate:
- main scene loads
- instantiates
- becomes ready
- all four tabs can be opened
- state dictionary has required platform/UI fields

### Visual/polish implementation tests — REWRITTEN IN B2
- `tests/test_farm_v15.gd`
- `tests/test_polish_v16.gd`

Previous problem:
- explicitly searched for `farm_polish_overlay_v15.gd`
- explicitly searched for `facility_action_overlay_v16.gd`

That would incorrectly fail a successful architecture consolidation.

Current contract:
- farm visual area remains >= product minimum
- visual children do not intercept map touch input
- action feedback targets the selected facility and starts immediately
- farm CTA remains thumb-sized
- SFX provides overlapping feedback capacity
- key sound categories build valid audio streams
- tab transition resolves to fully readable content

Implementation filename is no longer part of the contract.

---

## 2. New Save/Migration Hard Gate

Added:
- `tests/test_save_contract_b2.gd`
- workflow step `Save and migration B2 contract`

Contracts:
1. primary save succeeds
2. save round-trips through disk
3. schema remains current
4. release metadata survives load
5. second save creates usable previous-state backup
6. corrupted/tampered primary checksum falls back to backup
7. schema v1 fixture migrates to schema v4
8. legacy project/compost/relation/analytics data survives migration

### Bug found by the new gate
Before B2, `SaveService.save()` could fail its own post-write checksum verification because checksum calculation was based on the pre-serialization Variant representation rather than a JSON-normalized canonical representation.

Fix:
- canonical JSON round-trip before hashing
- sorted-key deterministic JSON text
- migration no longer invents the unrelated stale app version `godot-0.3.2-mobile-ci`
- migration preserves source release metadata until the active app stamps its own release after successful boot

This was a real product reliability defect, not a test-only issue.

---

## 3. Save field inventory for first 15-minute slice

Hard-preserve until explicit schema migration:

### Envelope / identity
- `schema_version`
- `version`

### Core progression
- `year`
- `month`
- `money`
- `reputation`
- `loop_score`
- `xp`
- `level`
- `yearly_sales`
- `lifetime_sales`
- `weather`

### Core resources
- `inventory`
- `facility_levels`
- `ready`
- `buffs`
- `projects`
- `compost_queue`
- `mushroom_batches`

### Village / collection
- `relation`
- `village_requests`
- `discovered`

### Current loop / FTUE
- `counters`
- `tutorial_step`
- `entertainment.*`
- `daily.*`

### Platform/player preferences
- `settings.sound`
- `settings.haptics`
- `settings.reduced_motion`
- `ui.selected_facility`
- `ui.last_tab`

### Telemetry placeholder
- `analytics`

No B3/B4 refactor may rename or reinterpret these fields without a schema migration decision.

---

## 4. Rollback anchors

### Pre-Commercial-Proof validated product baseline
`1e7741c38e50db8389294d8e5d57f2ad760a438a`

This is the previously validated v1.6 product baseline before Commercial Proof/B2 work.

### B2 candidate baseline
Latest code after Save fix and contract-test decoupling should become the new rollback anchor only after full CI + Web export + Pages deploy complete successfully.

Do not delete or archive the version-chain implementation until the B3/B4 consolidated path passes both CI and physical iPhone regression.

---

## 5. B2 completion criteria

- [x] active dependency chain mapped
- [x] current behavior ownership mapped
- [x] tests classified by product contract vs implementation detail
- [x] obvious historical implementation assertions removed from farm/polish tests
- [x] first-slice save fields inventoried
- [x] Save/Migration Hard Gate added
- [x] checksum/save defect fixed
- [x] legacy migration fixture added
- [x] rollback baseline documented
- [ ] latest full CI + Pages deployment green

When the final checkbox is green, B2 is COMPLETE and B3 Domain Consolidation may begin.