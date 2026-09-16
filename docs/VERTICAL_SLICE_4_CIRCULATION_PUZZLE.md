# Farm Loop — Vertical Slice 4 / Circulation Puzzle

Date: 2026-09-16
Status: NEXT IMPLEMENTATION TARGET
Canonical inputs:
- `docs/PRODUCT_RESET_V4_2026_09_16.md`
- `docs/GDD_V4_CIRCULATION_PUZZLE.md`

## 1. Purpose

Replace the passive Restore Loop proof with a genuinely decision-driven first two months.

The slice must answer:

> Is it fun to spend a few monthly interventions, predict a chain, then watch the satoyama answer back?

## 2. Slice Scope

### Required Zones
- Sansai Patch
- Stream Bank
- Meadow Edge
- Coop Yard

### Optional Zone
- Forest Edge

### Required Interventions
- Compost
- Restore Stream
- Plant Flowering Shrub

### Required Systems
- 3 AP per month
- zone selection
- intervention selection
- preview
- commit
- month end
- chain resolution
- overall recovery
- month 2 start
- FTUE V4
- save/migration
- local telemetry

### Explicitly Hidden During Proof
- Market
- Village
- mountain-route system
- complex money economy
- unrelated legacy facility actions

## 3. Internal Board Graph

Node ids:

- `sansai`
- `stream`
- `meadow`
- `coop`
- `forest` (optional)

Initial authored adjacency:

- sansai <-> stream
- sansai <-> meadow
- meadow <-> stream
- meadow <-> coop
- sansai <-> forest (optional)
- meadow <-> forest (optional)

The graph is invisible. The 3D landscape communicates proximity.

## 4. Initial State

Month: April / Spring
Action Points: 3

Suggested state:

### Sansai
- soil 0
- water 0
- bloom 0
- habitat 0
- recovery 0

### Stream
- water 0
- recovery 0

### Meadow
- bloom 0
- water 0
- recovery 0

### Coop
- recovery 1
- provides compost availability

The board must support at least two viable opening sequences.

## 5. Opening Sequence Examples

### Route A — Soil first
1. Compost -> Sansai
2. Restore Stream -> Stream
3. Flowering Shrub -> Meadow
4. End Month

Expected chain:
Stream flows -> Sansai receives water -> composted soil produces growth -> Meadow blooms -> first insects appear.

### Route B — Water first
1. Restore Stream -> Stream
2. Compost -> Sansai
3. Compost or Flowering Shrub depending current balance
4. End Month

Must produce a different but valid result.

The FTUE must not declare either route correct.

## 6. Milestone Order

### M1 — Rules-Only Simulation
Create a deterministic rules module and tests with no UI dependency.

PASS:
- 3 AP enforced
- previews deterministic
- at least two opening sequences produce different state
- no sequence can brick progression in first two months

### M2 — Save / Migration
Add `circulation_v4` state block.

PASS:
- legacy save loads
- V4 state initializes
- main save not destroyed
- test slot remains separate

### M3 — World Zone Selection
Map authored 3D areas to V4 zone ids.

PASS:
- tappable zones work on physical portrait layout
- no invisible grid shown
- selected zone obvious

### M4 — Intervention Tray
Tap zone -> small contextual action tray.

PASS:
- available actions understandable
- preview shown before commit
- AP cost clear
- cancel easy

### M5 — Chain Preview
Show predicted direct + connected effects.

PASS:
- preview matches deterministic rules
- no formula memorization required

### M6 — Month Resolution
Create readable 4–8 second chain animation.

PASS:
- water -> growth -> bloom/life order visible
- Reduced Motion works
- state saved after resolution

### M7 — FTUE V4
Teach by two valid choices.

PASS:
- player is never told a mandatory opening order
- month 1 can complete from both supported routes
- tutorial ends at month 2 start

### M8 — Game Feel
Add causal SFX / haptic / restrained world animation.

### M9 — Physical iPhone Proof
Run two fresh months.

Hard questions:
- Did I make a choice?
- Did I understand why the land changed?
- Did I want to test another order?

## 7. Architecture

New code should prefer clean modules rather than extending another long inheritance chain.

Suggested new modules:

- `scripts/core/circulation_rules_v4.gd`
- `scripts/core/circulation_state_v4.gd` or pure Dictionary helpers
- `scripts/ui/circulation_board_v4.gd`
- `scripts/ui/screens/farm_screen_v4_puzzle.gd`
- `tests/test_circulation_rules_v4.gd`
- `tests/test_ftue_v4.gd`

Do not append all V4 behavior into `main_v30.gd` or `farm_diorama_v15.gd`.

Reuse renderer geometry selectively, but V4 gameplay state should not depend on old FTUE V3 state.

## 8. UI Target

Normal proof screen priority:

1. Header: month / season / recovery / AP
2. Diorama: largest region
3. Context tray only after selection
4. Month End button
5. minimal bottom navigation

Remove the large instruction-card stack from normal V4 gameplay.

FTUE can use one compact hint line.

## 9. Definition of Done

Vertical Slice 4 is functionally ready only if:

- M1–M8 automated tests are green where applicable
- Web export works
- current iPhone layout has no clipping
- two opening routes are playable
- month 1 resolution is causally understandable
- month 2 begins with at least one new meaningful decision
- no forced passive CTA chain remains
- main save safety verified

It is not complete merely because the UI renders.