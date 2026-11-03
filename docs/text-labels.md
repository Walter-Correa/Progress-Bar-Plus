# HUD Value & Text Labels

Progress Bar Plus includes an integrated, high-contrast HUD text label system designed to display live numeric telemetry directly on top of progress meters. It eliminates manual TextDraw alignment by offering **Intelligent Auto-Scaling**, **Adaptive Vertical Text Stacking**, and **Dynamic Bar Color Synchronization**.

---

## 1. Dynamic Template Tokens

When attaching or updating a label, you can use dynamic tokens that automatically format and refresh whenever the bar's value changes:

| Token | Output Format | Description | Example |
| :--- | :--- | :--- | :--- |
| `{PERCENT}` | Integer ($0$ to $100$) | Normalized progress percentage | `"{PERCENT}%"` $\to$ `75%` |
| `{PCT}` | Integer ($0$ to $100$) | Short alias for `{PERCENT}` | `"{PCT}%"` $\to$ `75%` |
| `{VALUE}` | Integer | Current raw bar value | `"{VALUE} HP"` $\to$ `85 HP` |
| `{VAL}` | Integer | Short alias for `{VALUE}` | `"{VAL} L"` $\to$ `42 L` |
| `{MAX}` | Integer | Maximum capacity of the bar | `"{VAL}/{MAX}"` $\to$ `65/100` |
| `{MIN}` | Integer | Minimum threshold floor | `"{MIN}-{MAX}"` $\to$ `0-100` |

### Static Text & Formatting
You can freely mix dynamic tokens with custom strings, units, and color codes:
```pawn
// Vehicle Speedometer
SetPlayerProgressBarLabel(playerid, barSpeed, true, "{VAL} KM/H");

// Health Gauge with Color Tag
SetPlayerProgressBarLabel(playerid, barHealth, true, "{FF0000}HP: {FFFFFF}{PERCENT}%");

// Weapon Clip Ammo
SetPlayerProgressBarLabel(playerid, barAmmo, true, "{VAL} / {MAX}");
```

---

## 2. Intelligent Auto-Scaling (`SetPlayerProgressBarLabelAutoScale`)

Enabled by default (`true`), the Auto-Scale engine mathematically constrains the font scale dimensions ($scaleX, scaleY$) so that text glyphs **never bleed or overflow** outside the bar's borders.

```pawn
stock SetPlayerProgressBarLabelAutoScale(playerid, barid, bool:autoScale);
```

### How the Containment Algorithm Works
1. Measures the inner usable bounding box of the bar:
   $$W_{\text{avail}} = \text{Width} \times 0.85, \quad H_{\text{avail}} = \text{Height} \times 0.85$$
2. Evaluates the string length and calculates font proportions ($scaleX \approx scaleY \times 0.27$).
3. If the estimated text width exceeds $W_{\text{avail}}$, it scales both $X$ and $Y$ down proportionally.
4. Whenever you resize or reposition the bar in-game or via script, the label automatically recalculates its scale instantly.

To disable auto-scaling and specify fixed manual sizes:
```pawn
// Set fixed scale (X = 0.22, Y = 0.90) and automatically disable auto-scaling
SetPlayerProgressBarLabelScale(playerid, barid, 0.22, 0.90);
```

---

## 3. Adaptive Vertical Text Stacking (`SetPlayerProgressBarLabelOrientation`)

When creating narrow or vertical bars (such as tall vertical health bars, elevator indicators, or side gauges), horizontal text like `"70%"` spills over to the left and right:

```
Horizontal on narrow bar:  [ 70% ]  <-- Text overflows outside borders!
```

### Vertical Stacking via Native `~n~`
Progress Bar Plus solves this with **Adaptive Vertical Stacking**. It inserts the native GTA SA line break delimiter (`~n~`) between visible characters, stacking the characters vertically inside the bar:

```
Vertical stacked:  [ 7 ]
                   [ 0 ]   <-- Perfectly bounded and centered!
                   [ % ]
```

### Color Tag Preservation
If your label template contains embedded color tags like `{FF0000}70{FFFFFF}%`, the vertical formatting engine recognizes the brackets and keeps `{RRGGBB}` tags intact:
`"{FF0000}7~n~0~n~{FFFFFF}%"`

### Geometric Centering Math
* **Horizontal Centering:** With `alignment = 2` (Center), each line centers exactly on the bar's mid-axis:
  $$X = \text{barX} + \frac{\text{barW}}{2.0} + \text{offsetX}$$
* **Vertical Block Centering:** Calculates total stack height for $L$ lines ($L \times scaleY \times 9.0$) and offsets $Y$ so the entire stack is centered vertically within the bar:
  $$Y = \text{barY} + \frac{\text{barH} - (L \cdot scaleY \cdot 9.0)}{2.0} + \text{offsetY}$$

### Intelligent Auto-Adaptive Orientation
Progress Bar Plus features an **intelligent Auto-Adaptive layout engine** as its default standard behavior:
* **Width-Aware Dimension Check:** It continuously calculates the horizontal width required to display the text template at a legible font scale ($w_{\text{needed}} = \text{chars} \times 2.8 + 2.5$).
* **Wide Vertical Bars:** If a vertical bar ($height > width$) is wide enough ($width \ge w_{\text{needed}}$), the text **stays horizontal** and perfectly centered inside the bar.
* **Narrow Vertical Bars:** Only when the bar is too narrow to fit horizontal characters ($width < w_{\text{needed}}$) and tall enough ($height \ge \text{chars} \times 6.5$) does the engine seamlessly adapt and stack the characters vertically with `~n~`.
* **Zero Configuration:** In the In-Game Editor, auto-adaptation is 100% automatic and standard, adjusting dynamically in real time as you resize the bar.

---

## 4. Dynamic Color Synchronization (`SetPlayerProgressBarLabelFollowColour`)

By default, labels have a fixed color (pure white `0xFFFFFFFF` with a crisp black outline).

However, you can configure the label to **automatically mirror and track the bar's active fill color**:

```pawn
stock SetPlayerProgressBarLabelFollowColour(playerid, barid, bool:follow);
```
*(Alias: `SetPlayerProgressBarLabelFollowColor`)*

### Live Color Tracking & Dynamic Tag Injection
When enabled (`true`):
* Changing the bar color via `SetPlayerProgressBarColour` immediately updates the text label to match.
* When **Dynamic Health Gradients** are active, the text transitions smoothly and constantly along with the gradient (Green $\to$ Amber $\to$ Red) across value scrubbing, lerp transitions, and autofill cycles.
* Uses native SA-MP `{RRGGBB}` dynamic color tag injection at the string level, ensuring instant client-side color rendering without font cache latency or flicker.
* During **Blinking Alerts**, the text pulses in sync with the alert phase.

```pawn
// Enable dynamic color matching
SetPlayerProgressBarLabelFollowColour(playerid, barid, true);

// Or pass colour = 0 to SetPlayerProgressBarLabelColour to activate follow mode:
SetPlayerProgressBarLabelColour(playerid, barid, 0);
```

---

## 5. Typography, Alignments & Offsets

### Font Styles
GTA San Andreas supports four distinct textdraw fonts:
* **Font 0:** Classic fixed-width monospace.
* **Font 1:** Standard GTA slim font (**Recommended** — sharpest contrast and cleanest outlines).
* **Font 2:** Headline bold all-caps font.
* **Font 3:** Storyline / retro serif font.

> [!NOTE]
> Progress Bar Plus automatically bypasses SA-MP client font caching by recreating the label TextDraw handle whenever the font changes, guaranteeing instant visual updates.

### Horizontal Alignments
```pawn
// 1 = Left, 2 = Center (Default), 3 = Right
SetPlayerProgressBarLabel(playerid, barid, true, "{PERCENT}%", 0xFFFFFFFF, 2);
```

### Fine Pixel Offsets
Fine-tune the label's anchor point relative to the bar geometric center:
```pawn
// Shift label 2.0 pixels right and 1.5 pixels down
SetPlayerProgressBarLabelOffset(playerid, barid, 2.0, 1.5);
```
