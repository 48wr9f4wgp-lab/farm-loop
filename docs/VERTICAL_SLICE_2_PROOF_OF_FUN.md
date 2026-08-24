# Farm Loop — Vertical Slice 2.0 / Proof of Fun

Last updated: 2026-08-25
Status: IMPLEMENTATION TARGET
Purpose: prove Farm Loop is worth full production before adding content volume.

## 1. Product promise being tested

**雪国の里山を循環させて育てる、Cozy Management Game。**

The first 10–15 minutes must make a new player feel all five differentiators without reading a manual:
1. snow-country satoyama,
2. circular ecology,
3. mountain work,
4. village relationships,
5. anticipation for the next month/season.

This slice is not a content demo. It is a proof that the repeated play pattern is understandable and satisfying.

---

## 2. Success definition

A first-time external player should be able to say, in their own words, something close to:

> 鶏や山の恵みを使って里山を循環させ、季節を進めながら村と農場を育てるゲーム。

Pass signals:
- player understands what to do next without asking,
- first meaningful action occurs within 60 seconds,
- player experiences at least one complete circulation chain,
- player makes one mountain-route choice,
- player sells a meaningful basket,
- player sees one human/village purpose for production,
- player voluntarily wants to advance another month or see the next season,
- no energy dead-end, no forced waiting, no resource state where nothing useful can be done.

Fail signals:
- player describes it as a menu/list management app,
- player cannot explain why compost/mountain/village matter,
- player spends >20 seconds repeatedly hunting for the next action,
- feedback is too weak to recognize success,
- player reaches a progression blocker caused by selling/using the wrong item,
- player says the main loop feels like chores before minute 10.

---

## 3. Target first-session timeline

### Beat 0 — Arrival / 0:00–0:30
Goal: communicate place and one immediate action.
- Farm opens directly.
- Snow-country visual identity is visible immediately.
- One objective only: go to the chicken coop.
- No modal tutorial wall.

### Beat 1 — Chicken / 0:30–1:30
Action:
- select coop,
- avatar moves,
- collect eggs + manure.

Feedback requirement:
- immediate facility motion,
- collect SFX,
- visible reward recognition,
- next objective changes immediately.

Player learning:
**animals produce both sale goods and circulation resources.**

### Beat 2 — Materials / 1:30–2:30
Action:
- Work tab,
- gather leaves/rice-husk material.

Player learning:
**the mountain/farm edge feeds the production loop; there is no energy meter.**

### Beat 3 — Compost / 2:30–3:30
Action:
- compost shed,
- manure + leaves -> compost queue.

Feedback:
- work motion/SFX,
- clear “next month” anticipation.

Player learning:
**inputs are transformed rather than merely sold.**

### Beat 4 — Month transition / 3:30–4:30
Action:
- end current month.

Required presentation:
- month/season/weather change is unmistakable,
- compost completion is recognized,
- next action appears immediately.

Player learning:
**time changes the world and completes natural processes.**

### Beat 5 — Return to soil / 4:30–6:00
Action:
- apply finished compost to sansai,
- harvest seasonal sansai.

Feedback:
- loop/harvest feedback are stronger than ordinary button presses,
- player can see that circular play improved the result.

Player learning:
**the loop changes future output.**

### Beat 6 — Mountain choice / 6:00–8:00
Action:
- Work tab,
- choose Stream / Beech Forest / Ridge.

Rules:
- all routes advance,
- no wrong answer,
- route trade-offs are legible,
- discovery result appears immediately.

Player learning:
**mountain work is a meaningful choice, not a random side button.**

### Beat 7 — Village purpose / 8:00–10:30
Action:
- Village tab,
- see a resident request and relationship progression.

Requirement:
- the slice must guarantee at least one understandable resident need,
- if the player lacks the item, the UI must explicitly say where/how to obtain it,
- no permanent FTUE deadlock if the player sold or used an item early.

Player learning:
**production has a human purpose beyond currency.**

### Beat 8 — Market payoff / 10:30–12:30
Action:
- Market tab,
- compare channels,
- batch-sell remaining basket.

Feedback:
- predicted net value is visible before sale,
- sale is one satisfying action,
- reward feedback is Tier 4 quality.

Player learning:
**production decisions convert into visible growth.**

### Beat 9 — Return trigger / 12:30–15:00
Show, do not explain:
- satoyama rank/progress,
- next seasonal discovery,
- next facility/relationship goal,
- month/season anticipation.

Desired voluntary behavior:
**player chooses to advance another month without being told to.**

---

## 4. FTUE rules

- Teach by action, not text blocks.
- One primary objective at a time.
- Do not lock unrelated tabs unless a true progression safety reason exists.
- Never use energy or forced timers to pace FTUE.
- Early mistakes must recover within one short loop.
- Every successful action follows:
  input -> acknowledgement -> result -> audio/haptic -> reward recognition -> next cue.
- The player should not need to understand every stat during FTUE.
- Hide/de-emphasize administrative sections until they are relevant.

---

## 5. Required analytics for external test build

Core funnel:
- session_start
- ftue_step_started
- ftue_step_completed
- first_facility_action
- farm_harvest
- material_gather
- compost_create
- month_advance
- compost_use
- sansai_harvest
- mountain_route_selected
- mountain_result
- village_request_viewed
- village_request_completed
- market_channel_selected
- market_sell
- full_loop_complete
- session_end

Each FTUE event should include:
- step,
- elapsed_seconds,
- year/month,
- current_tab,
- relevant facility/route/channel,
- money,
- loop_score,
- satoyama rank where applicable.

---

## 6. External-test pass gate

Initial sample: 10–20 people unfamiliar with the project.

Qualitative pass:
- >=70% can explain the core loop without prompting,
- >=60% spontaneously mention at least two differentiators (snow country / circulation / mountain / village / seasons),
- >=60% say they want to see another month/season,
- no repeated critical navigation confusion shared by >=30% of testers.

Behavioral directional targets (not launch KPIs):
- first meaningful action median <=60 sec,
- FTUE circulation completion >=70%,
- mountain-choice reach >=65%,
- market payoff reach >=60%,
- village-purpose reach >=60%,
- progression-blocker rate = 0%.

These are proof thresholds for continuing production, not final retention targets.

---

## 7. Scope lock until this gate is tested

Do NOT add:
- more crop catalog for its own sake,
- new currencies,
- guilds/PvP/social systems,
- battle pass,
- gacha,
- energy,
- large LiveOps systems,
- city-building expansion,
- large new facility sets.

Allowed work:
- FTUE flow,
- clarity,
- visual/audio/game-feel quality for these beats,
- recovery from player mistakes,
- analytics,
- save/QA/performance fixes,
- representative final-quality art for slice-critical assets.

---

## 8. Production decision after test

FULL GO:
- proof thresholds pass and external players perceive the differentiator.

RE-SCOPE:
- core loop is liked but one or more pillars confuse or add friction.

KILL / PIVOT:
- circulation is understood but not enjoyable,
- the product is consistently described as chores/menu management,
- return motivation cannot be produced without heavy FOMO/LiveOps,
- art/content burden required to make it attractive exceeds realistic production capacity.
