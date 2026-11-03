# Progress Bar Plus — Documentation Hub

Welcome to the comprehensive technical documentation for **Progress Bar Plus** (SA-MP & open.mp). This hub provides guides, architectural deep-dives, tutorials, and complete API references covering every aspect of the library and the integrated visual editor suite.

---

## Documentation Sections

| Section | Description |
| :--- | :--- |
| **[Getting Started](getting-started.md)** | Installation, zero-dependency setup, drop-in migration from `progress2`, and your first HUD meter. |
| **[Bar Styles & Geometry](bar-styles.md)** | Linear rectangular bars, radial ring odometers, circular gauges, 16:9 widescreen border correction. |
| **[Animations & Visual FX](animations-and-fx.md)** | Fluid value lerp (quadratic ease-out), multi-stop color gradients, cyclic auto-fill, and blinking alerts. |
| **[HUD Value & Text Labels](text-labels.md)** | Intelligent auto-scaling, adaptive vertical character stacking (`~n~`), dynamic color tracking, font styles. |
| **[In-Game Visual Editor](in-game-editor.md)** | Full manual for `/pbe`: interactive 11-tool dock, real-time transforms, multi-layer workspace, HUD anchors. |
| **[Complete API Reference](api-reference.md)** | Exhaustive reference dictionary covering all functions, parameters, return values, macros, and enums. |

---

## Quick Navigation Matrix

Find immediate guidance based on your development goal:

* **I am migrating from `progress2`:**
  * Read [Drop-In Migration from progress2](getting-started.md#drop-in-migration-from-progress2).
  * Check the compatibility mapping for directions (`BAR_DIRECTION_*` → `PB_DIR_*`).
* **I want to design HUD meters visually in-game without manual coordinate guessing:**
  * Follow the [In-Game Visual Editor Manual](in-game-editor.md).
  * Launch the filterscript and press `/pbe` in-game.
* **I want smooth health or vehicle damage transitions:**
  * Read [Smooth Value Interpolation (Lerp)](animations-and-fx.md#smooth-value-interpolation-lerp).
  * Use `InterpolatePlayerProgressBarValue(playerid, barid, target, 500);`.
* **I want a health bar that smoothly transitions from Green → Amber → Red as HP drops:**
  * Read [Dynamic Multi-Stop Color Gradients](animations-and-fx.md#dynamic-multi-stop-color-gradients).
  * Use `SetPlayerProgressBarGradient(playerid, barid, true);`.
* **I have a vertical or narrow bar and want centered, vertically stacked text:**
  * Read [Adaptive Vertical Text Stacking](text-labels.md#adaptive-vertical-text-stacking).
  * Use `SetPlayerProgressBarLabelOrientation(playerid, barid, PB_LABEL_ORIENT_AUTO);`.
* **I want a radial speedometer, fuel ring, or boost odometer:**
  * Read [Segmented Radial Ring Odometers](bar-styles.md#2-segmented-radial-ring-odometers-pb_style_ring).
  * Set `style = PB_STYLE_RING` and customize segments ($4$ to $60$) and scale multiplier ($0.10$ to $3.00$).

---

## Compatibility & System Requirements

* **Game Platforms:** SA-MP (0.3.7-R1 through 0.3.7-R5), open.mp (all builds).
* **Compiler Support:**
  * Community Pawn Compiler (Pawn 3.10.x by Southclaws/Zeex) — *Recommended*.
  * Official Pawn 3.2.3664 (legacy SA-MP default).
* **Dependencies:** **Zero external dependencies**. Does not require Streamer, YSI, or third-party native plugins.
* **Aspect Ratios:** Native support for standard 4:3, 16:9 widescreen, and 21:9 ultrawide monitor displays with pixel-perfect geometric border compensation.

---

> [!NOTE]
> All code snippets and example scripts in these documents are production-ready and fully tested with 0 errors and 0 warnings.
