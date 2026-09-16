# Farm Loop — GDD v4 / Circulation Puzzle

Date: 2026-09-16
Status: CANONICAL GDD FOR CURRENT PRODUCT DIRECTION
Depends on: `docs/PRODUCT_RESET_V4_2026_09_16.md`

## 1. High Concept

Farm Loop is a portrait mobile cozy strategy game about restoring a Japanese snow-country satoyama by spending a limited number of monthly interventions and creating ecological synergies across a small 3D diorama.

Player fantasy:

> 自分の手入れで、水・土・植物・生き物の循環がつながり、荒れた里山が毎月少しずつ蘇る。

The player is a caretaker and planner, not a factory operator.

## 2. Design Pillars

### P1. Choice Before Chore
Every important action must contain a meaningful choice of **what / where / when**. Repeatedly pressing a facility CTA is not a core mechanic.

### P2. The World Answers Back
Player decisions must create visible environmental responses at month end.

### P3. Small Rules, Large Chains
Use a few legible rules that combine into satisfying multi-zone effects.

### P4. Cozy Tension
Use limited actions and seasonal opportunity cost, never hard punishment, energy walls or opaque loss.

### P5. Environment Is the Reward
The satoyama becoming richer must be more emotionally important than currency gain.

## 3. Core Session

Normal session target: 3–8 minutes.

A session can contain one or more months.

### Month Start
- weather / season context is shown
- player sees 3 Action Points
- board highlights current opportunities, not a mandatory single objective

### Action Phase
Player chooses intervention + zone.

Before commit, show:
- target zone
- immediate effect
- possible month-end chain
- Action Point cost

Action cost in the proof slice is always 1 AP.

### Month End
Player may end after 0–3 actions, but the UI should encourage spending the useful actions.

Pressing `今月を終える` triggers the ecological resolution sequence.

### Resolution
Resolve one chain at a time with readable animation and short labels.

Example:

`沢が戻る -> 山菜区画に水が届く -> 堆肥が効く -> 山菜が繁る -> 虫が戻る`

### Reward / New Decision
Player receives:
- visible landscape change
- recovery increase
- optional harvest/resource
- new opportunity for the next month

The next-month prompt should generate curiosity, not merely tell the player to continue.

## 4. Vertical Slice Board

Use 5 authored ecological zones.

### Z1. 山菜区画 / Sansai Patch
Role: first productive restoration target.

Reads visually as:
- damaged: sparse, dry, exposed soil
- recovering: sprouts, darker soil, low plant clusters
- thriving: dense sansai, flowers, insects, harvest cue

### Z2. 沢 / Stream Bank
Role: water source / network enabler.

States:
- blocked
- flowing
- healthy bank

### Z3. 草地 / Meadow Edge
Role: flowering / pollinator bridge.

States:
- bare grass
- flowering edge
- pollinator-rich meadow

### Z4. 鶏舎まわり / Coop Yard
Role: organic matter source and one visible human-land loop.

Do not make the player repeatedly collect manure by CTA. For the slice, the yard passively produces one compost resource or supports a compost intervention at month start.

### Z5. 林縁 / Forest Edge
Role: habitat / decomposition relationship.

Can remain partially inactive in the first playable build if the first three zones already prove the loop.

## 5. State Model

Each zone stores integers from 0–3 unless otherwise noted:

- `soil`
- `water`
- `bloom`
- `habitat`
- `recovery`

Board stores:

- `year`
- `month`
- `season`
- `weather`
- `action_points` (0–3)
- `resources` (minimal)
- `unlocked_interventions`
- `resolved_events`

Do not expose all values numerically in normal play.

## 6. Intervention Rules

### Compost
Target: land zone.

Immediate:
- soil +1

Month-end synergy:
- if water >=1, recovery +1
- if water >=2, produces stronger vegetation state / possible harvest

### Restore Stream
Target: stream zone.

Immediate:
- stream water state +1

Month-end:
- sends water support to authored neighbor zones
- visual water flow becomes stronger

### Plant Flowering Shrub
Target: meadow / compatible edge.

Immediate:
- bloom +1

Month-end:
- if adjacent healthy vegetation exists, supports pollinator event
- pollinator event can boost next-month productive opportunity

### Deadwood / Mushroom Log
Not required in the first implementation milestone.

Later rule:
- habitat +1
- stronger if adjacent forest and moist ground

## 7. Preview System

Preview is mandatory.

Before confirmation, visually show:
- selected target zone outline
- direct effect icon
- predicted connected zones using soft arrows / pulses
- short text, maximum two lines

Example:

`山菜区画に堆肥`  
`土 +1 / 沢が流れているので今月末に成長`

Do not require the player to memorize formulas.

## 8. Month-End Resolution UX

Target duration: 4–8 seconds total for the Vertical Slice.

Sequence:

1. camera remains stable
2. affected source zone pulses
3. connection path lights / flows
4. receiving zone changes
5. ambient life appears if relevant
6. recovery meter rises once at the end
7. next opportunity appears

Allow tap to accelerate after first viewing.

Reduced Motion:
- skip travel animations
- apply state changes with short fades / labels

## 9. Recovery Metric

One overall `里山回復度` from 0–100 exists for player comprehension.

It is derived from zone recovery and biodiversity, not directly purchased.

In the proof slice it can be simple:

`overall = average(active zone recovery normalized to 100)`

Do not let this become the only goal. The visual world must remain the main reward.

## 10. Resources / Economy

Keep minimal.

Vertical Slice resources:
- Compost token: max small count, produced by the existing coop/organic loop or granted at month start for proof
- Action Points: exactly 3 per month

No coins are required for the new core loop proof.

The existing money display may be hidden during Vertical Slice 4 if it distracts from the puzzle.

## 11. Difficulty

The player should see good / better choices, not one hidden correct answer.

Difficulty sources:
- limited AP
- seasonal opportunity
- adjacency
- order of interventions
- deciding whether to strengthen one zone or connect two zones

No hard fail in the first proof.

Optional performance goal:
- restore the initial district within N months
- no punishment if slower

## 12. FTUE V4

FTUE must teach by choice.

### Beat 1
Show damaged Sansai + blocked Stream.

Prompt:
`最初にどこから手を入れる？`

Offer two valid actions:
- 山菜区画へ堆肥
- 沢を整える

Both must work.

### Beat 2
After first action, preview how a second action could connect with it.

Do not prescribe exact order.

### Beat 3
Allow player to spend final AP freely among unlocked choices.

### Beat 4
`今月を終える`

Run full ecological resolution.

### Beat 5
Show the causal chain in-world.

### Beat 6
Next month begins with a new opportunity, and tutorial control is released.

FTUE success:
- player can explain why the land changed
- player knows they have 3 actions per month
- player understands month end as chain resolution

## 13. Feedback

Every intervention:
- target pulse
- short SFX
- light haptic
- AP decrement visibly animates

Every synergy:
- connection animation
- distinctive but restrained sound
- visual state transition

Major recovery:
- stronger haptic
- ambience gains one layer
- wildlife / vegetation addition

## 14. UI Structure

Primary screen:
- Header: year/month/season/weather + Recovery
- Small AP indicator: `手入れ 3/3`
- Main 3D diorama: largest element
- Context action tray appears after zone tap
- `今月を終える` appears as a persistent secondary action after at least one move
- Bottom nav minimized during proof; unrelated tabs hidden or disabled

Do not place a large instruction card above the world for normal play.

The world should occupy more vertical area than the current FTUE card stack.

## 15. Visual Rules

Keep current practical 3D target as baseline, but future visual work must support gameplay readability.

Required visual language:
- zone boundaries readable without visible grid
- water connections obvious
- thriving zones visibly denser
- intervention preview is distinct from completed state
- active selectable zones are discoverable
- no excessive yellow floating dots

## 16. Audio

Keep existing ambience system.

Month-end resolution should layer sounds causally:
- water
- soil / vegetation
- insects / birds

Audio must reinforce the chain sequence.

## 17. Save / Compatibility

Introduce a new v4 board block rather than overwriting legacy state immediately.

Suggested:

```text
state["circulation_v4"] = {
  board_version,
  action_points,
  zones,
  unlocked_interventions,
  last_resolution
}
```

Migration must initialize the new block safely while preserving current saves.

## 18. Analytics for Proof

Add local events:
- `v4_session_start`
- `v4_intervention_previewed`
- `v4_intervention_committed`
- `v4_month_end_pressed`
- `v4_chain_resolved`
- `v4_next_month_started`
- `v4_ftue_complete`

Properties:
- intervention
- target_zone
- AP_before / after
- predicted_chain_count
- actual_chain_count
- recovery_before / after
- month

## 19. Proof Metrics

Primary behavioral targets for internal/external test:

- first meaningful choice <= 45 sec median
- >=80% understand `3 actions -> month end -> chain`
- >=70% FTUE V4 complete without explanation
- >=60% voluntarily start month 2 after first resolution
- >=50% try a different intervention/order in month 2
- progression blocker = 0%

Qualitative:
- players describe at least one cause/effect relationship
- players say the month-end change felt earned by their choices
- no dominant reaction of `just pressing buttons`

## 20. Out of Scope Until Proof

- deep economy
- village social system
- broad crafting
- monetization implementation
- complex random events
- multiple maps
- large species catalogue
- elaborate story
- free camera

## 21. Vertical Slice Exit Rule

Do not move to content expansion until physical-device testing shows that the first two months contain meaningful decisions.

If players still describe the game as passive or obvious after V4, change the rule system again instead of adding content.