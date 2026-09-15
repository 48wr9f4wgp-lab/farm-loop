# Farm Loop — Vertical Slice 3 / Restore Loop

Date: 2026-09-15
Status: CURRENT IMPLEMENTATION TARGET
Depends on: `docs/PRODUCT_RESET_V3_2026_09_15.md`
Supersedes as active proof target: `docs/VERTICAL_SLICE_2_PROOF_OF_FUN.md`

## 1. Proof Question

Can a first-time player, without explanation, use a circular resource loop to visibly restore one damaged satoyama patch and then want to see the next month or season?

Everything in this slice serves that question.

## 2. First-Session Loop

**集める -> 堆肥にする -> 時間を進める -> 土へ還す -> 土地が蘇る -> 収穫する -> 次の季節を見たくなる**

Target first session: 6–10 minutes.

## 3. FTUE V3 Beats

### Beat 0 — 荒れた里山 / 0:00–0:30
Show the problem before showing systems.
- Farm map opens on one visibly tired/barren restoration patch.
- One short objective only.
- The player should understand: this place can become better.

### Beat 1 — 循環の材料 / 0:30–1:30
- Collect from the chicken coop.
- Manure is the important loop resource.
- Eggs may exist as secondary inventory but selling is not taught here.
- Collect leaf/rice-husk organic matter through the simplest available interaction.

Learning: useful resources come from ordinary life, not only from buying inputs.

### Beat 2 — 堆肥 / 1:30–2:30
- Combine manure + organic matter into compost.
- Immediate tactile feedback.
- UI makes the next month connection explicit without a long explanation.

Learning: waste becomes future soil value.

### Beat 3 — 月を進める / 2:30–3:30
- Advance one month.
- Compost completes.
- Season/weather/environment movement must be visually legible.

Learning: time changes natural processes and the world.

### Beat 4 — 土へ還す / 3:30–5:00
- Apply compost to the damaged restoration patch.
- This is the major payoff beat, not a routine button press.
- The patch must visibly change: soil/vegetation/color/life, not only a number.

Learning: the loop physically restores the satoyama.

### Beat 5 — 恵みが戻る / 5:00–6:30
- Harvest sansai or equivalent restored-land yield.
- Add a visible biodiversity/ambient-life response where feasible.
- Reward feedback should connect the harvest to the restored patch.

Learning: healthy land gives back.

### Beat 6 — 次の変化 / 6:30–8:00
- Show the next restoration opportunity and next seasonal change.
- Do not force a village request, market comparison or route choice.
- The desired behavior is voluntary: player chooses to advance or continue restoring.

## 4. UI Scope

During V3 FTUE:
- Farm/environment is the hero.
- One primary objective at a time.
- Market and Village are not required for progression.
- Mountain route choice is not required.
- Administrative stats are de-emphasized.
- Do not use a full-screen tutorial wall.
- Primary CTA >=50 px.
- Existing safe-area, reduced-motion, sound and haptic settings remain.

A temporary legacy tab may remain technically accessible only if it cannot consume required restoration resources or confuse the objective. Hiding/de-emphasizing legacy tabs is preferred to deleting their code during the first re-scope pass.

## 5. Visual Payoff Contract

The restored patch needs at least three simultaneous classes of change:
1. terrain/soil color or texture improves,
2. vegetation density or variety increases,
3. ambient life or environmental motion increases.

Preferred fourth signal:
- soundscape becomes richer or warmer.

A progress number alone does not satisfy the payoff contract.

## 6. Game Feel Contract

Major restore action:
input -> immediate acknowledgement -> land transformation -> sound/haptic -> reward recognition -> next-season cue.

The restore action should be the strongest first-session feedback tier.

Harvest is secondary to restoration, not the other way around.

## 7. Fail Conditions

The slice fails if any of the following occurs:
- player describes the game mainly as selling/menus/chores,
- player does not notice that the land improved,
- compost appears as an arbitrary crafting step rather than part of a loop,
- player cannot tell what to do next for >20 seconds repeatedly,
- resource use can create a progression dead-end,
- the player reaches Village/Market complexity before understanding restoration,
- the player has no reason to care about the next month/season.

## 8. External Proof Gate

Initial external sample remains 10–20 unfamiliar players.

Qualitative targets:
- >=70% can explain the loop as something close to “waste/resources go back to the soil and restore the land,”
- >=70% explicitly notice the land changed after restoration,
- >=60% mention at least two identity signals without prompting: snow country / satoyama / circulation / seasonal change / nature restoration,
- >=60% want to see another month/season or restore another patch,
- no critical navigation confusion shared by >=30% of testers.

Behavioral directional targets:
- first meaningful action median <=60 sec,
- compost creation reach >=80%,
- first restoration completion >=70%,
- harvest-after-restoration reach >=65%,
- next-month/next-patch voluntary continuation >=50%,
- progression blocker = 0%.

## 9. Analytics Needed for V3

Keep/reuse where applicable:
- session_start
- ftue_step_started
- ftue_step_completed
- first_facility_action
- material_gather
- compost_create
- month_advance
- compost_use
- sansai_harvest
- ftue_complete
- session_end

Add for V3:
- restoration_patch_viewed
- restoration_started
- restoration_completed
- restoration_payoff_viewed
- next_month_voluntary
- next_patch_selected

Village/market/mountain events are no longer proof-gate events for V3.

## 10. Implementation Order

P0:
1. dependency audit for FTUE V2 -> V3,
2. add V3 test contract before changing live flow,
3. reuse existing resource/month/compost actions,
4. make one restoration patch state explicit,
5. make its visual before/after obvious,
6. route FTUE to six/seven focused beats,
7. hide/de-emphasize legacy systems during FTUE,
8. full CI regression,
9. iPhone fresh FTUE verification.

P1 only after P0 works on device:
- stronger environment art,
- ambient life,
- BGM/ambience,
- season transition polish,
- second restoration patch,
- external alpha instrumentation.

Do not add new content families before this gate passes.
