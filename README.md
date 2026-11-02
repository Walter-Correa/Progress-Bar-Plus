# Progress Bar Plus

[![GitHub release](https://img.shields.io/github/v/release/Walter-Correa/Progress-Bar-Plus?include_prereleases&color=blue)](https://github.com/Walter-Correa/Progress-Bar-Plus/releases)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL%202.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)
[![Platform](https://img.shields.io/badge/platform-SA--MP%20%7C%20open.mp-orange.svg)](https://open.mp)

**Progress Bar Plus** is a high-performance, modern, flicker-free progress bar and visual gauge library engineered specifically for **San Andreas Multiplayer (SA-MP)** and **open.mp**.

It empowers Pawn developers to build fully customizable, hardware-accelerated HUD meters: **Linear Rectangular Bars**, **Segmented Radial Ring Odometers**, and **Concentric Circular Gauges**, complete with **Fluid Value Interpolation (Lerp)**, **Dynamic Multi-Stop Color Gradients**, **Intelligent Auto-Scaling HUD Text Labels**, **Cyclic Auto-Fill Animations**, and **Multi-Phase Blinking Alerts**—all operating with zero external dependencies and guaranteed $16:9$ widescreen pixel-perfect border correction.

> [!NOTE]
> This project is conceptually inspired by [@Southclaws](https://github.com/Southclaws)'s [progress2](https://github.com/Southclaws/progress2). It has been completely rebuilt from the ground up as a standalone, modern visual suite, introducing hardware-accelerated sprite rendering (`LD_SPAC:white` and `LD_BEAT:chit`), $16:9$ widescreen aspect-ratio border compensation, zero-flicker TextDraw recycling, open.mp native repositioning, smart bandwidth delta caching, and advanced animated states.

---

## Comparison: Progress Bar Plus vs. progress2

| Feature / Capability | progress2 (Southclaws) | Progress Bar Plus |
| :--- | :--- | :--- |
| **Rendering Primitive** | Text box padding using character `"_"` (`PlayerTextDrawUseBox`) | Hardware-accelerated native sprites (`LD_SPAC:white` & `LD_BEAT:chit`) |
| **Widescreen ($16:9$) Geometry** | Uncompensated coordinate offsets (borders appear thicker horizontally on $16:9$) | Exact $1.25\times$ vertical multiplier (`PB_BORDER_Y_RATIO`), uniform physical pixel thickness |
| **Supported Visual Styles** | 1 style (linear horizontal/vertical rectangular bar) | 3 styles (`PB_STYLE_BAR`, `PB_STYLE_RING` segmented radial odometer, `PB_STYLE_CIRCLE` concentric gauge) |
| **Standard SA-MP Value Updates** | Destroys & recreates textdraw on every update when `PlayerTextDrawSetPos` is unavailable | Zero-flicker dynamic sizing via `PlayerTextDrawTextSize`; never destroys textdraw on updates |
| **Zero-Value Z-Order Preservation** | Destroys textdraw on $0.0$; subsequent recreate re-renders bar on top of newer HUD layers | Hides element (`PlayerTextDrawHide`) on $0.0$; strictly preserves creation z-order |
| **External Dependencies** | Requires `YSI-Includes` (`y_iterate`) and `sampctl` toolchains in modern versions | Completely standalone and zero-dependency (only standard `<a_samp>` or `<open.mp>`) |
| **Fluid Value Interpolation (Lerp)** | ❌ None (requires external gamemode timers, step loops, and tracking variables) | Built-in quadratic ease-out interpolation (`InterpolatePlayerProgressBarValue`) |
| **Dynamic Color Gradients** | ❌ None (requires manual gamemode color math) | Built-in multi-stop color blending (`SetPlayerProgressBarGradient`) |
| **Visual HUD Text Labels** | ❌ None (requires external TextDraws manually attached to coordinates) | Built-in high-contrast HUD labels with token formatting and geometric auto-scaling |
| **Dynamic Auto-Fill Animations** | ❌ None (requires external gamemode timers and state machines) | Built-in cyclic auto-fill engine (`AutoFillPlayerProgressBar`) preserving base progress |
| **Pulsing & Critical Alerts** | ❌ None (requires manual gamemode timer and color toggling logic) | Built-in multi-phase blinking engine (`BlinkPlayerProgressBar`) with independent colors |
| **Multi-Element Network Caching** | Not applicable (only supports basic 3-textdraw rectangular bars) | Per-segment delta cache (`PB_TDColour`), updating only modified dots to prevent packet flooding |
| **Tagging & Type Safety** | Requires strict `PlayerBar:` tag (produces tag mismatch warnings if handled as raw integer) | Standard integer IDs with backward compatibility tag/direction macros (zero compiler warnings) |
| **In-Game Visual Editor** | Basic single-bar scripts (`editor-pottus.pwn` / `editor-emmet.pwn`), export-only | Full **Progress Bar Plus - Editor** with clickable 11-button Dock, 20-layer Z-order stack, `.pbp` projects, `.pbt` templates, Pawn code importer, 3-format exporter & Undo |

---

## Progress Bar Plus - Editor (v2.1.0)

**Progress Bar Plus v2.1.0** ships with a complete, plug-and-play in-game visual design and code generation filterscript located in `Progress Bar Plus - Editor/`. Built from the ground up with a lightweight, highly optimized **Session Pool** architecture (supporting up to 10 concurrent editors with automatic Project Lock protection) and **Pawn.CMD**, it works seamlessly on both **SA-MP** and **open.mp**.

### Directory Structure

```text
Progress Bar Plus - Editor/
├── filterscripts/
│   ├── FS_ProgressBarEditor.pwn     # Full-featured in-game visual HUD designer
│   └── FS_ProgressBarEditor.amx     # Pre-compiled filterscript binary
├── gamemodes/
│   ├── GM_ProgressBarEditor.pwn     # Sandbox test gamemode
│   └── GM_ProgressBarEditor.amx     # Pre-compiled gamemode binary
├── pawno/
│   ├── include/
│   │   ├── ProgressBar.inc          # Library include
│   │   ├── pawn.cmd.inc             # Command processor include
│   │   └── sscanf2.inc              # Fast string parser include
│   ├── pawncc.exe                   # Pawn 3.10.11 compiler binary
│   └── pawno.exe                    # Pawno IDE
├── scriptfiles/
│   └── ProgressBarPlus/
│       ├── projects/                # Saved workspace projects (.pbp)
│       ├── templates/               # Reusable preset layer templates (.pbt)
│       └── exports/                 # Generated Pawn code ready to paste
└── server.cfg                       # Ready-to-run local development server config
```

### Key Editor Capabilities

* **Interactive 11-Button Dock:** Switch between Bottom Dock, Top Dock, or Minimized Fullscreen Preview mode with live telemetry data and alignment crosshair/thirds grid.
* **Multi-Layer Z-Order Stack:** Create and manage up to 20 stacked bar layers per project with layer reordering, cloning, renaming, visibility toggling, and 1-step snapshot Undo.
* **Real-Time Keyboard Transform Engine:** Fluid 35ms transform controls using Keyboard (`W/A/S/D` & Arrows) with `SHIFT`/`CTRL` fast and `ALT` fine speed modifiers, grid snapping, and $16:9$ perfect circle aspect-ratio locking.
* **Integrated HUD Text Designer:** Configure label templates (`{PERCENT}`, `{VALUE}`, `{MAX}`, `{MIN}`), font styles ($0$ to $3$), colors, position offsets, and geometric auto-scaling.
* **Dynamic Gradient & Animation Controls:** Toggle Dynamic Health Gradients (Red -> Yellow -> Green), test smooth value lerp transitions (600ms), scrub live values, configure auto-fill ping-pong, and design multi-phase blinking alerts.
* **Multi-Format Exporter:** Export directly to modular standalone includes (`.inc`), complete gamemode scripts (`.pwn`), or raw code snippets into `scriptfiles/ProgressBarPlus/exports/`.

### Editor Commands (`Pawn.CMD`)

| Command | Arguments | Description |
| :--- | :--- | :--- |
| `/pbeditor` *(or `/pbe`)* | *None* | Toggles the visual editor on or off. Opens the Session Manager if no project is active. |
| `/pbeditor help` | *None* | Opens the comprehensive in-game interactive reference and keybindings manual. |
| `/pbeditor new` | `[project_name]` | Initializes a fresh multi-layer design project workspace. |
| `/pbeditor open` | `[project_name]` | Loads an existing project from `scriptfiles/ProgressBarPlus/projects/`. |
| `/pbeditor save` | `[project_name]` | Saves the active project with all layers and visual properties. |
| `/pbeditor export` | `[mode: pwn/inc/raw]` | Exports active layers to ready-to-paste Pawn code in `scriptfiles/ProgressBarPlus/exports/`. |
| `/pbeditor layers` | *None* | Opens the Layer Manager dialog to select, reorder, clone, or delete layers. |
| `/pbreload` | *None* | *(RCON Admin)* Reloads and recompiles active editor filterscripts. |

---

## Installation

### 1. File Placement

Copy `ProgressBar.inc` into your server's include directory:
* **SA-MP / Pawno:** `pawno/include/ProgressBar.inc`
* **open.mp / Qawno:** `qawno/include/ProgressBar.inc`

### 2. Script Inclusion

Add the include near the top of your gamemode or filterscript, after `<a_samp>` or `<open.mp>`:

```pawn
#include <open.mp> // or <a_samp>
#include <ProgressBar>
```

> [!TIP]
> If `<open.mp>` or `<a_samp>` has not yet been included when `<ProgressBar>` is parsed, the include will automatically detect and include the correct header for you.

---

## Configuration & Compile-Time Defines

You can customize the following compile-time constants before including `<ProgressBar>` to tailor capacity and performance:

| Constant | Default Value | Constraints / Unit | Description |
| :--- | :---: | :---: | :--- |
| `PB_MAX_BARS` | `64` | Slots per player | Maximum number of concurrent progress bars allocated per player session. |
| `PB_MAX_TDS` | `256` | PlayerTextDraw IDs | Size of internal delta-caching arrays for TextDraw ownership and ring segments. |
| `PB_TICK_RATE` | `33` | Milliseconds (30 FPS) | Timer tick interval for smooth value interpolation (`InterpolatePlayerProgressBarValue`). |
| `PB_AUTOFILL_TICK` | `35` | Milliseconds | Internal timer tick interval for cyclic auto-fill preview animations. |
| `PB_BORDER_Y_RATIO` | `1.25` | Float multiplier | Automatic vertical multiplier compensating for standard $16:9$ TextDraw coordinate stretching. |
| `PB_BORDER_MIN` | `0.0` | TextDraw coordinate units | Minimum allowable border thickness. |
| `PB_BORDER_MAX` | `20.0` | TextDraw coordinate units | Maximum allowable border thickness. |
| `PB_SEGMENTS_MIN` | `4` | Segments | Minimum segment count allowable for segmented radial rings (`PB_STYLE_RING`). |
| `PB_SEGMENTS_MAX` | `60` | Segments | Maximum segment count allowable for segmented radial rings (`PB_STYLE_RING`). |
| `PB_BLINK_MIN` | `50` | Milliseconds | Lower safety threshold for blinking intervals to prevent timer flooding. |
| `PB_BLINK_MAX` | `5000` | Milliseconds | Upper threshold for blinking intervals. |
| `PB_CHIT_SCALE` | `1.5` | Float multiplier | Native sprite scaling factor correcting `LD_BEAT:chit` internal texture margins. |

```pawn
// Example: Customizing capacity before inclusion
#define PB_MAX_BARS 128
#include <ProgressBar>
```

---

## Constants & Enumerations

### Bar Styles (`ProgressBarStyle`)

| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_STYLE_BAR` | `0` | Sleek linear rectangular progress bar rendered with 3 hardware-accelerated sprites (`LD_SPAC:white`). |
| `PB_STYLE_RING` | `1` | Segmented radial odometer/dial composed of circular disc chits (`LD_BEAT:chit`) filling sequentially. |
| `PB_STYLE_CIRCLE` | `2` | Smooth concentric expanding disc gauge (`LD_BEAT:chit`) expanding radially from the center outward. |

### Bar Directions (`BarDirection`)

| Constant | Value | Description |
| :--- | :---: | :--- |
| `PB_DIR_RIGHT` | `0` | Fills horizontally from left to right *(Default)*. |
| `PB_DIR_LEFT` | `1` | Fills horizontally from right to left. |
| `PB_DIR_UP` | `2` | Fills vertically from bottom to top. |
| `PB_DIR_DOWN` | `3` | Fills vertically from top to bottom. |

### Special Return Values

| Constant | Value | Description |
| :--- | :---: | :--- |
| `INVALID_PLAYER_BAR_ID` | `-1` | Returned when bar creation fails or an invalid bar handle is referenced. |

---

## Functions

### 1. Creation & Lifecycle

#### `CreatePlayerProgressBar`
```pawn
stock CreatePlayerProgressBar(playerid, Float:x, Float:y, Float:width = PB_DEFAULT_WIDTH, Float:height = PB_DEFAULT_HEIGHT, colour = PB_DEFAULT_COLOUR, Float:max = PB_DEFAULT_MAX, style = PB_STYLE_BAR, direction = PB_DIR_RIGHT, Float:min = 0.0);
```
Allocates, configures, and initializes a new progress bar instance for the specified player.
* **`playerid`:** Player who owns the progress bar.
* **`x`, `y`:** Screen space coordinates ($0.0$ to $640.0$, $0.0$ to $448.0$).
* **`width`, `height`:** Outer dimensions in TextDraw coordinate units.
* **`colour`:** RGBA fill color (defaults to `0xE74C3CFF`).
* **`max`:** Upper limit of the progress range (defaults to `100.0`).
* **`style`:** Visual rendering style (`PB_STYLE_BAR`, `PB_STYLE_RING`, `PB_STYLE_CIRCLE`).
* **`direction`:** Fill progression vector (`PB_DIR_RIGHT`, `PB_DIR_LEFT`, `PB_DIR_UP`, `PB_DIR_DOWN`).
* **`min`:** Lower floor of the progress range (defaults to `0.0`).
* **Returns:** The newly allocated `barid` on success, or `INVALID_PLAYER_BAR_ID` (`-1`) on failure.

#### `DestroyPlayerProgressBar`
```pawn
stock DestroyPlayerProgressBar(playerid, barid);
```
Completely removes the progress bar, cancels active timers, cleans up all internal TextDraws, and recycles the bar slot.
* **Returns:** `1` on success, `0` on failure.

#### `IsValidPlayerProgressBar`
```pawn
stock bool:IsValidPlayerProgressBar(playerid, barid);
```
Validates whether the specified bar handle represents an actively allocated progress bar.
* **Returns:** `true` if valid, `false` otherwise.

#### `ResetPlayerProgressBar`
```pawn
stock ResetPlayerProgressBar(playerid, barid);
```
Resets the progress bar value back to its minimum floor (`PB_MinValue`), terminating any active animations or blinking effects.
* **Returns:** `1` on success, `0` on failure.

---

### 2. Visibility & Display Management

#### `ShowPlayerProgressBar`
```pawn
stock ShowPlayerProgressBar(playerid, barid);
```
Displays all components of the progress bar (border frame, background track, active fill, and text label) on the player's screen.
* **Returns:** `1` on success, `0` on failure.

#### `HidePlayerProgressBar`
```pawn
stock HidePlayerProgressBar(playerid, barid);
```
Hides all TextDraw components associated with the bar without destroying handles or altering the current value.
* **Returns:** `1` on success, `0` on failure.

#### `bool:IsPlayerProgressBarVisible`
```pawn
stock bool:IsPlayerProgressBarVisible(playerid, barid);
```
Queries whether the progress bar is currently visible on the player's screen.
* **Returns:** `true` if visible, `false` otherwise.

---

### 3. Value & Range Control

#### `SetPlayerProgressBarValue`
```pawn
stock SetPlayerProgressBarValue(playerid, barid, Float:value);
```
Sets the current progress value. Clamped automatically between `PB_MinValue` and `PB_MaxValue`. Terminating active value lerps while updating text labels and dynamic color gradients in real time.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarValue`
```pawn
stock Float:GetPlayerProgressBarValue(playerid, barid);
```
Returns the actual underlying progress value of the bar.
* **Returns:** Current value as a float, or `0.0` on invalid bar.

#### `SetPlayerProgressBarMinValue`
```pawn
stock SetPlayerProgressBarMinValue(playerid, barid, Float:minvalue);
```
Sets a custom minimum threshold value (floor). Linearly normalizes fill proportion across the range $[min, max]$.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarMinValue`
```pawn
stock Float:GetPlayerProgressBarMinValue(playerid, barid);
```
Retrieves the minimum value floor of the progress bar.
* **Returns:** Minimum value as a float, or `0.0` on invalid bar.

#### `SetPlayerProgressBarMaxValue`
```pawn
stock SetPlayerProgressBarMaxValue(playerid, barid, Float:maxvalue);
```
Updates the maximum capacity of the progress bar.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarMaxValue`
```pawn
stock Float:GetPlayerProgressBarMaxValue(playerid, barid);
```
Retrieves the maximum capacity of the progress bar.
* **Returns:** Maximum value as a float, or `100.0` on invalid bar.

#### `SetPlayerProgressBarRange`
```pawn
stock SetPlayerProgressBarRange(playerid, barid, Float:minvalue, Float:maxvalue);
```
Convenience function to configure both minimum and maximum boundaries in a single atomic call.
* **Returns:** `1` on success, `0` on failure.

---

### 4. Geometry & Dimensions

#### `SetPlayerProgressBarPos`
```pawn
stock SetPlayerProgressBarPos(playerid, barid, Float:x, Float:y);
```
Relocates the bar to new screen coordinates. Automatically repositioning all child sprites, ring segments, and text labels.
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarPos`
```pawn
stock GetPlayerProgressBarPos(playerid, barid, &Float:x, &Float:y);
```
Retrieves the origin coordinates of the progress bar into the referenced variables.
* **Returns:** `1` on success, `0` on failure.

#### `SetPlayerProgressBarWidth`
```pawn
stock SetPlayerProgressBarWidth(playerid, barid, Float:width);
```
Updates the outer width of the progress bar.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarWidth`
```pawn
stock Float:GetPlayerProgressBarWidth(playerid, barid);
```
Retrieves the outer width of the progress bar.
* **Returns:** Outer width as a float, or `0.0` on invalid bar.

#### `SetPlayerProgressBarHeight`
```pawn
stock SetPlayerProgressBarHeight(playerid, barid, Float:height);
```
Updates the outer height of the progress bar.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarHeight`
```pawn
stock Float:GetPlayerProgressBarHeight(playerid, barid);
```
Retrieves the outer height of the progress bar.
* **Returns:** Outer height as a float, or `0.0` on invalid bar.

#### `SetPlayerProgressBarBorder`
```pawn
stock SetPlayerProgressBarBorder(playerid, barid, Float:border = PB_BORDER_DEFAULT);
```
Sets the border thickness. Top and bottom borders automatically scale by `PB_BORDER_Y_RATIO` ($1.25	imes$) to maintain square, uniform physical screen pixels on $16:9$ widescreen displays.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarBorder`
```pawn
stock Float:GetPlayerProgressBarBorder(playerid, barid);
```
Retrieves the horizontal border thickness of the bar.
* **Returns:** Border thickness as a float, or `0.0` on invalid bar.

---

### 5. Styles, Segments & Rings

#### `SetPlayerProgressBarStyle`
```pawn
stock SetPlayerProgressBarStyle(playerid, barid, style);
```
Switches the visual presentation style (`PB_STYLE_BAR`, `PB_STYLE_RING`, `PB_STYLE_CIRCLE`). Automatically recreates internal TextDraw primitives to match the chosen layout.
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarStyle`
```pawn
stock GetPlayerProgressBarStyle(playerid, barid);
```
Retrieves the current visual style of the progress bar.
* **Returns:** Active style ID, or `0` on invalid bar.

#### `SetPlayerProgressBarDirection`
```pawn
stock SetPlayerProgressBarDirection(playerid, barid, direction);
```
Configures the direction in which the bar fills (`PB_DIR_RIGHT`, `PB_DIR_LEFT`, `PB_DIR_UP`, `PB_DIR_DOWN`).
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarDirection`
```pawn
stock GetPlayerProgressBarDirection(playerid, barid);
```
Retrieves the fill direction of the bar.
* **Returns:** Direction constant, or `0` on invalid bar.

#### `SetPlayerProgressBarSegments`
```pawn
stock SetPlayerProgressBarSegments(playerid, barid, segments);
```
Configures the segment count ($4$ to $60$) for segmented radial ring gauges (`PB_STYLE_RING`).
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarSegments`
```pawn
stock GetPlayerProgressBarSegments(playerid, barid);
```
Retrieves the segment count of a segmented radial ring.
* **Returns:** Segment count, or `0` on invalid bar.

#### `SetPlayerProgressBarSegmentScale`
```pawn
stock SetPlayerProgressBarSegmentScale(playerid, barid, Float:scale);
```
Applies a size multiplier to individual ring segment chits.
* **Returns:** `1` on success, `0` on failure.

#### `Float:GetPlayerProgressBarSegmentScale`
```pawn
stock Float:GetPlayerProgressBarSegmentScale(playerid, barid);
```
Retrieves the segment scale multiplier of a radial ring.
* **Returns:** Scale multiplier as a float, or `1.0` on invalid bar.

---

### 6. Colors, Themes & Dynamic Gradients

#### `SetPlayerProgressBarColour`
```pawn
stock SetPlayerProgressBarColour(playerid, barid, colour = PB_DEFAULT_COLOUR);
```
Sets the primary RGBA fill color. The subtle translucent background track automatically adopts a 30% alpha profile matching this color. *(Alias: `SetPlayerProgressBarColor`)*
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarColour`
```pawn
stock GetPlayerProgressBarColour(playerid, barid);
```
Retrieves the primary RGBA fill color. *(Alias: `GetPlayerProgressBarColor`)*
* **Returns:** RGBA integer color, or `0` on invalid bar.

#### `SetPlayerProgressBarBorderColor`
```pawn
stock SetPlayerProgressBarBorderColor(playerid, barid, bordercolor = 0);
```
Sets the border frame RGBA color. Passing `0` applies automatic dark shading matching the bar's alpha. *(Alias: `SetPlayerProgressBarBorderColour`)*
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarBorderColor`
```pawn
stock GetPlayerProgressBarBorderColor(playerid, barid);
```
Retrieves the border frame color. *(Alias: `GetPlayerProgressBarBorderColour`)*
* **Returns:** RGBA integer color, or `0` on invalid bar.

#### `SetPlayerProgressBarGradient`
```pawn
stock SetPlayerProgressBarGradient(playerid, barid, bool:enable, colour_empty = 0xE74C3CFF, colour_full = 0x2ECC71FF, colour_mid = 0xF1C40FFF, bool:inverted = false);
```
Enables dynamic multi-stop color blending that interpolates the bar fill color according to current progress:
* **`colour_empty`:** Color at $0\%$ minimum progress (default Crimson `0xE74C3CFF`).
* **`colour_mid`:** Color at $50\%$ midpoint progress (default Amber `0xF1C40FFF`). Passing `0` switches to 2-point direct linear blending between empty and full.
* **`colour_full`:** Color at $100\%$ maximum capacity (default Emerald Green `0x2ECC71FF`).
* **`inverted`:** If `true`, reverses color progression polarity (low values render Green, high values render Red; ideal for heat, threat, stress, and temperature meters).
* Updates automatically across value changes, auto-fill cycles, and value interpolations.
* **Returns:** `1` on success, `0` on failure.

#### `SetPlayerProgressBarGradientInverted`
```pawn
stock SetPlayerProgressBarGradientInverted(playerid, barid, bool:inverted);
```
Toggles or sets the gradient polarity direction without changing the configured color palette. *(Alias: `SetPlayerProgressBarGradientDirection`)*
* **`inverted`:** `false` for Standard (Low=Red -> High=Green), `true` for Inverted (Low=Green -> High=Red).
* **Returns:** `1` on success, `0` on failure.

#### `bool:IsPlayerProgressBarGradientInverted`
```pawn
stock bool:IsPlayerProgressBarGradientInverted(playerid, barid);
```
Queries whether the bar's gradient is currently using inverted polarity. *(Alias: `IsPlayerProgressBarGradientDirection`)*
* **Returns:** `true` if inverted, `false` otherwise.

#### `StopPlayerProgressBarGradient`
```pawn
stock StopPlayerProgressBarGradient(playerid, barid);
```
Disables dynamic color blending and restores the bar's static primary color.
* **Returns:** `1` on success, `0` on failure.

#### `bool:IsPlayerProgressBarGradientEnabled`
```pawn
stock bool:IsPlayerProgressBarGradientEnabled(playerid, barid);
```
Checks if the progress bar is actively using dynamic color gradients.
* **Returns:** `true` if enabled, `false` otherwise.

---

### 7. Animations & Value Interpolation (Lerp)

#### `InterpolatePlayerProgressBarValue`
```pawn
stock InterpolatePlayerProgressBarValue(playerid, barid, Float:target_value, duration_ms = 500);
```
Smoothly glides the progress bar value from its current level to `target_value` over `duration_ms` milliseconds using a fluid quadratic ease-out curve.
* **`target_value`:** Destination progress value (automatically clamped between min and max).
* **`duration_ms`:** Animation duration in milliseconds (defaults to `500ms`).
* **Mutual Exclusion:** Automatically halts any active auto-fill preview to preserve clean animation states.
* **Returns:** `1` on success, `0` on failure.

#### `StopPlayerProgressBarInterpolation`
```pawn
stock StopPlayerProgressBarInterpolation(playerid, barid);
```
Immediately terminates active value interpolation, retaining the current intermediate progress level.
* **Returns:** `1` on success, `0` on failure.

#### `bool:IsPlayerProgressBarInterpolating`
```pawn
stock bool:IsPlayerProgressBarInterpolating(playerid, barid);
```
Checks if the progress bar is currently undergoing a value interpolation transition.
* **Returns:** `true` if interpolating, `false` otherwise.

#### `AutoFillPlayerProgressBar`
```pawn
stock AutoFillPlayerProgressBar(playerid, barid, Float:maxvalue = -1.0);
```
Initiates a smooth cyclic preview animation rising from the baseline value up to `maxvalue`, holding, receding down, and repeating continuously.
* **`maxvalue`:** Peak animation threshold. Passing `-1.0` or omitting defaults to the bar's maximum capacity.
* The true underlying value remains untouched; calling `SetPlayerProgressBarValue` adjusts the baseline in real time.
* **Mutual Exclusion:** Automatically halts any active value interpolation transitions.
* **Returns:** `1` on success, `0` on failure.

#### `StopAutoFillPlayerProgressBar`
```pawn
stock StopAutoFillPlayerProgressBar(playerid, barid);
```
Terminates the auto-fill animation and restores the visual display to the bar's true progress value.
* **Returns:** `1` on success, `0` on failure.

#### `bool:IsPlayerProgressBarAutoFilling`
```pawn
stock bool:IsPlayerProgressBarAutoFilling(playerid, barid);
```
Queries whether the progress bar is actively running an auto-fill preview animation.
* **Returns:** `true` if auto-filling, `false` otherwise.

---

### 8. Pulsing & Blinking Alerts

#### `BlinkPlayerProgressBar`
```pawn
stock BlinkPlayerProgressBar(playerid, barid, interval = PB_BLINK_DEFAULT, duration = 0, colour = 0, bordercolour = 0);
```
Activates high-visibility blinking for alerts, critical health warnings, and cooldown notifications.
* **`interval`:** Milliseconds between each toggle phase (`PB_BLINK_MIN` to `PB_BLINK_MAX`).
* **`duration`:** Duration in milliseconds before stopping ($0$ for continuous).
* **`colour`:** Alternate fill color while lit. Passing `0` toggles visibility on/off in the existing color.
* **`bordercolour`:** Alternate border color while lit. Passing `0` preserves the existing border color.
* **Returns:** `1` on success, `0` on failure.

#### `StopPlayerProgressBarBlink`
```pawn
stock StopPlayerProgressBarBlink(playerid, barid);
```
Stops blinking immediately and restores normal colors and visibility.
* **Returns:** `1` on success, `0` on failure.

#### `bool:IsPlayerProgressBarBlinking`
```pawn
stock bool:IsPlayerProgressBarBlinking(playerid, barid);
```
Checks if the progress bar is actively in a blinking state.
* **Returns:** `true` if blinking, `false` otherwise.

---

### 9. Visual Value & Text Labels

#### `SetPlayerProgressBarLabel`
```pawn
stock SetPlayerProgressBarLabel(playerid, barid, bool:enable, const template[] = "{PERCENT}%", colour = 0xFFFFFFFF, alignment = 2, font = 1, Float:scaleX = 0.20, Float:scaleY = 0.85, Float:offsetX = 0.0, Float:offsetY = 0.0);
```
Attaches or updates a high-contrast HUD text label integrated directly onto the progress bar.
* **`enable`:** `true` to display the label, `false` to hide/disable it.
* **`template`:** Format string or template supporting dynamic tokens:
  * `{PERCENT}` / `{PCT}`: Normalized integer percentage ($0\%$ to $100\%$).
  * `{VALUE}` / `{VAL}`: Current progress value (integer).
  * `{MAX}`: Maximum capacity.
  * `{MIN}`: Minimum floor.
  * Static custom text (e.g., `"HP: {PERCENT}%"`, `"{VAL} / {MAX}"`, `"SPEED: {VAL}"`).
* **`colour`:** RGBA font color (defaults to pure white `0xFFFFFFFF` with automatic black outline).
* **`alignment`:** `1` (Left), `2` (Center - default), or `3` (Right).
* **`font`:** GTA TextDraw font style ($0$ to $3$). Automatically recreated on change to bypass SA-MP client font caching.
* **`scaleX`, `scaleY`:** Font width and height scale factors.
* **`offsetX`, `offsetY`:** Pixel displacement relative to the bar geometric center.
* **Returns:** `1` on success, `0` on failure.

#### `SetPlayerProgressBarLabelText`
```pawn
stock SetPlayerProgressBarLabelText(playerid, barid, const template[]);
```
Updates the template string or text of an existing label.
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarLabelText`
```pawn
stock GetPlayerProgressBarLabelText(playerid, barid, dest[], size = sizeof dest);
```
Retrieves the current label template string into `dest`.
* **Returns:** `1` on success, `0` on failure.

#### `SetPlayerProgressBarLabelColour`
```pawn
stock SetPlayerProgressBarLabelColour(playerid, barid, colour);
```
Updates the label font color. *(Alias: `SetPlayerProgressBarLabelColor`)*
* **Returns:** `1` on success, `0` on failure.

#### `GetPlayerProgressBarLabelColour`
```pawn
stock GetPlayerProgressBarLabelColour(playerid, barid);
```
Retrieves the current label font color. *(Alias: `GetPlayerProgressBarLabelColor`)*
* **Returns:** RGBA integer color, or `0` on invalid bar.

#### `SetPlayerProgressBarLabelScale`
```pawn
stock SetPlayerProgressBarLabelScale(playerid, barid, Float:scaleX, Float:scaleY);
```
Updates manual font letter scaling dimensions. Disables auto-scaling for that bar.
* **Returns:** `1` on success, `0` on failure.

#### `SetPlayerProgressBarLabelOffset`
```pawn
stock SetPlayerProgressBarLabelOffset(playerid, barid, Float:offsetX, Float:offsetY);
```
Sets relative pixel offsets $(X, Y)$ from the bar's geometric center.
* **Returns:** `1` on success, `0` on failure.

#### `SetPlayerProgressBarLabelAutoScale`
```pawn
stock SetPlayerProgressBarLabelAutoScale(playerid, barid, bool:autoScale);
```
Enables or disables automatic geometric text containment (`true` by default).
* When enabled, font scaling ($scaleX, scaleY$) automatically recalculates whenever the bar is resized or moved, guaranteeing text glyphs remain strictly inside the bar boundaries without overflowing.
* Text outlines are allowed to aesthetically touch/overlap borders for maximum readability.
* **Returns:** `1` on success, `0` on failure.

#### `bool:GetPlayerProgressBarLabelAutoScale`
```pawn
stock bool:GetPlayerProgressBarLabelAutoScale(playerid, barid);
```
Queries whether auto-scaling is currently active for the bar's label.
* **Returns:** `true` if auto-scaling is active, `false` otherwise.

#### `bool:IsPlayerProgressBarLabelEnabled`
```pawn
stock bool:IsPlayerProgressBarLabelEnabled(playerid, barid);
```
Checks if the progress bar currently has an active text label.
* **Returns:** `true` if enabled, `false` otherwise.

---

## Version History

<details>
<summary>Show the version history</summary>

### 2.1.0 — 02/11/2026
* **Smooth Value Interpolation (`InterpolatePlayerProgressBarValue`):**
  * Added built-in fluid value transition engine with quadratic ease-out curves and 30 FPS timer ticks (`PB_TICK_RATE = 33ms`).
  * Added `StopPlayerProgressBarInterpolation` and `IsPlayerProgressBarInterpolating` for complete runtime control.
  * Implemented mutual exclusion: activating lerp automatically halts auto-fill, and activating auto-fill automatically halts lerp.
* **Dynamic Multi-Stop Color Gradients (`SetPlayerProgressBarGradient`):**
  * Added dynamic color interpolation based on current bar fill ratio (Empty -> Midpoint -> Full, defaulting to Red -> Amber -> Green).
  * Added bidirectional gradient direction and polarity control (`SetPlayerProgressBarGradientInverted` / `SetPlayerProgressBarGradientDirection`) supporting Standard (Health: Red -> Green) and Inverted (Heat/Threat/Temperature: Green -> Red) progression modes.
  * Implemented real-time gradient synchronization with cyclic auto-fill preview animations across all bar styles.
  * Added `StopPlayerProgressBarGradient` and `IsPlayerProgressBarGradientEnabled`.
* **Intelligent Auto-Scaling Value Labels (`SetPlayerProgressBarLabel`):**
  * Built-in high-contrast HUD text label with dynamic template token formatting (`{PERCENT}`, `{VALUE}`, `{MAX}`, `{MIN}`).
  * Added `SetPlayerProgressBarLabelAutoScale`: mathematically bounds font scale ($scaleX, scaleY$) within the bar's inner dimensions so text never overflows the borders across all resizes and moves.
  * Fixed SA-MP TextDraw font caching bug by automatically recreating the label TextDraw on style change for instant on-screen updates.
* **Custom Min-Value Range (`SetPlayerProgressBarMinValue`, `SetPlayerProgressBarRange`):**
  * Added support for custom minimum thresholds with mathematical fill normalization (`part = (val - min) / (max - min)`), ensuring zero visual distortion.
* **Gamemode Lifecycle & Cache Hardening:**
  * Added Advanced Library Standard (ALS) hook for `OnGameModeExit` to automatically garbage-collect timers, state, and TextDraws on `/rcon gmx`.
  * Added zeroing of per-segment delta caches (`PB_TDPart`, `PB_TDColour`) in `PB_KillRing` and `OnPlayerDisconnect` to prevent state contamination between reconnects.
* **Progress Bar Plus - Editor v2.1.0 Upgrades:**
  * Integrated Text Label designer with font picker, live preview, offset adjustments, and auto-scale toggle.
  * Integrated Dynamic Health Gradient toggle and Direction / Polarity switcher in Color & Themes menu.
  * Integrated Min-Value configuration dialog in Animations & Values menu.
  * Full export generator updated for all v2.1.0 functions across Pawn script, project (`.pbp`), and template (`.pbt`) formats.
* **Drop-In Compatibility & Repository Enhancements:**
  * 100% backward-compatible drop-in replacement for v1.0.0 and `progress2` codebases.
  * Added `.gitignore` to keep runtime server logs (`log.txt`, `server_log.txt`, `omp-server.log`) out of version control.

### 2.0.0 — 01/11/2026
* Introduced **Progress Bar Plus - Editor** (`Progress Bar Plus - Editor/filterscripts/FS_ProgressBarEditor.pwn` & `gamemodes/GM_ProgressBarEditor.pwn`):
  * Complete in-game visual HUD editor built with `Pawn.CMD`, compatible out-of-the-box with SA-MP and open.mp, accompanied by a lightweight sandbox test gamemode.
  * Memory-optimized 10-slot concurrent Session Pool architecture with automatic in-memory **Project Lock** protection preventing concurrent overwrites across active editors.
  * Interactive 11-button Editor Dock (Bottom / Top / Minimized fullscreen preview) with live telemetry HUD, project save state indicator (`[Saved]` / `[Unsaved]`), and alignment crosshair/thirds grid.
  * Multi-bar workspace supporting up to 20 layers per project with Z-order reordering, cloning, renaming, visibility toggling, and 1-step snapshot Undo.
  * Real-time `35ms` transform engine supporting Keyboard (`W/A/S/D` & Arrows) with `SHIFT`/`CTRL` fast and `ALT` fine speed modifiers, grid snapping, and $16:9$ perfect circle aspect-ratio locking for rings and circles with precise 1:1 screen synchronization.
  * Interactive Live Value Scrubber allowing developers to visually test fill thresholds in real time using WASD / Arrow keys.
  * Color & Theme Designer featuring 28 modern curated palette swatches, direct hex RGBA/RGB `#HEX` entry, 5 opacity presets, automatic border shading, and cross-layer visual theme cloning.
  * Segmented Radial Ring Customizer with real-time segment count adjustment ($4$ to $60$) and independent dot scale multipliers.
  * Dynamic Auto-Fill preview designer and multi-phase blinking alert configurator with interval and duration tuning.
  * Project management system saving binary `.pbp` workspaces to `scriptfiles/ProgressBarPlus/projects/` with automatic directory self-healing.
  * Template preset library saving reusable layer templates (`.pbt`) to `scriptfiles/ProgressBarPlus/templates/`.
  * Interactive Pawn code importer parsing `CreatePlayerProgressBar` code directly into live editable layers.
  * Tri-format code exporter generating modular standalone includes (`.inc`), standalone test gamemodes (`.pwn`), or raw code snippets into `scriptfiles/ProgressBarPlus/exports/`.

### 1.0.0 — 01/11/2026
* Initial public release of **Progress Bar Plus**:
  * Pure sprite rendering engine utilizing native `LD_SPAC:white` (linear bars) and `LD_BEAT:chit` (segmented radial rings and expanding concentric circular gauges).
  * Built-in widescreen aspect-ratio border compensation (`PB_BORDER_Y_RATIO = 1.25`) guaranteeing uniform physical pixel thickness on $16:9$ monitors.
  * Dynamic in-place coordinate resizing (`PlayerTextDrawTextSize` and open.mp `PlayerTextDrawSetPos`) eliminating TextDraw destruction flickering.
  * Handle preservation and zero-value hiding (`PlayerTextDrawHide`) maintaining strict Z-index ordering.
  * Dynamic cyclic auto-fill animation engine (`AutoFillPlayerProgressBar`).
  * Multi-phase blinking alert system (`BlinkPlayerProgressBar`) with independent inner and border color overrides.
  * Per-segment delta network caching (`PB_TDColour`) preventing bandwidth packet flooding on high-frequency ring updates.
  * Zero external dependencies—fully compatible with standard SA-MP (`<a_samp>`) and open.mp (`<open.mp>`).

</details>

---

## Author & Credits

* **Walter Corrêa** ([@Walter-Correa](https://github.com/Walter-Correa)) - Creator & Maintainer of **Progress Bar Plus**.
* **Southclaws** ([@Southclaws](https://github.com/Southclaws)), **Toranks** ([@Toranks](https://github.com/Toranks)), and **Pottus** ([@Pottus](https://github.com/Pottus)) - Foundational concepts and inspiration from legacy SA-MP progress bar libraries.

---

## License

This project is licensed under the **Mozilla Public License 2.0 (MPL-2.0)**. See the [LICENSE](LICENSE) file for complete legal terms.
