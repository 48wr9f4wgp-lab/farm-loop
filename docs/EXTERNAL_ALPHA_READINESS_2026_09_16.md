# Farm Loop — External Alpha Readiness Gate

Date: 2026-09-16 JST

## Status

**READY_PENDING_PHYSICAL_IPHONE**

Farm Loop has reached an External Alpha candidate in code, automated regression and GitHub Pages delivery. External Alpha has **not** started.

The remaining hard gate is one fresh FTUE V3 completion on a physical iPhone using the deployed GitHub Pages build.

## Current Runtime

- `main.tscn`
- `scripts/ui/main_v29.gd`
- `scripts/ui/screens/farm_screen_v14.gd`
- `scripts/ui/farm_diorama_v14.gd`
- visual pass 12
- visual target `satoyama-premium-2026-09-16-alpha-rc`

## Proof Loop

FTUE V3 currently tests the smallest product hypothesis:

1. collect eggs + manure from coop
2. gather leaves / husks
3. make compost
4. end the month and mature compost
5. return compost to the sansai patch
6. harvest from the recovering land

Village, mountain-route choice and market payoff are not required beats in this proof loop. They remain implemented outside the proof path and should not distort the current proof metric.

## Alpha RC Improvements

### Visual / Game Feel

- premium 3D satoyama diorama retained
- hard portrait-safe framing retained
- guided target/input alignment retained
- restoration states remain damaged / recovering / thriving
- Alpha restoration payoff adds stronger vegetation contrast, flowers, life motes, petals and returning-bird silhouettes
- Reduced Motion remains respected

### Audio

- existing procedural SFX remains
- procedural ambience added for the Alpha candidate
- ambience reacts to season/weather with a restrained mix of wind, stream, birds, summer bees, autumn leaf rustle and winter quiet
- sound setting disables ambience too
- no external audio asset contract or paid service is used

### Telemetry

Telemetry remains local-only. There is no external SaaS transmission.

Current additional events:

- `session_end`
- `village_request_completed`
- `telemetry_exported`

Export schema:

- `farm_loop_alpha_telemetry_v1`

Manual export path:

`村 -> Alpha テスト -> テストデータをコピー`

The export is copied to the clipboard and also written to:

`user://farm_loop_alpha_telemetry.json`

## Automated Gate

`.github/workflows/mobile-web.yml` includes:

- Import / Parse
- Japanese font smoke
- Core Loop
- Save / migration
- Current Rules equivalence
- Current runtime contract
- legacy FTUE contract
- FTUE V3 restore contract
- 3D diorama / month gate contract
- **External Alpha readiness contract**
- legacy product/UI regressions
- Web export
- app icon materialization
- artifact validation
- GitHub Pages deploy

Relevant tests:

- `tests/test_diorama_v1.gd`
- `tests/test_alpha_readiness.gd`

## Physical iPhone Hard Gate

Before inviting external testers, perform exactly one fresh physical-iPhone pass from the deployed Pages build.

PASS requires all of the following:

- fresh FTUE V3 reaches 6/6 without blocker
- next target is obvious without explanation
- Objective, CTA and tappable 3D target agree
- unrelated facilities do not steal input during guided beats
- Step 4 month advance works
- Step 5 compost return works
- restoration change is obvious at phone scale
- no right-edge clipping
- no Safe Area / Bottom Nav overlap
- no unreadable or clipped Japanese text
- motion is comfortable
- SFX / ambience / haptic feedback are acceptable
- Reduced Motion suppresses unnecessary motion
- FTUE test slot does not damage main save
- normal save can be restored
- telemetry-copy action works

Any progression blocker is an automatic FAIL and must be fixed before Alpha.

## External Alpha Cohort

After physical-iPhone PASS and explicit user approval:

- 10–20 testers
- prefer people with no prior Farm Loop explanation
- one fresh first session per tester
- collect local telemetry export plus a short qualitative interview

## Proof Thresholds

Qualitative:

- >=70% explain the Restore Loop in their own words
- >=60% spontaneously mention at least two differentiators among snow-country, satoyama, circulation, land restoration, season
- >=60% want to see one more month / the next land change
- no major navigation confusion shared by >=30% of testers

Behavioral directional targets:

- first meaningful action median <= 60 seconds
- FTUE Restore Loop completion >= 70%
- progression blocker = 0%

Legacy Vertical Slice 2 reach metrics for mountain choice, market payoff and village purpose are not primary FTUE V3 metrics because those beats are no longer mandatory in the current proof path.

## Decision After Alpha

Choose one:

- **FULL GO** — proof loop and differentiation are strong enough to fund content / retention expansion
- **RE-SCOPE** — core idea survives but loop/presentation needs meaningful redesign
- **KILL / PIVOT** — proof does not justify further production

## Explicit Boundary

Do not perform any of the following without user approval:

- begin External Alpha invitations/distribution
- connect external analytics SaaS or transmit tester data externally
- enter paid service contracts
- start monetization
- submit to App Store
- publicly release the product beyond the current development preview flow
