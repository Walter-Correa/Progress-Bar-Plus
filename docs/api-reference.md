# Complete API Reference

Exhaustive technical dictionary for all functions, compile-time configurations, macros, and enumerations provided by **Progress Bar Plus**.

---

## Quick Navigation

* [1. Lifecycle & Creation](#1-lifecycle--creation)
* [2. Value & Range Control](#2-value--range-control)
* [3. Position, Dimensions & Borders](#3-position-dimensions--borders)
* [4. Colors & Dynamic Gradients](#4-colors--dynamic-gradients)
* [5. Animations & Visual FX](#5-animations--visual-fx)
* [6. HUD Value & Text Labels](#6-hud-value--text-labels)
* [7. Styles, Segments & Radial Rings](#7-styles-segments--radial-rings)
* [8. Diagnostic & Capacity Utilities](#8-diagnostic--capacity-utilities)
* [9. Constants & Enumerations](#9-constants--enumerations)
* [10. Compile-Time Configuration Defines](#10-compile-time-configuration-defines)

---

## 1. Lifecycle & Creation

### `CreatePlayerProgressBar`
```pawn
stock PlayerBar:CreatePlayerProgressBar(
    playerid,
    Float:x, Float:y,
    Float:width = 60.0, Float:height = 8.0,
    colour = PB_DEFAULT_COLOUR,
    Float:max = 100.0,
    direction = PB_DIR_RIGHT,
    Float:border = PB_BORDER_DEFAULT,
    bordercolour = 0,
    style = PB_STYLE_BAR,
    segments = PB_RING_SEGMENTS,
    Float:segmentscale = PB_RING_SEGMENT_SCALE,
    bool:convert_legacy = false
);
```
Allocates, configures, and initializes a new progress bar instance on the player's screen canvas.
* **`playerid`:** Player who owns the progress bar.
* **`x`, `y`:** Screen space coordinates ($0.0$ to $640.0$, $0.0$ to $448.0$).
* **`width`, `height`:** Outer dimensions in TextDraw coordinate units (automatically clamped to style minimum limits).
* **`colour`:** Bar fill color (RGBA hex, defaults to `0xE74C3CFF`).
* **`max`:** Upper limit of the progress range (defaults to `100.0`).
* **`direction`:** Fill progression vector (`PB_DIR_RIGHT`, `PB_DIR_LEFT`, `PB_DIR_UP`, `PB_DIR_DOWN`).
* **`border`:** Outline border thickness in pixels (`0.0` for borderless, `1.25` default).
* **`bordercolour`:** Border RGBA color (`0` = automatic black derived).
* **`style`:** Visual rendering style (`PB_STYLE_BAR`, `PB_STYLE_RING`, `PB_STYLE_CIRCLE`).
* **`segments`:** Number of radial segments if style is Ring ($4$ to $60$, default `24`).
* **`segmentscale`:** Ring chit dot scale multiplier ($0.10$ to $3.00$, default `1.00`).
* **`convert_legacy`:** *(Optional, default: `false`)* When set to `true`, automatically applies a $2.5\times$ scale multiplier (min $6.0$ px) to legacy `progress2` font-box heights ($\le 4.5$) on horizontal linear bars.
* **Returns:** The newly allocated `barid` on success, or `INVALID_PLAYER_BAR_ID` (`-1`) on failure.

---

### `DestroyPlayerProgressBar`
```pawn
stock DestroyPlayerProgressBar(playerid, barid);
```
Completely removes the progress bar, terminates active timers (lerp, gradient, autofill, blink), cleans up all internal TextDraws, and recycles the bar slot.
* **Returns:** `1` on success, `0` on failure.

---

### `DestroyAllPlayerProgressBars`
```pawn
stock DestroyAllPlayerProgressBars(playerid);
```
Destroys all active bars allocated for the specified player. Called automatically on `OnPlayerDisconnect`.
* **Returns:** `1` on success, `0` on invalid player.

---

### `ResetPlayerProgressBar`
```pawn
stock ResetPlayerProgressBar(playerid, barid);
```
Resets the progress bar value back to its minimum floor (`PB_MinValue`), terminating any active animations or blinking effects.
* **Returns:** `1` on success, `0` on failure.

---

### `ShowPlayerProgressBar` / `HidePlayerProgressBar`
```pawn
stock ShowPlayerProgressBar(playerid, barid);
stock HidePlayerProgressBar(playerid, barid);
```
Displays or hides all TextDraw components associated with the bar (border frame, background track, active fill, and text label) without destroying handles or altering the current value.
* **Returns:** `1` on success, `0` on failure.

---

### `bool:IsPlayerProgressBarVisible`
```pawn
stock bool:IsPlayerProgressBarVisible(playerid, barid);
```
Queries whether the progress bar is currently visible on the player's screen.
* **Returns:** `true` if visible, `false` otherwise.

---

### `bool:IsPlayerProgressBarRendered`
```pawn
stock bool:IsPlayerProgressBarRendered(playerid, barid);
```
Checks whether the bar's underlying TextDraw elements are currently instantiated and valid in the engine.
* **Returns:** `true` if valid and currently rendered with active TextDraw handles; `false` if unallocated or if the last render attempt failed.

---

### `bool:IsValidPlayerProgressBar`
```pawn
stock bool:IsValidPlayerProgressBar(playerid, barid);
```
Validates whether the specified bar handle represents an actively allocated progress bar.
* **Returns:** `true` if valid, `false` otherwise.

---

## 2. Value & Range Control

### `SetPlayerProgressBarValue` / `Float:GetPlayerProgressBarValue`
```pawn
stock SetPlayerProgressBarValue(playerid, barid, Float:value, bool:bar_show = false);
stock Float:GetPlayerProgressBarValue(playerid, barid);
```
Sets or retrieves the active progress fill value. Values outside `[min, max]` are automatically clamped.
* Setting a new value automatically recalculates Dynamic Gradients and updates any attached HUD Text Label.
* Terminating active value lerps when called directly.
* **`bar_show`:** Optional boolean (`false` default). When `true`, automatically displays the bar (`ShowPlayerProgressBar`) if it was previously hidden, saving boilerplate code.
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarValue` returns `Float:value` or `0.0`).

---

### `SetPlayerProgressBarMaxValue` / `Float:GetPlayerProgressBarMaxValue`
```pawn
stock SetPlayerProgressBarMaxValue(playerid, barid, Float:max = 100.0);
stock Float:GetPlayerProgressBarMaxValue(playerid, barid);
```
Sets or retrieves the upper capacity threshold. If the current value exceeds `max`, it is clamped automatically.
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarMaxValue` returns `Float:max` or `100.0`).

---

### `SetPlayerProgressBarMinValue` / `Float:GetPlayerProgressBarMinValue`
```pawn
stock SetPlayerProgressBarMinValue(playerid, barid, Float:min = 0.0);
stock Float:GetPlayerProgressBarMinValue(playerid, barid);
```
Sets or retrieves the lower floor value threshold. Linearly normalizes fill proportion across the range $[min, max]$:
$$\text{Ratio} = \frac{\text{Value} - \text{Min}}{\text{Max} - \text{Min}}$$
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarMinValue` returns `Float:min` or `0.0`).

---

### `SetPlayerProgressBarRange`
```pawn
stock SetPlayerProgressBarRange(playerid, barid, Float:min, Float:max);
```
Convenience function to configure both minimum and maximum boundaries in a single atomic call.
* **Returns:** `1` on success, `0` on failure.

---

## 3. Position, Dimensions & Borders

### `SetPlayerProgressBarPos` / `GetPlayerProgressBarPos`
```pawn
stock SetPlayerProgressBarPos(playerid, barid, Float:x, Float:y);
stock GetPlayerProgressBarPos(playerid, barid, &Float:x, &Float:y);
```
Sets or retrieves the screen anchor coordinates ($0.0$ to $640.0$, $0.0$ to $448.0$). On open.mp, repositioning operates in-place without destroying TextDraw handles.
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarSize` / `GetPlayerProgressBarSize`
```pawn
stock SetPlayerProgressBarSize(playerid, barid, Float:width, Float:height);
stock GetPlayerProgressBarSize(playerid, barid, &Float:width, &Float:height);
```
Sets or retrieves both outer dimensions simultaneously in TextDraw coordinate units (automatically clamped to style minimum limits).
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarWidth` / `Float:GetPlayerProgressBarWidth`
```pawn
stock SetPlayerProgressBarWidth(playerid, barid, Float:width);
stock Float:GetPlayerProgressBarWidth(playerid, barid);
```
Sets or retrieves the outer width dimension (automatically clamped to style minimum limit).
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarWidth` returns `Float:width` or `0.0`).

---

### `SetPlayerProgressBarHeight` / `Float:GetPlayerProgressBarHeight`
```pawn
stock SetPlayerProgressBarHeight(playerid, barid, Float:height);
stock Float:GetPlayerProgressBarHeight(playerid, barid);
```
Sets or retrieves the outer height dimension (automatically clamped to style minimum limit).
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarHeight` returns `Float:height` or `0.0`).

---

### `SetPlayerProgressBarDirection` / `GetPlayerProgressBarDirection`
```pawn
stock SetPlayerProgressBarDirection(playerid, barid, direction = PB_DIR_RIGHT);
stock GetPlayerProgressBarDirection(playerid, barid);
```
Configures fill direction: `PB_DIR_RIGHT` (0), `PB_DIR_LEFT` (1), `PB_DIR_UP` (2), `PB_DIR_DOWN` (3).
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarDirection` returns `direction`).

---

### `SetPlayerProgressBarBorder` / `Float:GetPlayerProgressBarBorder`
```pawn
stock SetPlayerProgressBarBorder(playerid, barid, Float:border = PB_BORDER_DEFAULT);
stock Float:GetPlayerProgressBarBorder(playerid, barid);
```
Configures the outline border thickness ($0.00$ to $5.00$ pixels). Automatically calculates $16:9$ widescreen compensation ($1.25\times$ vertical multiplier).
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarBorder` returns `Float:border`).

---

### `SetPlayerProgressBarBorderColor` / `GetPlayerProgressBarBorderColor`
```pawn
stock SetPlayerProgressBarBorderColor(playerid, barid, bordercolor = 0);
stock GetPlayerProgressBarBorderColor(playerid, barid);
```
*(Alias: `SetPlayerProgressBarBorderColour`, `GetPlayerProgressBarBorderColour`)*
Sets or retrieves the border outline RGBA color (`0` = automatic black derived).
* **Returns:** `1` on success, `0` on failure.

---

## 4. Colors & Dynamic Gradients

### `SetPlayerProgressBarColour` / `GetPlayerProgressBarColour`
```pawn
stock SetPlayerProgressBarColour(playerid, barid, colour = PB_DEFAULT_COLOUR);
stock GetPlayerProgressBarColour(playerid, barid);
```
*(Aliases: `SetPlayerProgressBarColor`, `GetPlayerProgressBarColor`)*
Sets the bar's base fill color. If the attached label has `followColour = true`, the text color updates to match immediately.
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarGradient`
```pawn
stock SetPlayerProgressBarGradient(
    playerid,
    barid,
    bool:enable,
    colour_empty = 0xE74C3CFF,
    colour_full = 0x2ECC71FF,
    colour_mid = 0xF1C40FFF,
    bool:inverted = false
);
```
Enables or disables 3-stop dynamic color blending based on active progress fill ratio.
* **`colour_empty`:** Color at 0% (defaults to Red `0xE74C3CFF`).
* **`colour_full`:** Color at 100% (defaults to Green `0x2ECC71FF`).
* **`colour_mid`:** Color at 50% (defaults to Amber `0xF1C40FFF`).
* **`inverted`:** `false` for Standard (Red $\to$ Green), `true` for Inverted (Green $\to$ Red).
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarGradientDirection` / `SetPlayerProgressBarGradientInverted`
```pawn
stock SetPlayerProgressBarGradientInverted(playerid, barid, bool:inverted);
#define SetPlayerProgressBarGradientDirection SetPlayerProgressBarGradientInverted
```
Switches gradient polarity between Standard (`false` / `PB_GRAD_STANDARD`) and Inverted (`true` / `PB_GRAD_INVERTED`).
* **Returns:** `1` on success, `0` on failure.

---

### `bool:IsPlayerProgressBarGradientInverted`
```pawn
stock bool:IsPlayerProgressBarGradientInverted(playerid, barid);
```
Queries whether the active gradient is inverted.
* **Returns:** `true` if inverted, `false` otherwise.

---

### `StopPlayerProgressBarGradient` / `bool:IsPlayerProgressBarGradientEnabled`
```pawn
stock StopPlayerProgressBarGradient(playerid, barid);
stock bool:IsPlayerProgressBarGradientEnabled(playerid, barid);
```
Halts gradient calculation and queries active state.
* **Returns:** `1` on success, `0` on failure.

---

## 5. Animations & Visual FX

### `InterpolatePlayerProgressBarValue`
```pawn
stock InterpolatePlayerProgressBarValue(playerid, barid, Float:target_value, duration_ms = 500);
```
Smoothly slides the progress value to `target_value` over `duration_ms` using a quadratic ease-out curve at 30 FPS (`PB_TICK_RATE = 33ms`).
* **Returns:** `1` on success, `0` on failure.

---

### `StopPlayerProgressBarInterpolation` / `bool:IsPlayerProgressBarInterpolating`
```pawn
stock StopPlayerProgressBarInterpolation(playerid, barid);
stock bool:IsPlayerProgressBarInterpolating(playerid, barid);
```
Halts an ongoing value interpolation and queries active state.
* **Returns:** `1` on success, `0` on failure.

---

### `AutoFillPlayerProgressBar` / `SetPlayerProgressBarAutoFill`
```pawn
stock AutoFillPlayerProgressBar(playerid, barid, Float:maxvalue = -1.0);
#define SetPlayerProgressBarAutoFill AutoFillPlayerProgressBar
```
Runs a recurring cyclic auto-fill animation loop (Rise $\to$ Hold $\to$ Fall $\to$ Hold) while preserving the underlying progress bar value.
* **`maxvalue`:** Upper target limit (`-1.0` defaults to `PB_MaxValue`).
* **Returns:** `1` on success, `0` on failure.

---

### `StopAutoFillPlayerProgressBar` / `bool:IsPlayerProgressBarAutoFilling`
```pawn
stock StopAutoFillPlayerProgressBar(playerid, barid);
stock bool:IsPlayerProgressBarAutoFilling(playerid, barid);
```
*(Alias: `StopPlayerProgressBarAutoFill`)*
Halts auto-fill animation and restores base progress.
* **Returns:** `1` on success, `0` on failure.

---

### `BlinkPlayerProgressBar` / `SetPlayerProgressBarBlink`
```pawn
stock BlinkPlayerProgressBar(playerid, barid, interval = PB_BLINK_DEFAULT, duration = 0, colour = 0, bordercolour = 0);
#define SetPlayerProgressBarBlink BlinkPlayerProgressBar
#define SetPlayerProgressBarFlash BlinkPlayerProgressBar
```
Alternates bar color and/or visibility in a pulsating alert pattern.
* **`interval`:** Flash cycle period in ms (defaults to `250` ms).
* **`duration`:** Auto-stop timer in ms (`0` = infinite).
* **`colour`:** Alternate phase color (`0` = toggle visibility).
* **`bordercolour`:** Alternate phase border color.
* **Returns:** `1` on success, `0` on failure.

---

### `StopPlayerProgressBarBlink` / `bool:IsPlayerProgressBarBlinking`
```pawn
stock StopPlayerProgressBarBlink(playerid, barid);
stock bool:IsPlayerProgressBarBlinking(playerid, barid);
```
*(Aliases: `StopPlayerProgressBarFlash`, `IsPlayerProgressBarFlashing`)*
Halts blinking alert and queries active state.
* **Returns:** `1` on success, `0` on failure.

---

## 6. HUD Value & Text Labels

### `SetPlayerProgressBarLabel`
```pawn
stock SetPlayerProgressBarLabel(
    playerid,
    barid,
    bool:enable,
    const template[] = "{PERCENT}%",
    colour = 0xFFFFFFFF,
    alignment = 2,
    font = 1,
    Float:scaleX = 0.0, Float:scaleY = 0.0,
    Float:offsetX = 0.0, Float:offsetY = 0.0,
    bool:followColour = false,
    orientation = PB_LABEL_ORIENT_AUTO
);
```
Attaches or reconfigures an integrated HUD text label.
* **`enable`:** `true` to display, `false` to disable.
* **`template`:** String supporting `{PERCENT}`, `{PCT}`, `{VALUE}`, `{VAL}`, `{MAX}`, `{MIN}`.
* **`colour`:** RGBA font color (`0xFFFFFFFF` default). Passing `colour = 0` automatically enables `followColour`.
* **`alignment`:** `1` (Left), `2` (Center - default), `3` (Right).
* **`font`:** GTA TextDraw font ($0$ to $3$). Bypasses client font caching automatically.
* **`scaleX`, `scaleY`:** Manual letter scaling (`0.0` enables Auto-Scale).
* **`offsetX`, `offsetY`:** Relative pixel offset from bar geometric center.
* **`followColour`:** `true` to dynamically track the active bar color and gradients.
* **`orientation`:** `PB_LABEL_ORIENT_AUTO` (0), `PB_LABEL_ORIENT_HORIZONTAL` (1), `PB_LABEL_ORIENT_VERTICAL` (2).
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelText` / `GetPlayerProgressBarLabelText`
```pawn
stock SetPlayerProgressBarLabelText(playerid, barid, const template[]);
stock GetPlayerProgressBarLabelText(playerid, barid, dest[], size = sizeof dest);
```
Updates or retrieves the template format string.
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelColour` / `GetPlayerProgressBarLabelColour`
```pawn
stock SetPlayerProgressBarLabelColour(playerid, barid, colour);
stock GetPlayerProgressBarLabelColour(playerid, barid);
```
*(Aliases: `SetPlayerProgressBarLabelColor`, `GetPlayerProgressBarLabelColor`)*
Sets or retrieves label font color. Passing `colour = 0` enables dynamic color tracking.
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelFollowColour` / `bool:GetPlayerProgressBarLabelFollowColour`
```pawn
stock SetPlayerProgressBarLabelFollowColour(playerid, barid, bool:follow);
stock bool:GetPlayerProgressBarLabelFollowColour(playerid, barid);
```
*(Aliases: `SetPlayerProgressBarLabelFollowColor`, `GetPlayerProgressBarLabelFollowColor`)*
Configures whether the text label dynamically tracks the bar's active fill color.
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelOrientation` / `GetPlayerProgressBarLabelOrientation`
```pawn
stock SetPlayerProgressBarLabelOrientation(playerid, barid, orientation = PB_LABEL_ORIENT_AUTO);
stock GetPlayerProgressBarLabelOrientation(playerid, barid);
```
Configures text orientation: `PB_LABEL_ORIENT_AUTO` (0, stacks vertically on narrow/tall bars), `PB_LABEL_ORIENT_HORIZONTAL` (1), or `PB_LABEL_ORIENT_VERTICAL` (2).
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelAutoScale` / `bool:GetPlayerProgressBarLabelAutoScale`
```pawn
stock SetPlayerProgressBarLabelAutoScale(playerid, barid, bool:autoScale);
stock bool:IsPlayerProgressBarLabelAutoScale(playerid, barid);
#define GetPlayerProgressBarLabelAutoScale IsPlayerProgressBarLabelAutoScale
```
Toggles automatic geometric containment bounding so text never spills outside the bar boundary.
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelScale` / `GetPlayerProgressBarLabelScale`
```pawn
stock SetPlayerProgressBarLabelScale(playerid, barid, Float:scaleX, Float:scaleY);
stock GetPlayerProgressBarLabelScale(playerid, barid, &Float:scaleX, &Float:scaleY);
```
Manually sets or retrieves letter dimensions (setting manual scale disables Auto-Scale).
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarLabelOffset` / `GetPlayerProgressBarLabelOffset`
```pawn
stock SetPlayerProgressBarLabelOffset(playerid, barid, Float:offsetX, Float:offsetY);
stock GetPlayerProgressBarLabelOffset(playerid, barid, &Float:offsetX, &Float:offsetY);
```
Sets or retrieves pixel anchor offsets relative to the bar geometric center.
* **Returns:** `1` on success, `0` on failure.

---

### `GetPlayerProgressBarLabelAlignment` / `GetPlayerProgressBarLabelFont`
```pawn
stock GetPlayerProgressBarLabelAlignment(playerid, barid);
stock GetPlayerProgressBarLabelFont(playerid, barid);
```
*(Alias: `GetPlayerProgressBarLabelAlign`)*
Retrieves text alignment (`1` = Left, `2` = Center, `3` = Right) or GTA SA font ID ($0$ to $3$).
* **Returns:** integer value, or `0` on failure.

---

### `bool:IsPlayerProgressBarLabelEnabled`
```pawn
stock bool:IsPlayerProgressBarLabelEnabled(playerid, barid);
```
Checks if the bar currently has an active text label.
* **Returns:** `true` if enabled, `false` otherwise.

---

## 7. Styles, Segments & Radial Rings

### `SetPlayerProgressBarStyle` / `GetPlayerProgressBarStyle`
```pawn
stock SetPlayerProgressBarStyle(playerid, barid, style = PB_STYLE_BAR, segments = PB_RING_SEGMENTS, Float:segmentscale = PB_RING_SEGMENT_SCALE);
stock GetPlayerProgressBarStyle(playerid, barid);
```
Changes the bar rendering architecture on the fly (`PB_STYLE_BAR`, `PB_STYLE_RING`, `PB_STYLE_CIRCLE`).
* **Returns:** `1` on success, `0` on failure.

---

### `SetPlayerProgressBarSegments` / `GetPlayerProgressBarSegments`
```pawn
stock SetPlayerProgressBarSegments(playerid, barid, segments);
stock GetPlayerProgressBarSegments(playerid, barid);
```
Sets or retrieves the radial ring segment count ($4$ to $60$).
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarSegments` returns segment count).

---

### `SetPlayerProgressBarRingScale` / `Float:GetPlayerProgressBarRingScale`
```pawn
stock SetPlayerProgressBarRingScale(playerid, barid, Float:scale);
stock Float:GetPlayerProgressBarRingScale(playerid, barid);
#define SetPlayerProgressBarSegmentScale SetPlayerProgressBarRingScale
#define GetPlayerProgressBarSegmentScale GetPlayerProgressBarRingScale
```
Sets or retrieves the radial chit dot scale multiplier ($0.10$ to $3.00$).
* **Returns:** `1` on success, `0` on failure (`GetPlayerProgressBarRingScale` returns `Float:scale`).

---

## 8. Diagnostic & Capacity Utilities

### `bool:PB_CanAllocatePlayerTextDraws`
```pawn
stock bool:PB_CanAllocatePlayerTextDraws(playerid, count);
```
Verifies whether `count` PlayerTextDraws can safely be allocated for `playerid` without exhausting engine capacity or causing visual glitching.
* **open.mp**: Traverses handles using native `IsValidPlayerTextDraw` in $O(N)$ with zero allocations.
* **SA-MP 0.3.7**: Performs a live targeted probe testing only up to `count` handles in RAM (e.g. 4 handles for a standard bar instead of scanning all 256), ensuring 100% real-time accuracy without stale cache or network packets.
* **Returns:** `true` if all `count` handles are free, `false` otherwise.

---

### `PB_GetFreePlayerTextDraws`
```pawn
stock PB_GetFreePlayerTextDraws(playerid);
```
Calculates the number of unallocated PlayerTextDraw slots available to `playerid`.
* **open.mp**: Directly counts unallocated slots.
* **SA-MP 0.3.7**: Probes available handles with an automatic 1.0-second TTL cache to prevent CPU overhead during consecutive UI layout updates.
* **Returns:** Total number of free PlayerTextDraw slots.

---

### `PB_GetUsedPlayerTextDraws`
```pawn
stock PB_GetUsedPlayerTextDraws(playerid);
```
Calculates the number of PlayerTextDraw slots currently consumed by `playerid` across all gamemodes and filterscripts.
* **Returns:** Total number of active PlayerTextDraw slots.

---

### `PB_GetBarRequiredTextDraws`
```pawn
stock PB_GetBarRequiredTextDraws(style, segments, bool:hasLabel = false);
```
Computes the exact number of PlayerTextDraw elements required by a bar given its visual style, segment count, and label presence.
* **Returns:** TextDraw count needed (e.g., `3` for plain bar, `4` for bar with label, `segments + (border?1:0) + (bg?1:0)` for radial rings).

---

### `PB_GetMinDimensions`
```pawn
stock PB_GetMinDimensions(style, &Float:minW, &Float:minH);
```
Retrieves the minimum allowable outer width and height for the given bar style (`PB_STYLE_BAR`, `PB_STYLE_RING`, `PB_STYLE_CIRCLE`).

---

### `PB_ClampSize`
```pawn
stock PB_ClampSize(style, &Float:width, &Float:height);
```
Enforces style minimum boundaries on `width` and `height`, preventing invisible or distorted bar geometry.

---

## 9. Constants & Enumerations

### Bar Styles (`ProgressBarStyle`)
| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_STYLE_BAR` | `0` | Sleek linear rectangular progress bar rendered with 3 hardware-accelerated sprites (`LD_SPAC:white`). |
| `PB_STYLE_RING` | `1` | Segmented radial odometer/dial composed of circular disc chits (`LD_BEAT:chit`) filling sequentially. |
| `PB_STYLE_CIRCLE` | `2` | Smooth concentric expanding disc gauge (`LD_BEAT:chit`) expanding radially from the center outward. |

### Fill Directions (`BarDirection`)
| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_DIR_RIGHT` | `0` | Fills horizontally from left to right *(Default)*. |
| `PB_DIR_LEFT` | `1` | Fills horizontally from right to left. |
| `PB_DIR_UP` | `2` | Fills vertically from bottom to top. |
| `PB_DIR_DOWN` | `3` | Fills vertically from top to bottom. |

### Label Orientations
| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_LABEL_ORIENT_AUTO` | `0` | Automatically stacks text vertically with `~n~` linebreaks if bar is tall & narrow. |
| `PB_LABEL_ORIENT_HORIZONTAL` | `1` | Forces standard horizontal text layout. |
| `PB_LABEL_ORIENT_VERTICAL` | `2` | Forces vertical character stacking. |

### Gradient Polarities
| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_GRAD_STANDARD` | `0` | Red at 0%, Amber at 50%, Green at 100% (Standard Health/Stamina mode). |
| `PB_GRAD_INVERTED` | `1` | Green at 0%, Amber at 50%, Red at 100% (Heat/Threat/Pressure mode). |

### Special Values
| Constant | Value | Description |
| :--- | :---: | :--- |
| `INVALID_PLAYER_BAR_ID` | `-1` | Returned when bar creation fails or an invalid bar handle is referenced. |
| `INVALID_PLAYER_BAR_VALUE` | `Float:0xFFFFFFFF` | Returned when querying values on an invalid bar handle. |

### Version Identifiers
| Constant | Type | Value | Description |
| :--- | :---: | :---: | :--- |
| `PROGRESSBAR_VERSION_MAJOR` | `int` | `2` | Major version component. |
| `PROGRESSBAR_VERSION_MINOR` | `int` | `2` | Minor version component. |
| `PROGRESSBAR_VERSION_PATCH` | `int` | `0` | Patch version component. |
| `PROGRESSBAR_VERSION_STRING` | `string` | `"2.2.0"` | SemVer version string literal. |

---

## 10. Compile-Time Configuration Defines

You can customize the following compile-time constants before including `<ProgressBar>` to tailor server memory and execution capacity:

| Constant | Default Value | Unit / Constraint | Description |
| :--- | :---: | :---: | :--- |
| `PB_MAX_BARS` | `64` | Slots per player | Maximum number of concurrent progress bars allocated per player session. |
| `PB_MAX_TDS` | `256` | TextDraw IDs | Internal delta-caching array size for ownership and ring segments. |
| `PB_TICK_RATE` | `33` | Milliseconds (30 FPS) | Tick interval for smooth value interpolation (`InterpolatePlayerProgressBarValue`). |
| `PB_AUTOFILL_TICK` | `50` | Milliseconds | Tick interval for cyclic auto-fill animation loops. |
| `PB_BORDER_Y_RATIO` | `1.25` | Multiplier | Vertical multiplier compensating for 16:9 TextDraw widescreen coordinate stretching. |
| `PB_BORDER_NONE` | `0.00` | Virtual pixels | Completely borderless bar (`0.00` thickness). |
| `PB_BORDER_MIN` | `0.50` | Virtual pixels | Minimum allowable border thickness (when border enabled). |
| `PB_BORDER_MAX` | `5.00` | Virtual pixels | Maximum allowable border thickness. |
| `PB_RING_MIN` | `4` | Segments | Minimum segment count allowable for segmented radial rings (`PB_STYLE_RING`). |
| `PB_RING_MAX` | `60` | Segments | Maximum segment count allowable for segmented radial rings (`PB_STYLE_RING`). |
| `PB_RING_SEGMENTS` | `24` | Segments | Default segment count for new radial rings. |
| `PB_RING_SCALE_MIN` | `0.10` | Multiplier | Minimum radial dot scale multiplier. |
| `PB_RING_SCALE_MAX` | `3.00` | Multiplier | Maximum radial dot scale multiplier. |
| `PB_RING_SEGMENT_SCALE` | `1.00` | Multiplier | Default dot chit scale ($0.10$ to $3.00$). |
| `PB_BLINK_MIN` | `50` | Milliseconds | Minimum safe threshold for blinking alerts to prevent timer flooding. |
| `PB_BLINK_MAX` | `60000` | Milliseconds | Maximum allowable threshold for blinking alerts. |
| `PB_CHIT_SCALE` | `1.50` | Multiplier | Native sprite scaling factor correcting `LD_BEAT:chit` internal texture margins. |
| `PB_BAR_MIN_WIDTH` | `3.0` | Virtual pixels | Minimum allowable width for rectangular linear bars (`PB_STYLE_BAR`). |
| `PB_BAR_MIN_HEIGHT` | `3.0` | Virtual pixels | Minimum allowable height for rectangular linear bars (`PB_STYLE_BAR`). |
| `PB_CIRCLE_MIN_WIDTH` | `8.0` | Virtual pixels | Minimum allowable width for circular gauges (`PB_STYLE_CIRCLE`). |
| `PB_CIRCLE_MIN_HEIGHT` | `8.0` | Virtual pixels | Minimum allowable height for circular gauges (`PB_STYLE_CIRCLE`). |
| `PB_RING_MIN_WIDTH` | `16.0` | Virtual pixels | Minimum allowable width for segmented radial rings (`PB_STYLE_RING`). |
| `PB_RING_MIN_HEIGHT` | `16.0` | Virtual pixels | Minimum allowable height for segmented radial rings (`PB_STYLE_RING`). |

```pawn
// Example: Customizing server capacity before including ProgressBar
#define PB_MAX_BARS 128
#define PB_TICK_RATE 25 // 40 FPS lerp interpolation
#include <open.mp>
#include <ProgressBar>
```
