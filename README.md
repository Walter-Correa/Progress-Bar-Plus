# Progress Bar Plus

[![GitHub release](https://img.shields.io/github/v/release/Walter-Correa/Progress-Bar-Plus?include_prereleases&color=blue)](https://github.com/Walter-Correa/Progress-Bar-Plus/releases)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)
[![Platform](https://img.shields.io/badge/platform-SA--MP%20%7C%20open.mp-orange.svg)](https://open.mp)

**Progress Bar Plus** is a high-performance, modern visual progress bar and radial gauge library engineered specifically for **San Andreas Multiplayer (SA-MP)** and **open.mp**. It enables Pawn scripts to render pixel-perfect, flicker-free HUD progress bars, segmented radial rings (odometer style), and concentric expanding circular gauges with exact sub-pixel borders, smooth auto-fill animations, and dynamic pulsing/blinking alerts.

> [!NOTE]
> This project is conceptually inspired by [@Southclaws](https://github.com/Southclaws)'s [progress2](https://github.com/Southclaws/progress2). It has been completely rebuilt from the ground up as a standalone, modern visual suite, introducing hardware-accelerated sprite rendering (`LD_SPAC:white` and `LD_BEAT:chit`), $16:9$ widescreen aspect-ratio border compensation, zero-flicker TextDraw recycling, open.mp native repositioning, smart bandwidth delta caching, and advanced animated states.

---

## Highlights & Key Features

* **Exact Widescreen Aspect-Ratio Border Correction ($16:9$ Geometry):**
  * Traditional SA-MP TextDraw coordinates span a virtual canvas of $640 \times 448$ units. On a standard $16:9$ monitor ($1920 \times 1080$), $1.0$ TextDraw width equals $3.00\text{ px}$, whereas $1.0$ height equals only $2.41\text{ px}$.
  * **Progress Bar Plus** features an automatic $1.25\times$ vertical border multiplier (`PB_BORDER_Y_RATIO = 1.25`). This guarantees that top and bottom borders render with the exact same physical screen pixel thickness as side borders (e.g., exactly $3\text{ px}$ on all four edges).
  * Automatically clamps borders within safe bounds (`PB_BORDER_MIN` to `PB_BORDER_MAX`) and ensures the inner content area is never truncated.

* **Three Distinct Visual Bar Styles:**
  * **`PB_STYLE_BAR` (Linear / Rectangular Bar):**
    A sleek, straight progress bar built with 3 sprite TextDraws (`LD_SPAC:white`): outer border background, semi-transparent inner fill, and active value progress. Supports 4 fill directions (`PB_DIR_RIGHT`, `PB_DIR_LEFT`, `PB_DIR_UP`, `PB_DIR_DOWN`).
  * **`PB_STYLE_RING` (Segmented Radial Odometer / Dial):**
    An elliptical ring of round disc segments (`LD_BEAT:chit`) that light up sequentially starting from 12 o'clock ($-90^\circ$). Supports clockwise or counter-clockwise filling, configurable segment counts ($4$ to $60$, default $24$), and custom segment scaling multipliers.
  * **`PB_STYLE_CIRCLE` (Concentric Expanding Gauge):**
    A circular gauge composed of 3 concentric disc sprites (`LD_BEAT:chit`) expanding smoothly from the geometric center outward according to current progress. Ideal for skill cooldowns, radar pings, power meters, and circular countdown timers.

* **Flicker-Free TextDraw Recycling Engine:**
  * Outdated approaches destroy and recreate TextDraws on every value change, causing noticeable screen flickering, frame hitches, and rapid TextDraw ID pool exhaustion.
  * **Progress Bar Plus** retains persistent PlayerTextDraw handles. On **open.mp**, it dynamically resizes and repositions TextDraws in-place using `PlayerTextDrawSetPos` and `PlayerTextDrawTextSize` without ever destroying them.

* **Z-Index Layer Preservation on Zero Values:**
  * When a progress bar reaches zero ($0.0$), the inner progress element is hidden (`PlayerTextDrawHide`) rather than destroyed.
  * Because SA-MP draws TextDraws in their creation order, destroying and recreating elements later would cause them to render in front of labels, icons, or frames created after the bar. By preserving the handle and simply hiding it, the original UI layering order remains pristine.

* **Delta Network Optimization & Bandwidth Caching:**
  * For segmented rings, the include maintains an internal state cache per player (`PB_TDOwner`, `PB_TDPart`, `PB_TDColour`).
  * When updating values or blinking, only the segments whose state or color has actually changed are transmitted across the network. This prevents open.mp `ackslimit` packet warnings and ensures zero network lag during high-frequency updates.

* **Dynamic Auto-Fill Animation Engine:**
  * Built-in cyclic animation engine (`AutoFillPlayerProgressBar`) that smoothly animates the bar up to a target maximum, holds at the peak, recedes back to the baseline value, and pauses at the base.
  * The bar's true underlying value is preserved under the hood. Perfect for interactive lockpicking, stamina regeneration previews, fuel pump dispensers, or ability charging meters.

* **Multi-Phase Blinking & Critical Alerts:**
  * Highly customizable alert engine (`BlinkPlayerProgressBar`) with millisecond interval tuning, duration timeouts, and independent inner/border color overrides.
  * Bars can pulse between full visibility and transparency or toggle to an alternate highlight color (e.g., flashing bright red on low health or flashing yellow on low fuel).

* **Automatic Lifecycle & Memory Garbage Collection:**
  * Advanced Library Standard (ALS) hooks on `OnPlayerDisconnect` and `OnFilterScriptExit` automatically cancel active timers, free bar structures, and clear TextDraw ownership maps across player sessions, preventing memory leaks.

---

### Comparison: Progress Bar Plus vs. progress2

| Feature / Capability | progress2 (Southclaws) | Progress Bar Plus |
| :--- | :--- | :--- |
| **Rendering Primitive** | Text box padding using character `"_"` (`PlayerTextDrawUseBox`) | Hardware-accelerated native sprites (`LD_SPAC:white` & `LD_BEAT:chit`) |
| **Widescreen ($16:9$) Geometry** | Uncompensated coordinate offsets (borders appear thicker horizontally on $16:9$) | ✅ Exact $1.25\times$ vertical multiplier (`PB_BORDER_Y_RATIO`), uniform physical pixel thickness |
| **Supported Visual Styles** | 1 style (linear horizontal/vertical rectangular bar) | 3 styles (`PB_STYLE_BAR`, `PB_STYLE_RING` segmented radial odometer, `PB_STYLE_CIRCLE` concentric gauge) |
| **Standard SA-MP Value Updates** | Destroys & recreates textdraw on every update when `PlayerTextDrawSetPos` is unavailable | ✅ Zero-flicker dynamic sizing via `PlayerTextDrawTextSize`; never destroys textdraw on updates |
| **Zero-Value Z-Order Preservation** | Destroys textdraw on $0.0$; subsequent recreate re-renders bar on top of newer HUD layers | ✅ Hides element (`PlayerTextDrawHide`) on $0.0$; strictly preserves creation z-order |
| **External Dependencies** | Requires `YSI-Includes` (`y_iterate`) and `sampctl` toolchains in modern versions | ✅ Completely standalone and zero-dependency (only standard `<a_samp>` or `<open.mp>`) |
| **Dynamic Visual Animations** | ❌ None (requires external gamemode timers, step loops, and tracking variables) | ✅ Built-in cyclic auto-fill engine (`AutoFillPlayerProgressBar`) preserving base progress |
| **Pulsing & Critical Alerts** | ❌ None (requires manual gamemode timer and color toggling logic) | ✅ Built-in multi-phase blinking engine (`BlinkPlayerProgressBar`) with independent colors |
| **Multi-Element Network Caching** | Not applicable (only supports basic 3-textdraw rectangular bars) | ✅ Per-segment delta cache (`PB_TDColour`), updating only modified dots to prevent packet flooding |
| **Tagging & Type Safety** | Requires strict `PlayerBar:` tag (produces tag mismatch warnings if handled as raw integer) | ✅ Standard integer IDs with backward compatibility tag/direction macros (zero compiler warnings) |

---

## Installation

### 1. File Placement

Copy `ProgressBar.inc` into your server's include folder:
* **Pawno:** `pawno/include/ProgressBar.inc`
* **open.mp / Qawno:** `qawno/include/ProgressBar.inc`

### 2. Script Inclusion

Add the include near the top of your gamemode or filterscript, after `<a_samp>`:

```pawn
#include <a_samp>
#include <ProgressBar>
```

---

## Configuration & Compile-Time Defines

You can override any of the following definitions before including `<ProgressBar>` to tailor the library to your server's exact specifications:

| Constant | Default Value | Range / Unit | Description |
| :--- | :---: | :---: | :--- |
| `MAX_PLAYER_BARS` | `MAX_PLAYER_TEXT_DRAWS / 3` | $1$ – $85$ | Maximum simultaneous progress bars allocated per player. |
| `PB_DEFAULT_COLOUR` | `0xE74C3CFF` | RGBA Hex | Default bar color (modern flat red). |
| `PB_BORDER_DEFAULT` | `1.0` | Float (units) | Default border thickness on side edges. |
| `PB_BORDER_MIN` | `0.5` | Float (units) | Minimum allowed border thickness. |
| `PB_BORDER_MAX` | `5.0` | Float (units) | Maximum allowed border thickness. |
| `PB_BORDER_Y_RATIO` | `1.25` | Float (ratio) | Vertical border scaling factor to match $16:9$ pixel aspect ratio. |
| `PB_MIN_INNER` | `1.0` | Float (units) | Minimum guaranteed inner fill area preserved inside borders. |
| `PB_BLINK_DEFAULT` | `250` | Milliseconds | Default toggle interval for blinking bars. |
| `PB_BLINK_MIN` | `50` | Milliseconds | Minimum allowed blink toggle interval. |
| `PB_BLINK_MAX` | `60000` | Milliseconds | Maximum allowed blink toggle interval. |
| `PB_RING_SEGMENTS` | `24` | Segments | Default segment count for `PB_STYLE_RING`. |
| `PB_RING_SEGMENT_SCALE` | `1.0` | Float (scale) | Default relative size multiplier for ring segment dots. |
| `PB_RING_MIN` | `4` | Segments | Minimum allowed segment count for rings. |
| `PB_RING_MAX` | `60` | Segments | Maximum allowed segment count for rings. |
| `PB_AUTOFILL_TICK` | `50` | Milliseconds | Timer tick rate for smooth auto-fill animations. |
| `PB_AUTOFILL_RISE` | `1000` | Milliseconds | Duration of the auto-fill upward rising phase. |
| `PB_AUTOFILL_HOLD_TOP` | `400` | Milliseconds | Pause duration when auto-fill reaches the peak. |
| `PB_AUTOFILL_FALL` | `1000` | Milliseconds | Duration of the auto-fill downward falling phase. |
| `PB_AUTOFILL_HOLD_BASE` | `300` | Milliseconds | Pause duration when auto-fill returns to the baseline. |

---

## API Reference

### Constants & Enumerations

#### `BarDirection`
Determines the fill direction for linear bars and the angular rotation direction for segmented rings:
| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_DIR_RIGHT` | `0` | Fills from left to right (linear) or clockwise from 12 o'clock (ring). |
| `PB_DIR_LEFT` | `1` | Fills from right to left (linear) or counter-clockwise (ring). |
| `PB_DIR_UP` | `2` | Fills from bottom to top (linear) or counter-clockwise (ring). |
| `PB_DIR_DOWN` | `3` | Fills from top to bottom (linear) or clockwise (ring). |

*(Aliases: `BAR_DIRECTION_RIGHT`, `BAR_DIRECTION_LEFT`, `BAR_DIRECTION_UP`, `BAR_DIRECTION_DOWN`)*

#### `ProgressBarStyle`
Specifies the geometric rendering style of the progress bar:
| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_STYLE_BAR` | `0` | Standard rectangular bar using sprite `LD_SPAC:white`. |
| `PB_STYLE_RING` | `1` | Segmented radial ring composed of circular dots (`LD_BEAT:chit`). |
| `PB_STYLE_CIRCLE` | `2` | Solid circle growing from the geometric center (`LD_BEAT:chit`). |

#### Special Return Values
| Constant | Value | Description |
| :--- | :---: | :--- |
| `INVALID_PLAYER_BAR_ID` | `-1` | Returned when bar creation fails or bar ID is invalid. |
| `INVALID_PLAYER_BAR_VALUE` | `Float:0xFFFFFFFF` | Returned by float getters when querying an invalid bar. |

---

### Functions

#### 1. Creation & Lifecycle

```pawn
stock bool:IsValidPlayerProgressBar(playerid, barid);
```
Checks whether `barid` is an active, valid progress bar allocated for `playerid`.
* **Returns:** `true` if valid, `false` otherwise.

```pawn
stock CreatePlayerProgressBar(playerid, Float:x, Float:y, Float:width = 60.0, Float:height = 8.0, colour = PB_DEFAULT_COLOUR, Float:max = 100.0, direction = PB_DIR_RIGHT, Float:border = PB_BORDER_DEFAULT, bordercolour = 0, style = PB_STYLE_BAR, segments = PB_RING_SEGMENTS, Float:segmentscale = PB_RING_SEGMENT_SCALE);
```
Creates a new progress bar instance for `playerid`. The bar is created initially hidden.
* **`x`, `y`:** Top-left coordinates in standard TextDraw units ($640 \times 448$).
* **`width`, `height`:** Total dimensions of the bar bounding box (including borders). Defaults to modern $60.0 \times 8.0$.
* **`colour`:** Bar foreground color in RGBA format (defaults to `0xE74C3CFF`).
* **`max`:** Upper limit value representing 100% fill.
* **`direction`:** Fill orientation (`PB_DIR_RIGHT`, `PB_DIR_LEFT`, `PB_DIR_UP`, `PB_DIR_DOWN`).
* **`border`:** Side border thickness (clamped between `PB_BORDER_MIN` and `PB_BORDER_MAX`).
* **`bordercolour`:** RGBA color for the border. Passing `0` defaults to black with the bar's alpha transparency.
* **`style`:** Visual geometry (`PB_STYLE_BAR`, `PB_STYLE_RING`, or `PB_STYLE_CIRCLE`).
* **`segments`:** Number of segment dots (used only by `PB_STYLE_RING`, $4$ to $60$).
* **`segmentscale`:** Relative size multiplier for segment dots in `PB_STYLE_RING`.
* **Returns:** The allocated bar ID ($0$ to `MAX_PLAYER_BARS - 1`), or `INVALID_PLAYER_BAR_ID` on failure.

```pawn
stock DestroyPlayerProgressBar(playerid, barid);
```
Stops any active blinking or auto-fill animations, destroys all underlying TextDraws, and frees the bar ID slot for the player.
* **Returns:** `1` on success, `0` if the player or bar is invalid.

```pawn
stock DestroyAllPlayerProgressBars(playerid);
```
Destroys every progress bar currently assigned to the given player.
* **Returns:** `1` on success, `0` if the player ID is out of range.

---

#### 2. Visibility Management

```pawn
stock ShowPlayerProgressBar(playerid, barid);
```
Renders the progress bar visible on the player's screen.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock HidePlayerProgressBar(playerid, barid);
```
Hides the progress bar from the player's screen. All properties, values, colors, and animation states are preserved.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock bool:IsPlayerProgressBarVisible(playerid, barid);
```
Queries whether the progress bar is currently shown to the player.
* **Returns:** `true` if visible, `false` otherwise.

---

#### 3. Value & Range Control

```pawn
stock SetPlayerProgressBarValue(playerid, barid, Float:value);
```
Updates the current progress value. The value is automatically clamped between `0.0` and `max`.
> [!TIP]
> If the bar was previously hidden, calling `SetPlayerProgressBarValue` will automatically reveal it.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock Float:GetPlayerProgressBarValue(playerid, barid);
```
Retrieves the current progress value.
* **Returns:** The current `Float` value, or `INVALID_PLAYER_BAR_VALUE` if invalid.

```pawn
stock SetPlayerProgressBarMaxValue(playerid, barid, Float:max = 100.0);
```
Updates the maximum value that represents 100% fill. If the current value or auto-fill target exceeds this new maximum, it is clamped accordingly.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock Float:GetPlayerProgressBarMaxValue(playerid, barid);
```
Retrieves the maximum value capacity of the bar.
* **Returns:** The maximum `Float` value, or `INVALID_PLAYER_BAR_VALUE` if invalid.

---

#### 4. Positioning & Dimensions

```pawn
stock SetPlayerProgressBarPos(playerid, barid, Float:x, Float:y);
```
Repositions the bar's top-left corner on the screen.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock GetPlayerProgressBarPos(playerid, barid, &Float:x, &Float:y);
```
Retrieves the current top-left screen position into `x` and `y`.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock SetPlayerProgressBarSize(playerid, barid, Float:width, Float:height);
```
Resizes both the width and height of the bar simultaneously.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock GetPlayerProgressBarSize(playerid, barid, &Float:width, &Float:height);
```
Stores the overall width and height of the bar into `width` and `height`.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock SetPlayerProgressBarWidth(playerid, barid, Float:width);
stock Float:GetPlayerProgressBarWidth(playerid, barid);
```
Sets or retrieves the width of the progress bar.

```pawn
stock SetPlayerProgressBarHeight(playerid, barid, Float:height);
stock Float:GetPlayerProgressBarHeight(playerid, barid);
```
Sets or retrieves the height of the progress bar.

```pawn
stock SetPlayerProgressBarDirection(playerid, barid, direction = PB_DIR_RIGHT);
stock GetPlayerProgressBarDirection(playerid, barid);
```
Sets or gets the fill/rotation direction (`PB_DIR_RIGHT`, `PB_DIR_LEFT`, `PB_DIR_UP`, `PB_DIR_DOWN`).

---

#### 5. Style & Segment Configuration

```pawn
stock SetPlayerProgressBarStyle(playerid, barid, style = PB_STYLE_BAR, segments = PB_RING_SEGMENTS, Float:segmentscale = PB_RING_SEGMENT_SCALE);
```
Switches the bar's visual style (`PB_STYLE_BAR`, `PB_STYLE_RING`, or `PB_STYLE_CIRCLE`) while preserving all values, colors, visibility, and blinking state.
* **`segments`:** Number of radial segments if converting to `PB_STYLE_RING` ($4$ to $60$).
* **`segmentscale`:** Relative dot size scale for `PB_STYLE_RING`.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock GetPlayerProgressBarStyle(playerid, barid);
```
Returns the active style enum (`PB_STYLE_BAR`, `PB_STYLE_RING`, or `PB_STYLE_CIRCLE`).

```pawn
stock GetPlayerProgressBarSegments(playerid, barid);
```
Returns the number of segments configured for a ring bar.

```pawn
stock SetPlayerProgressBarRingScale(playerid, barid, Float:scale);
stock Float:GetPlayerProgressBarRingScale(playerid, barid);
```
Configures or retrieves the segment dot size scale factor for `PB_STYLE_RING` bars ($> 0.0$).

---

#### 6. Colors & Border Styling

```pawn
stock SetPlayerProgressBarColour(playerid, barid, colour = PB_DEFAULT_COLOUR);
stock GetPlayerProgressBarColour(playerid, barid);
```
Sets or gets the primary bar color (RGBA). The subtle translucent inner background color is dynamically blended using a 30% alpha profile.
*(Aliases: `SetPlayerProgressBarColor`, `GetPlayerProgressBarColor`)*

```pawn
stock SetPlayerProgressBarBorder(playerid, barid, Float:border = PB_BORDER_DEFAULT);
stock Float:GetPlayerProgressBarBorder(playerid, barid);
```
Sets or gets the side border thickness. Top and bottom borders automatically scale by `PB_BORDER_Y_RATIO (1.25)`.

```pawn
stock SetPlayerProgressBarBorderColor(playerid, barid, bordercolor = 0);
stock GetPlayerProgressBarBorderColor(playerid, barid);
```
Sets or gets the border color (RGBA). Passing `0` sets the border to semi-transparent black matching the bar's alpha.
*(Aliases: `SetPlayerProgressBarBorderColour`, `GetPlayerProgressBarBorderColour`)*

---

#### 7. Dynamic Auto-Fill Animations

```pawn
stock AutoFillPlayerProgressBar(playerid, barid, Float:maxvalue = 0.0);
```
Starts a smooth pulsating preview animation that rises from the bar's current value up to `maxvalue`, holds, recedes back down, holds, and repeats continuously.
* **`maxvalue`:** Peak animation threshold. Passing `0.0` or omitting it defaults to the bar's maximum value.
* The true underlying value remains untouched; calling `SetPlayerProgressBarValue` smoothly adjusts the animation baseline in real time.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock StopAutoFillPlayerProgressBar(playerid, barid);
```
Terminates the auto-fill animation and immediately restores the display to the bar's actual progress value.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock bool:IsPlayerProgressBarAutoFilling(playerid, barid);
```
Queries whether the bar is currently running an active auto-fill animation.
* **Returns:** `true` if auto-filling, `false` otherwise.

---

#### 8. Pulsing & Blinking Alerts

```pawn
stock BlinkPlayerProgressBar(playerid, barid, interval = PB_BLINK_DEFAULT, duration = 0, colour = 0, bordercolour = 0);
```
Activates high-visibility blinking for alerts and warnings.
* **`interval`:** Milliseconds between each toggle phase (`PB_BLINK_MIN` to `PB_BLINK_MAX`).
* **`duration`:** Total duration in milliseconds before automatically stopping ($0$ for continuous until manual stop).
* **`colour`:** Alternate inner color while lit. Passing `0` toggles the bar on and off in its existing color.
* **`bordercolour`:** Alternate border color while lit. Passing `0` keeps the existing border color intact.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock StopPlayerProgressBarBlink(playerid, barid);
```
Stops blinking immediately and restores normal colors and visibility.
* **Returns:** `1` on success, `0` on failure.

```pawn
stock bool:IsPlayerProgressBarBlinking(playerid, barid);
```
Checks if the bar is currently in a blinking state.
* **Returns:** `true` if blinking, `false` otherwise.

---

## Usage Examples

### 1. Dynamic Health HUD with Critical Low-Health Red Pulse

```pawn
#include <a_samp>
#include <ProgressBar>

new gPlayerHealthBar[MAX_PLAYERS] = {INVALID_PLAYER_BAR_ID, ...};

public OnPlayerConnect(playerid)
{
    // Create a 60x8 linear health bar at the top-right corner
    gPlayerHealthBar[playerid] = CreatePlayerProgressBar(
        playerid, 
        548.0, 65.0, 
        60.0, 8.0, 
        0xE74C3CFF, // Crimson Red
        100.0, 
        PB_DIR_RIGHT, 
        1.2
    );
    ShowPlayerProgressBar(playerid, gPlayerHealthBar[playerid]);
    return 1;
}

public OnPlayerUpdate(playerid)
{
    if (gPlayerHealthBar[playerid] != INVALID_PLAYER_BAR_ID)
    {
        new Float:hp;
        GetPlayerHealth(playerid, hp);
        SetPlayerProgressBarValue(playerid, gPlayerHealthBar[playerid], hp);

        // Flash rapid warning alert when health drops below 25%
        if (hp <= 25.0 && !IsPlayerProgressBarBlinking(playerid, gPlayerHealthBar[playerid]))
        {
            // Blink every 150ms in bright white, border blinking red
            BlinkPlayerProgressBar(playerid, gPlayerHealthBar[playerid], 150, 0, 0xFFFFFFFF, 0xFF0000FF);
        }
        else if (hp > 25.0 && IsPlayerProgressBarBlinking(playerid, gPlayerHealthBar[playerid]))
        {
            StopPlayerProgressBarBlink(playerid, gPlayerHealthBar[playerid]);
        }
    }
    return 1;
}
```

### 2. Vehicle Speedometer Radial Ring (Clockwise Dial)

```pawn
new gSpeedoRing[MAX_PLAYERS] = {INVALID_PLAYER_BAR_ID, ...};

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    if (newstate == PLAYER_STATE_DRIVER)
    {
        // On 16:9 widescreen, width 40.0 requires height 50.0 (40.0 * 1.25) for a perfect circle
        gSpeedoRing[playerid] = CreatePlayerProgressBar(
            playerid,
            550.0, 360.0,
            40.0, 50.0,
            0x2ECC71FF, // Emerald Green
            200.0,      // Max 200 km/h
            PB_DIR_RIGHT,
            1.0,
            0,
            PB_STYLE_RING,
            24,         // 24 discrete segments
            1.1         // Slightly larger dots
        );
        ShowPlayerProgressBar(playerid, gSpeedoRing[playerid]);
    }
    else if (oldstate == PLAYER_STATE_DRIVER && gSpeedoRing[playerid] != INVALID_PLAYER_BAR_ID)
    {
        DestroyPlayerProgressBar(playerid, gSpeedoRing[playerid]);
        gSpeedoRing[playerid] = INVALID_PLAYER_BAR_ID;
    }
    return 1;
}
```

### 3. Ability Cooldown with Auto-Fill Preview Animation

```pawn
CMD:startcharge(playerid)
{
    new bar = CreatePlayerProgressBar(
        playerid, 
        300.0, 200.0, 
        40.0, 50.0, 
        0x3498DBFF, // Sky Blue
        100.0, 
        PB_DIR_RIGHT, 
        1.0, 0, 
        PB_STYLE_CIRCLE
    );
    ShowPlayerProgressBar(playerid, bar);

    // Smoothly animate previewing power build-up from 0 to 100%
    AutoFillPlayerProgressBar(playerid, bar, 100.0);
    SendClientMessage(playerid, -1, "Ability charging up...");
    return 1;
}
```

---

## Technical Specifications & Aspect Ratio Math

### TextDraw Screen Space Geometry

SA-MP's TextDraw coordinate canvas is mapped to a static grid of $640.0 \times 448.0$ arbitrary units. On modern high-definition widescreen displays ($16:9$, such as $1920 \times 1080$), pixel mapping behaves as follows:

$$\text{Pixel Width per Unit} = \frac{1920\text{ px}}{640} = 3.00\text{ px/unit}$$

$$\text{Pixel Height per Unit} = \frac{1080\text{ px}}{448} \approx 2.4107\text{ px/unit}$$

$$\text{Aspect Ratio Factor} = \frac{3.00}{2.4107} \approx 1.2445 \approx 1.25$$

Because one horizontal unit spans more pixels than one vertical unit, uncompensated borders look thick on the left/right and squished on the top/bottom. **Progress Bar Plus** compensates for this difference by multiplying vertical border offsets by `PB_BORDER_Y_RATIO = 1.25`:

$$y_{\text{border}} = x_{\text{border}} \times 1.25$$

This ensures that a $1.0$ border produces an even $3.0\text{ px}$ framing on every side.

### Circular Proportion Rule
For circular styles (`PB_STYLE_CIRCLE` and `PB_STYLE_RING`), shapes appear circular on $16:9$ screens only when:

$$\text{Height} = \text{Width} \times 1.25$$

For example, a width of $40.0$ units requires a height of $50.0$ units.

### Chit Sprite Scaling (`PB_CHIT_SCALE = 1.5`)
The native GTA sprite `"LD_BEAT:chit"` represents a circle occupying exactly $\frac{2}{3}$ of its bounding texture. To display a circle of diameter $D$, the sprite bounding box must be expanded by $1.5\times$:

$$\text{Sprite Width} = D \times 1.5$$

$$\text{Offset} = \frac{D - (D \times 1.5)}{2} = -0.25 \times D$$

This calculation is handled internally so developers only need to specify desired shape dimensions.

---

## Version History

<details>
<summary>Show the version history</summary>

### 1.0.0 — 01/11/2026
* Initial release of **Progress Bar Plus**:
  * Standalone, modern visual suite under `ProgressBar.inc`.
  * Aspect-ratio-corrected border calculation with `PB_BORDER_Y_RATIO (1.25)` for consistent physical pixel thickness on $16:9$ displays.
  * Hardware sprite rendering architecture using `LD_SPAC:white` and `LD_BEAT:chit`.
  * 3 distinct visual styles: `PB_STYLE_BAR`, `PB_STYLE_RING`, and `PB_STYLE_CIRCLE`.
  * Implemented zero-flicker TextDraw recycling with in-place open.mp repositioning (`PlayerTextDrawSetPos`).
  * Delta network optimization for segmented rings, caching state to eliminate open.mp `ackslimit` packet flooding.
  * Added dynamic cyclic auto-fill animation engine (`AutoFillPlayerProgressBar`).
  * Added flexible multi-phase pulsing/blinking alert engine (`BlinkPlayerProgressBar`).
  * Z-index order preservation on $0.0$ progress values by hiding rather than destroying TextDraws.
  * Automatic ALS hooking for `OnPlayerDisconnect` and `OnFilterScriptExit` memory garbage collection.
  * Zero-warning compilation on standard SA-MP Pawn compiler (`pawncc 3.2.3664`) and open.mp toolchains.
  * Released under the **Mozilla Public License 2.0 (MPL-2.0)**.

</details>

---

## Credits & Acknowledgements

* [@Walter-Correa](https://github.com/Walter-Correa) - Author & maintainer of **Progress Bar Plus**, widescreen aspect-ratio border algorithms, sprite architecture, ring delta caching, and auto-fill animation engine.
* [@Southclaws](https://github.com/Southclaws) - Creator of `progress2`, which served as conceptual inspiration for this project.

---

## License

This project is licensed under the Mozilla Public License 2.0 (MPL-2.0). See the [LICENSE](LICENSE) file for details.
