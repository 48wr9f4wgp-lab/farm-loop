# Farm Loop v0.4 Live Benchmark — 2026-08-23

## Candidate pool checked
Hay Day / Township / Japanese Rural Life Adventure / Family Island / Goodville / FarmVille 3 / Klondike Adventures / Sunrise Village / Harvest Land / Stardew Valley / My Dear Farm / Tsuki's Odyssey.

## Final benchmark roles
1. **Hay Day** — farm readability, instant work feedback, production/sale clarity, long-lived mobile UX.
2. **Township** — dense-but-readable map composition, long-term visual layering, visible production state.
3. **Japanese Rural Life Adventure** — Japanese countryside identity, seasonality, quiet environmental storytelling.
4. **Family Island** — task guidance, direct map interaction, reward readability, character-in-world presentation.
5. **My Dear Farm** — compact mobile composition, cute/tactile facility silhouettes, decoration readability.

## Patterns to transfer (not copy)
- The farm/world occupies most of the screen; UI should support the world, not replace it.
- Top HUD contains only high-value state.
- Ready/collectable state is readable without opening a panel.
- Characters, animals, water, foliage, smoke and weather provide low-cost ambient movement.
- Repeated work feedback is short; major reward feedback is larger.
- Seasonal state changes world palette and detail, not just text labels.
- Task guidance names the next useful action without blocking free interaction.
- Facility silhouettes are recognizable before labels.

## Anti-patterns to avoid
- Generic emoji as the primary art language.
- Card-stack web-app composition covering most of the map.
- Permanent high-intensity VFX.
- Dense icon clusters that compete with the farm.
- Color-only ready/warning states.
- Copying another game's building shape, icon, layout or reward animation.

## v0.4 implementation targets
- Replace circular kanji facility tokens with original mini-building silhouettes.
- Add depth: shadow, terrain bands, trees, crop rows, creek, mountain/snow-country horizon.
- Add ambient animation: water shimmer, trees/grass, chickens/bees, chimney smoke, character walk bob.
- Make ready state a physical sign + glow pulse.
- Keep frequent action feedback under ~0.8 sec.
- Preserve reduced-motion support.
