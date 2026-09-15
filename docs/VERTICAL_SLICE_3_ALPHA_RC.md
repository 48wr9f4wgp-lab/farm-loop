# Farm Loop — Vertical Slice 3 / Alpha RC

Date: 2026-09-16 JST

## Product Hypothesis

Farm Loop succeeds only if the player enjoys causing visible ecological recovery, not merely completing farm chores.

The Alpha RC therefore tests one compact fantasy:

> Collect a local resource -> turn waste into compost -> advance time -> return compost to the land -> see life return -> harvest the result -> want to see what happens next.

## Canonical Loop for the Slice

1. Snow-country coop: collect eggs and manure
2. Work: gather leaves / rice husks
3. Compost shed: prepare compost
4. End month: compost matures
5. Sansai patch: return mature compost to soil
6. Harvest: collect seasonal sansai from recovered land

The loop must work without energy, forced waiting, dead-end resources or hidden mandatory knowledge.

## Experience Goals

### First 60 seconds

- player understands where to tap
- first meaningful action happens quickly
- 3D world, not a management dashboard, is the emotional center

### Restore Beat

The compost-return beat must provide the strongest payoff in the slice:

- clear visual state change
- richer soil / vegetation
- flowers and small signs of life
- restrained animation
- SFX + haptic recognition
- immediate next cue to harvest

### Completion Beat

At 6/6 the player should understand:

- waste became fertility
- fertility changed the land
- the land produced a reward
- another month may reveal a new state

The desired reaction is not “tutorial finished.” It is “I want to see the next change.”

## Presentation Contract

- portrait 390x844 baseline
- fixed orthographic 3D diorama
- guided hero height 400–420px
- no critical UI under Bottom Nav
- no right-edge clipping
- Safe Area respected
- one primary objective per guided step
- Objective / CTA / visual focus / allowed input must match
- unrelated facilities remain visible but cannot cause guided misnavigation

## Visual Target

Runtime renderer:

- `scripts/ui/farm_diorama_v14.gd`
- visual pass 12
- `satoyama-premium-2026-09-16-alpha-rc`

Core visual identity:

- Japanese snow-country mountain backdrop
- satoyama tree line
- stream
- wooden rural structures
- coop / compost / sansai / log mushrooms / hives
- lived-in small props
- damaged -> recovering -> thriving land hierarchy

Do not add facilities merely to increase content density.

## Audio Target

Alpha RC includes:

- procedural action SFX
- procedural low-volume ambience
- wind / stream / birds
- seasonal bee / leaf / winter quiet variation
- sound toggle
- Reduced Motion for visual motion
- haptic feedback for key actions

These are validation assets, not a commitment to final production audio sources.

## Measurement

Local telemetry only during readiness stage.

Must support:

- session start/end
- FTUE step start/completion
- core resource actions
- compost create/use
- month advance
- sansai harvest
- FTUE completion
- full Restore Loop completion
- request completion where relevant
- manual telemetry export

## Not in Scope Before Alpha Result

Do not expand:

- crop catalogue
- facility count
- currencies
- village arc depth
- mountain content volume
- seasonal content volume
- retention economy
- monetization

until the Restore Loop passes proof.

## Alpha Readiness Definition

Code-ready is not enough.

Vertical Slice 3 becomes Alpha-ready only when:

1. all CI hard gates are green
2. GitHub Pages deploy is green
3. one fresh physical-iPhone FTUE pass is completed without blocker
4. restoration payoff is clearly visible on-device
5. telemetry export works on-device
6. main save survives FTUE test-slot use

Until #3–#6 are manually verified, status remains:

**READY_PENDING_PHYSICAL_IPHONE**
