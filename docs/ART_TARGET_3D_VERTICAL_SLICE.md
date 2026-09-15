# Farm Loop — 3D Vertical Slice Art Target

Updated: 2026-09-15

## Decision

Farm Loop will no longer polish the old flat 2D farm-map presentation as the main product direction.

The canonical presentation target is now:

- portrait mobile-first
- fixed oblique / isometric 3D diorama
- premium cozy UI
- Japanese snow-country satoyama atmosphere
- restoration fantasy as the main visual reward

The generated finished-state concept approved on 2026-09-15 is the visual north star for this slice.

## Product fantasy

> Restore a snow-country satoyama with circular ecology, and enjoy watching the land become alive again.

The player should understand this primarily from the scenery, not from explanatory UI.

## Canonical visual direction

- Warm, handcrafted miniature-diorama feeling.
- Stylized 3D rather than photorealism.
- Soft spring sunlight, readable shadows, natural depth.
- Snow-capped mountains, satoyama tree line, clear stream, footpaths and wooden rural structures.
- Ivory/white UI cards with deep green accents and generous touch targets.
- The 3D farm is the hero; UI must support it rather than dominate it.

## First seasonal target: Spring

The first proof-quality scene must visibly contain:

1. lingering snow on mountains
2. fresh spring greens
3. cherry/spring blossom accents
4. clear stream and small bridge
5. chicken coop and chickens
6. compost shed and compost pile
7. sansai restoration patch
8. beehives
9. log mushroom area
10. paths, fences, stones, flowers and a wooded ridge

## Restoration states

The land-restoration payoff must be obvious in three stages.

### Damaged
- pale/dry soil
- sparse vegetation
- few living accents
- visually tired

### Recovering
- healthier soil
- new sprouts
- more greenery
- small signs of returning life

### Thriving
- dense healthy vegetation
- flowers and richer ground color
- stronger biodiversity cues
- unmistakable sense that the land has recovered

## Interaction constraints

- Keep the fixed/semifixed diorama camera.
- Do not add free-roaming 3D movement.
- Preserve tap-first facility interaction.
- Keep FTUE V3 restore loop as the proof loop.
- Step 4 must keep a dedicated visible `今月を終える` CTA.
- Visual polish must never hide or reduce interaction clarity.

## Build order

### P0
- stabilize the 3D renderer on iPhone Web
- lock the diorama composition
- establish lighting, terrain, stream, forest ridge and facility silhouettes
- preserve Save / GameRules / FTUE contracts

### P1
- strengthen damaged/recovering/thriving visuals
- increase material and silhouette quality of the five identity facilities
- add spring vegetation, stones, fences, flowers and bridge details
- align UI spacing and tone to the premium target

### P2
- ambience motion: water glint, foliage motion, petals, bees
- month/season transition presentation
- compost completion, restoration and harvest payoff effects

## Do not

- return to flat 2D as the main product target
- add many new systems before this scene works
- add content volume to compensate for weak presentation
- reintroduce village/market complexity into the proof loop
- treat primitive geometry as final art

## Slice success

This visual slice succeeds when a first-time player can immediately say:

- this is a Japanese snow-country satoyama
- the land can be restored
- my actions are changing the scenery
- I want to see the next month / next restoration stage
