# Farm Loop — Product Reset v3

Date: 2026-09-15
Status: CANONICAL PRODUCT DIRECTION
Supersedes for product/design decisions: `docs/VERTICAL_SLICE_2_PROOF_OF_FUN.md` and the five-pillar positioning in `HANDOFF.md`.

This document records the approved re-scope. Existing code remains a reusable implementation baseline, not a reason to preserve old product scope.

## 1. Decision

Farm Loop remains in development, but the previous product concept is rejected as too broad.

Old concept mixed too many parallel pillars: farming, mountain routes, village relationships, channel selling, hazards, mushrooms, bees, processing, collections and seasonal management.

New concept is intentionally narrower:

> **雪国の荒れた里山を、循環の力で蘇らせるCozy Restoration Management Game。**

The game is not a small Hay Day/Township clone. The primary reward is not money or catalog size. The primary reward is seeing a damaged satoyama visibly recover through player-created resource loops.

## 2. Context Lock

- Platform: mobile first; iOS/Android target, current iPhone Web build is the daily validation surface.
- Region: Japan-first product sensibility; English localization remains a later expansion target.
- Audience: players seeking calm management, visible progression, seasons, nature and short repeatable sessions.
- Genre: Cozy Restoration Management / light simulation.
- Core loop: gather by-products -> return nutrients -> restore land -> harvest/observe recovery -> advance time/season -> restore the next area.
- Meta loop: progressively restore the satoyama map, increase habitat richness, unlock new seasonal states and restoration zones.
- Session length: normal 3–8 minutes; first session target 6–10 minutes.
- Orientation/input: portrait, touch.
- Offline/online: single-player, local-first. No backend required for current slice.
- Monetization hypothesis: premium purchase + optional future large expansion/DLC. No forced ads, gacha, battle pass or high-frequency FOMO.
- LiveOps: not required for product proof.
- Visual target: stylized handcrafted snow-country satoyama; environment is the hero.
- Save: existing local schema/backup system remains until a schema change is justified.
- Privacy class: no personal account or user-generated content required for current slice.

## 3. Success Definition

### What the player repeats
Collect useful by-products, turn them back into soil value, restore a damaged patch, then see the land respond over time.

### What feels good
A clear before/after transformation: soil improves, plants return, snow/season changes reveal growth, wildlife/ambient life comes back, and the map becomes visibly healthier.

### What grows
The satoyama itself: restored zones, habitat richness, seasonal discoveries and visible landscape quality. Currency is secondary.

### Why open the game again
To see what changed after the next month/season and what new life or restoration opportunity appeared.

### Monetization point
The base game sells a complete calm restoration experience; future expansion can add a new mountain/valley/seasonal region rather than pressure-based spending.

### Shared category expectation
Easy touch interaction, clear next action, satisfying harvest/reward feedback, readable progression, warm worldbuilding and short mobile sessions.

### Differentiation
Japanese snow-country satoyama + circular resource restoration + visible ecological recovery + seasonal transformation.

## 4. Market Check — 2026-09-15

The live benchmark pool was refreshed before this re-scope.

Observed category signals:
- Mobile Simulation remains large, but 2025 downloads grew while IAP revenue declined, so broad F2P simulation is not an easy economic lane.
- Hay Day and Township still demonstrate the category expectation for readable production/progression, but competing on content breadth, economy depth or LiveOps is unrealistic for Farm Loop.
- Japanese Rural Life Adventure demonstrates current demand for Japanese countryside, seasons, self-sufficiency and village revival.
- Longleaf Valley demonstrates that restoring damaged nature is immediately understandable as a long-term visual objective.
- Cozy Grove and Tsuki's Odyssey demonstrate return motivation through a changing world and low-pressure observation rather than pure economic optimization.
- Tiny Harvest is a useful small-team mobile reference for calm farming progression without punishing timers.

Final benchmark roles for v3:
1. Japanese Rural Life Adventure — Japanese countryside, seasonality, atmosphere.
2. Longleaf Valley — visible restoration payoff and damaged-to-thriving transformation.
3. Hay Day — mobile clarity, collection feedback and baseline farming readability only.
4. Cozy Grove: Camp Spirit — world revival, gentle progression and environmental payoff.
5. Tiny Harvest — small-scope mobile farming, low-pressure pacing and readable growth.

Do not copy their characters, compositions, icons, art, text or exact systems. Transfer only abstract success principles.

## 5. Scope Cut

These are removed from the Core Loop and must not be required in the next proof slice:
- mountain-route three-choice system,
- village relationship progression,
- village delivery as a first-session beat,
- channel comparison / complex selling,
- mushroom system,
- beekeeping/pollination system,
- processing catalog,
- bear/hornet/biosecurity hazards,
- large collection/book systems,
- facility catalog expansion,
- multiple currencies.

They may remain in legacy code temporarily for rollback and reuse. Do not delete them in bulk before dependencies are understood.

## 6. Keep / Promote

Promote to primary product value:
- snow-country visual identity,
- season/month change,
- chicken/manure or equivalent organic by-product,
- leaf/rice-husk organic matter,
- compost creation,
- returning compost to soil,
- sansai/forest-edge harvest,
- satoyama restoration progress,
- environmental before/after transformation,
- ambient life returning,
- strong harvest/restoration feedback,
- save safety, mobile UX, sound/haptics accessibility.

## 7. Product Rule for New Features

A proposed feature enters scope only if it materially strengthens at least one of these:
1. the restoration loop is easier to understand,
2. restoration feels better moment-to-moment,
3. the land changes more visibly,
4. the next month/season becomes more desirable to see,
5. long-term satoyama growth becomes more meaningful.

Personal interest alone is not a product justification.

## 8. Architecture / Migration Rule

Do not rewrite the project wholesale.

Reuse the existing Godot runtime, save service, GameRulesCurrent, farm map, month/season system, feedback/audio/haptics and tested resource actions where they support v3.

Legacy systems are to be de-emphasized or hidden first. Delete only after dependency audit and regression coverage.

## 9. Next Build Target

Build `Vertical Slice 3 — Restore Loop` before any content expansion.

The slice must prove one thing:

> A new player can create one ecological loop, visibly restore one piece of land, and voluntarily want to see the next month/season.

If that is not fun, adding village, bees, mushrooms, routes or more products is prohibited.
