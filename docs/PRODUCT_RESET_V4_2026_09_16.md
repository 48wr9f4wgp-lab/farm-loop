# Farm Loop — Product Reset v4

Date: 2026-09-16
Status: CANONICAL PRODUCT DIRECTION
Supersedes for product/design decisions: `docs/PRODUCT_RESET_V3_2026_09_15.md`, `docs/VERTICAL_SLICE_3_ALPHA_RC.md`, and Restore Loop FTUE V3 as the product proof target.

Existing code remains a reusable implementation baseline. The previous Restore Loop is not preserved merely because it works.

## 1. Decision

Theme/IP: KEEP  
3D Diorama: KEEP  
Current CTA-driven Restore Loop: KILL  
New Core Loop: ADOPT

Farm Loop becomes:

> **雪国の里山を、限られた手数で手入れし、循環の連鎖を組み上げて蘇らせる Cozy Restoration Puzzle / Management Game。**

The player is not primarily operating facilities. The player is deciding **where to intervene, what ecological loop to create, and when to advance the month to see the land answer back**.

## 2. Market Check — 2026-09-16

This reset was checked against current and still-active adjacent references.

### ISLANDERS: Mobile
Official App Store positioning emphasizes a calm minimalist puzzle-strategy loop where buildings score based on nearby structures, with no timers or microtransactions. The transferable principle is **simple placement with meaningful adjacency** and low-pressure mobile readability.

Source: https://apps.apple.com/us/app/islanders-mobile/id6745312000

### Terra Nil
Netflix describes a reverse city-builder about transforming lifeless terrain into a thriving ecosystem, with procedurally generated terrain and a strong ecological before/after reward. The transferable principle is **restoration itself as the reward and objective**.

Source: https://about.netflix.com/news/continuing-our-games-journey

### Preserve
Steam describes a relaxing puzzle nature-building game where players place plants and animals to create symbiosis. The transferable principle is **ecological relationships as puzzle rules rather than decoration**.

Source: https://store.steampowered.com/app/2109270/

### Dorfromantik
Steam describes a relaxing strategy/puzzle game where placement creates landscape combinations, points and quests. The transferable principle is **calm presentation + real placement decisions + satisfying board evolution**.

Source: https://store.steampowered.com/app/1455840/Dorfromantik/

### ISLANDERS: New Shores
The 2025 sequel continues the calm minimalist 3D placement strategy model and currently maintains strong user review sentiment. The transferable principle is **small-rule strategy that creates attractive 3D worlds without large simulation complexity**.

Source: https://store.steampowered.com/app/2368930/ISLANDERS_New_Shores/

### Market interpretation

Farm Loop should not copy any one title. Its lane is the overlap of:

- restoration payoff,
- light spatial strategy,
- cozy mobile pacing,
- visible landscape growth,
- Japanese snow-country identity.

The product advantage is not content breadth. It is **a small number of understandable ecological rules that produce satisfying visual chains**.

## 3. Context Lock

- Platform: mobile-first; iOS/Android target. Current Web/iPhone build remains daily validation surface.
- Region: Japan-first sensibility; later English localization.
- Audience: players who like calm strategy, cozy worldbuilding, nature restoration, visible progression and short sessions.
- Genre: Cozy Restoration Puzzle / Light Management.
- Subgenre: spatial synergy / ecological chain puzzle.
- Core loop: choose intervention -> place/apply it to a zone -> create adjacency/synergy -> spend limited monthly actions -> advance month -> watch ecological chain resolve -> collect/observe new benefits -> plan next month.
- Meta loop: restore connected satoyama districts, unlock new ecological relationships, seasonal conditions and landscape states.
- Session length: 3–8 minutes normal; first session 6–10 minutes.
- Orientation/input: portrait touch.
- Offline/online: single-player, local-first.
- Monetization hypothesis: premium purchase + optional major-region expansion/DLC later.
- LiveOps: not required for proof.
- Device tier: modern mid-range iPhone/Android; compatibility renderer remains valid for proof.
- Visual target: stylized fixed-angle 3D satoyama diorama; environment remains the hero.
- Production scale: small-team / AI-assisted, systems-first, limited authored content volume.
- Save: reuse current save architecture; schema changes only when the new board state requires them.
- Backend: none for the proof slice.
- Privacy: local-only proof telemetry remains preferred until external service use is approved.

## 4. New Core Loop

Each in-game month gives the player **3 Action Points**.

A month is:

1. Read the land state.
2. Choose one intervention.
3. Choose where to apply it.
4. See immediate preview / local feedback.
5. Repeat until 3 actions are spent or the player voluntarily ends early.
6. Press **今月を終える**.
7. The satoyama resolves ecological chains all at once.
8. New growth / water / wildlife / harvest opportunities appear.
9. Player decides what to improve next month.

The month-end button is no longer waiting. It is the **answer-reveal button**.

## 5. Initial Intervention Set

Vertical Slice 4 starts with only four intervention types.

### A. 堆肥を入れる — Compost
- primary effect: improves Soil in one land zone
- synergy: stronger growth if the zone has Water
- visual: soil darkens, sprouts appear, plants thicken

### B. 沢を整える — Restore Stream
- primary effect: restores Water to a stream / adjacent zone chain
- synergy: enables Soil improvements to convert into stronger Growth
- visual: water flow strengthens, banks green, stones/wet edge appear

### C. 花木を植える — Plant Flowering Shrub
- primary effect: adds Bloom / Pollinator support
- synergy: boosts productive/restored zones nearby
- visual: flowering shrubs / blossom tree, insects appear later

### D. 原木を置く — Add Deadwood / Mushroom Log
- primary effect: improves Habitat / decomposition loop near forest edge
- synergy: supports biodiversity and later soil return
- visual: logs, mushrooms, forest-edge life

Only A/B/C are required for the first playable proof. D is allowed only if A/B/C already create a clear puzzle.

## 6. Board / Zone Model

Do not convert the world into a visible square grid.

The 3D satoyama keeps an organic appearance, but internally uses a small graph of tappable zones.

Vertical Slice 4 target board:

- Sansai Patch
- Stream Bank
- Meadow / Flower Edge
- Coop Yard
- Forest Edge

Each zone has small hidden or lightly surfaced state values:

- Soil
- Water
- Habitat
- Bloom
- Recovery

The player should read these primarily from the world, not from spreadsheet-like meters.

Adjacency is authored and simple. Example:

- Stream Bank neighbors Sansai Patch + Meadow.
- Meadow neighbors Sansai Patch + Coop Yard.
- Forest Edge neighbors Sansai Patch + Meadow.

## 7. Chain Resolution

At month end, resolve in a clear visual order:

1. Water spreads / activates wet zones.
2. Soil converts into plant growth where water is sufficient.
3. Bloom attracts pollinators / supports nearby productive zones.
4. Habitat raises biodiversity if connected to restored land.
5. Recovery score updates.
6. Harvest / wildlife / next-month opportunities appear.

The player must be able to infer why a chain occurred.

No opaque random bonus spam.

## 8. Failure / Tension

The game remains cozy, but decisions must matter.

Use **opportunity cost**, not punishment:

- only 3 actions per month,
- seasonal windows,
- one action may help multiple zones if positioned well,
- poor order costs time but does not brick the run,
- actions can be previewed before confirmation,
- no irreversible trap in the proof slice.

A weak month means slower recovery, not game over.

## 9. Meta Loop

Restore one small district -> unlock the next connected district -> new ecology rule becomes available -> restore the wider satoyama.

Long-term growth is visible in the map:

- initial sparse valley,
- stream restored,
- forest edge returns,
- wet area / meadow appears,
- wildlife returns,
- seasonal richness increases,
- settlement becomes visibly alive.

Unlocks should add **new relationships**, not merely bigger numbers.

## 10. Success Definition

### Repeat
The player repeatedly chooses where to spend a small number of monthly interventions and builds ecological synergies.

### Delight
Month-end chain resolution causes multiple visible changes that the player can connect to their own choices.

### Progress
The satoyama graph gains restored zones, richer habitat and new ecological interactions.

### Return
The player wants to see how the next month / season changes the land and whether a planned chain succeeds.

### Revenue
A complete premium base game sells the restoration puzzle experience; later paid expansions may add a new mountain/valley ecology rather than pressure spending.

### Convention
Touch targets are obvious, previews are readable, actions are reversible before commitment, feedback is immediate, sessions are short and the world remains visually attractive.

### Differentiation
Japanese snow-country satoyama + ecological chain puzzle + limited monthly interventions + visible 3D restoration.

## 11. Explicit Scope Cut

Do not reintroduce these before the new Core Loop is proven:

- complex market selling,
- village relationship progression,
- mountain route choice system,
- large crafting trees,
- multiple currencies,
- facility catalog expansion,
- hazard systems,
- collection book depth,
- deep character simulation,
- LiveOps dependency,
- F2P timer pressure.

Existing code may remain for rollback until dependency cleanup is safe.

## 12. Technology Decision

Keep Godot 4.7.2.

Reason:
- current 3D diorama, input, save and Web/iPhone test pipeline already exist,
- the new loop is graph/state driven and does not require an engine change,
- engine migration would not solve the product problem.

The architecture must separate:

- board state,
- intervention rules,
- month resolution,
- presentation,
- legacy Restore Loop code.

## 13. Next Build Target

Build **Vertical Slice 4 — Circulation Puzzle**.

It must prove:

> A new player makes at least two meaningful choices, advances the month, understands the resulting ecological chain, and immediately wants to try a better / different next month.

Until this works, no further visual-polish-only pass is allowed.