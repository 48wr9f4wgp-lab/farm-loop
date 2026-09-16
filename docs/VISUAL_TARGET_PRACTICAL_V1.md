# Farm Loop — Practical Visual Target V1

Date: 2026-09-16 JST
Status: Canonical visual implementation target for the current Vertical Slice / Alpha RC

## One-line target

**軽く動く、見やすい、里山らしい、回復が気持ちいい3D箱庭。**

The target is not generated-concept-art density. The shipping direction is a lightweight premium 3D miniature that can be reproduced consistently in Godot 4.7.2 / WebGL compatibility mode on iPhone.

## Product visual fantasy

> 雪国の小さな里山へ手を入れ、土地・水・植生・暮らしが少しずつ蘇る景色を育てる。

The world should be the emotional center. UI exists to clarify action; it should not overpower the diorama.

## Must — Alpha visual contract

1. Fixed-angle orthographic 3D diorama
2. Entire playable island remains inside portrait safe framing
3. No right-edge clipping or Bottom Nav collision
4. Coop / compost / sansai / mushrooms / hives remain recognizable at phone size
5. Sansai restoration has three readable states: damaged / recovering / thriving
6. The Step 5 -> Step 6 restore payoff is obvious without zoom
7. Stream reads as water through bank contrast, highlights and vegetation
8. Paths remain visually clear and connect the functional spaces
9. Buildings have readable contact with the ground; no floating-model look
10. Snow-country identity appears through mountain silhouette, conifers and seasonal palette
11. Motion remains restrained and respects Reduced Motion
12. Compatibility rendering performance remains the priority over expensive post effects

## Should — Full GO preparation

- stronger seasonal palette separation
- additional authored tree varieties
- better path / stone / bank variation
- facility-specific micro-animation where it improves readability
- more distinct autumn and winter landscape treatment
- final recorded / licensed ambience after product validation
- consistent iconography and typography polish across all tabs

## Nice to have — after proof

- richer fog / atmospheric depth where performance allows
- higher-fidelity water material
- facility upgrade visual states
- more environmental wildlife
- subtle day/time lighting states
- optional higher-detail native build preset

## Explicit non-goals for the current slice

Do not chase:

- photorealism
- concept-art density of flowers and props
- free camera rotation
- high-cost volumetrics
- dense screen-space effects
- complex character animation
- dozens of unique vegetation assets before proof

## Visual hierarchy

Phone-size first read should be:

1. Current actionable / restored land
2. Farm buildings and path network
3. Stream and ecological connections
4. Tree line / snow-country silhouette
5. decorative micro-detail

If decorative detail competes with #1 or #2, remove it.

## Current implementation

Runtime target:

- `scripts/ui/farm_diorama_v15.gd`
- visual pass: `13`
- visual target id: `satoyama-practical-final-2026-09-16-v1`

V15 adds the practical target using inexpensive geometry and material separation:

- stronger stream banks and center highlight
- sparse reeds / river stones
- path-edge structure
- snow-country conifer silhouettes
- meadow clusters to break flat ground
- thin facility foundations for contact readability
- stronger facility silhouette details
- larger harvest-readable sansai rosettes in restored states
- lighting / ambient balance tuned without changing the proven camera framing

## Acceptance rule

A visual pass is successful only when it improves the physical-iPhone screenshot while preserving:

- FTUE clarity
- safe framing
- tap targets
- progression
- save compatibility
- acceptable performance

Automated tests validate contracts, but the physical iPhone remains the final visual authority.
