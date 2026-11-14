# Getting Started with Progress Bar Plus

This guide walks you through installing **Progress Bar Plus**, understanding its zero-dependency architecture, seamlessly migrating existing `progress2` codebases, and creating your very first interactive HUD meter in Pawn.

---

## 1. Prerequisites & Installation

Progress Bar Plus is packaged as a single, self-contained include file (`ProgressBar.inc`). It requires **zero external dependencies** — no plugins, no Streamer, and no YSI required.

### Step 1: Copy Include File
Copy `ProgressBar.inc` into your server development environment:
```
pawno/include/ProgressBar.inc
```
*(Or your preferred include path if using `sampctl` or custom build pipelines).*

### Step 2: Include in Pawn Code
Include `ProgressBar.inc` in your gamemode or filterscript immediately after `<a_samp>` (or `<open_mp>`):

```pawn
#include <a_samp>
#include <ProgressBar>
```

> [!TIP]
> Progress Bar Plus automatically detects whether you are compiling for open.mp (`_INC_open_mp`) or standard SA-MP, configuring native PlayerTextDraw repositioning (`PlayerTextDrawSetPos`) and enums on the fly.

> [!IMPORTANT]
> **Recommended Include Order for Maximum Performance:**
> If your project uses TextDraw hooking libraries (such as `TextDrawFX` or custom ALS hook wrappers), always place `#include <ProgressBar>` **before** them:
> ```pawn
> #include <a_samp>      // or <open.mp>
> #include <ProgressBar> // High-frequency rendering bypasses third-party hook wrappers
> #include <TextDrawFX>  // Hooking library
> ```
> Placing `ProgressBar` first ensures high-frequency rendering routines (such as radial ring updates with up to 60 segments per frame) call native functions directly, avoiding unnecessary search loops in external hook wrappers.

---

## 2. Drop-In Migration from `progress2`

Progress Bar Plus was built from the ground up as a standalone suite, but provides **100% backward compatibility** for all legacy `progress2` functions and definitions.

If your existing codebase uses `progress2`, you can replace the include file without modifying a single line of your existing logic:

### Compatibility Definitions Matrix

| Legacy progress2 Definition | Progress Bar Plus Standard | Status / Notes |
| :--- | :--- | :--- |
| `PlayerBar:` (Strong Tag) | `#define PlayerBar: _:` | Fully Supported (Zero tag mismatch warnings) |
| `BAR_DIRECTION_RIGHT` | `PB_DIR_RIGHT` / `PBP_DIR_RIGHT` | Fully Supported (Aliased) |
| `BAR_DIRECTION_LEFT` | `PB_DIR_LEFT` / `PBP_DIR_LEFT` | Fully Supported (Aliased) |
| `BAR_DIRECTION_UP` | `PB_DIR_UP` / `PBP_DIR_UP` | Fully Supported (Aliased) |
| `BAR_DIRECTION_DOWN` | `PB_DIR_DOWN` / `PBP_DIR_DOWN` | Fully Supported (Aliased) |
| `MAX_PLAYER_BARS` | `PB_MAX_BARS` (default: 64) | Configurable via `#define PB_MAX_BARS` |
| `INVALID_PLAYER_BAR_ID` | `INVALID_PLAYER_BAR_ID` (-1) | Identical |
| `SetPlayerProgressBarColor` | `SetPlayerProgressBarColour` | Fully Supported (Aliased) |
| `GetPlayerProgressBarColor` | `GetPlayerProgressBarColour` | Fully Supported (Aliased) |
| `Float:height = 3.2` | Explicit 2.5x Conversion | Optional `convert_legacy = true` in `CreatePlayerProgressBar` |

### Important Migration Nuances: Tagging & Coordinate Scaling

#### 1. PlayerBar: Tag Support
In `progress2`, all bar variables were declared with the strong tag `PlayerBar:` (e.g. `new PlayerBar:myBar[MAX_PLAYERS];`). In **Progress Bar Plus**, bar IDs are lightweight integer indices. To make migrations 100% painless without altering your gamemode source files, `ProgressBar.inc` defines:
```pawn
#if !defined PlayerBar
    #define PlayerBar: _:
#endif
```
This guarantees zero tag mismatch compiler warnings (Warning 213) across legacy scripts.

#### 2. Height Parameter & Legacy Conversion
- In legacy `progress2`, bars were drawn using a GTA font-box text rendering hack where `height` represented **font letter size Y divided by 10** (default was `3.2`). In the GTA SA font pipeline, a letter size Y of `0.32` produced an on-screen box approximately **~8.0 pixels high** on a 640x448 canvas.
- In **Progress Bar Plus**, bars are rendered as crisp hardware quad sprites (`LD_SPAC:white`) where `width` and `height` represent true 1:1 pixel coordinate units.
- **No Unwanted Auto-Conversion:** By default, Progress Bar Plus preserves your exact pixel dimensions without unexpected automatic scaling. If you are migrating legacy code with sub-4.5 font-box heights (such as `3.2`), you can enable the $2.5\times$ scaler by passing the optional parameter `convert_legacy = true` to `CreatePlayerProgressBar`:
```pawn
// Converts legacy height 3.2 to 8.0 pixels:
new PlayerBar:myBar = CreatePlayerProgressBar(
    playerid, 548.0, 66.0, 60.0, 3.2,
    PB_DEFAULT_COLOUR, 100.0, PB_DIR_RIGHT, PB_BORDER_DEFAULT, 0,
    PB_STYLE_BAR, PB_RING_SEGMENTS, PB_RING_SEGMENT_SCALE,
    true // bool:convert_legacy
);
```
*(Alternatively, you can simply update the height argument directly to your desired pixel size, e.g. `8.0` or `10.0`).*

#### 3. Guaranteed Minimum Dimensions
To ensure borders and inner fill ("recheio") remain clearly visible across all screen resolutions and styles, Progress Bar Plus enforces well-defined minimum dimension boundaries:
* **Rectangular Bars (`PB_STYLE_BAR`):** Minimum **`3.0 x 3.0`** (`PB_BAR_MIN_WIDTH`, `PB_BAR_MIN_HEIGHT`). Guarantees at least $1.0$ px inner fill (`PB_MIN_INNER`) and visible border even with default borders.
* **Circular Gauges (`PB_STYLE_CIRCLE`):** Minimum **`8.0 x 8.0`** (`PB_CIRCLE_MIN_WIDTH`, `PB_CIRCLE_MIN_HEIGHT`). Guarantees clear concentric disc expansion and discernible border ring.
* **Radial Rings (`PB_STYLE_RING`):** Minimum **`16.0 x 16.0`** (`PB_RING_MIN_WIDTH`, `PB_RING_MIN_HEIGHT`). Guarantees an open central hole, non-overlapping orbit ($px > 0$), and distinct dot chits.

If any bar is created or resized below these thresholds, the library automatically clamps dimensions to the minimum allowable limit rather than allowing distorted or invisible elements.

#### 4. PlayerTextDraw Limits (256 per player)
- SA-MP and open.mp enforce a hard engine ceiling of **256 PlayerTextDraws** per connected player (`MAX_PLAYER_TEXT_DRAWS`).
- Classic Linear Bars and Circular Gauges consume 3 PlayerTextDraws (or 4 with label enabled).
- Radial Rings consume **$2 \times \text{segments}$** textdraws ($48$ TDs for a 24-segment ring; $120$ TDs for a 60-segment ring).
- **Progress Bar Plus** features built-in capacity verification (`PB_GetFreePlayerTextDraws`) and atomic rollback: if the client pool cannot accommodate a full bar, creation safely fails without leaving broken, orphaned, or black boxes on screen.

### Key Improvements Over `progress2`
1. **Hardware Texture Rendering:** Renders clean quad quads via `LD_SPAC:white` and anti-aliased circular points via `LD_BEAT:chit`, avoiding ugly font-box artifacts.
2. **16:9 Aspect-Ratio Border Correction:** Automatically multiplies the vertical border by $1.25$, ensuring borders look pixel-perfect and square on widescreen monitors.
3. **Radial Rings & Gauges:** Out-of-the-box support for radial odometers ($4$ to $60$ segments) and circular dials.
4. **Zero-Flicker open.mp In-Place Updating:** Moves and resizes textdraws without destroying or recreating handles.
5. **Delta Bandwidth Caching:** Caches color states and visibility to avoid flooding the network.

---

## 3. Creating Your First Progress Bar

Below is a complete, minimal example showing how to create a modern HUD Health Bar for players:

```pawn
#include <a_samp>
#include <ProgressBar>

// Store bar handle per player
new PlayerBar:g_PlayerHealthBar[MAX_PLAYERS] = { INVALID_PLAYER_BAR_ID, ... };

public OnPlayerConnect(playerid)
{
    // Initialize slot state
    g_PlayerHealthBar[playerid] = INVALID_PLAYER_BAR_ID;
    return 1;
}

public OnPlayerSpawn(playerid)
{
    // Create the health bar if not yet spawned
    if (g_PlayerHealthBar[playerid] == INVALID_PLAYER_BAR_ID)
    {
        // Coordinates: X = 548.0, Y = 66.0 (below standard GTA SA radar/fist area)
        // Width: 60.0, Height: 8.0, Colour: Red (0xEF4444FF), Max: 100.0, Direction: Right
        g_PlayerHealthBar[playerid] = CreatePlayerProgressBar(
            playerid,
            548.0, 66.0,
            60.0, 8.0,
            0xEF4444FF,
            100.0,
            PB_DIR_RIGHT,
            PB_BORDER_DEFAULT,
            0x000000FF
        );

        // Attach an auto-scaling text label showing percentage
        SetPlayerProgressBarLabel(
            playerid,
            g_PlayerHealthBar[playerid],
            true,
            "{PERCENT}%",
            0xFFFFFFFF,
            2 // Alignment: Center
        );

        // Display the bar on player's screen
        ShowPlayerProgressBar(playerid, g_PlayerHealthBar[playerid]);
    }

    // Set initial value based on player health
    new Float:hp;
    GetPlayerHealth(playerid, hp);
    SetPlayerProgressBarValue(playerid, g_PlayerHealthBar[playerid], hp);
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    if (g_PlayerHealthBar[playerid] != INVALID_PLAYER_BAR_ID)
    {
        new Float:hp;
        GetPlayerHealth(playerid, hp);

        // Smoothly interpolate the bar value to the new health over 350ms!
        InterpolatePlayerProgressBarValue(playerid, g_PlayerHealthBar[playerid], hp, 350);
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    // ProgressBar.inc automatically destroys all player bars on disconnect,
    // but resetting your gamemode handle slot is good practice:
    g_PlayerHealthBar[playerid] = INVALID_PLAYER_BAR_ID;
    return 1;
}
```

---

## 4. Next Steps

* Explore visual styles and geometry in **[Bar Styles & Geometry](bar-styles.md)**.
* Learn how to activate multi-stop color transitions and ease-out curves in **[Animations & Visual FX](animations-and-fx.md)**.
* Learn how to design HUD bars directly inside GTA SA using the **[In-Game Visual Editor](in-game-editor.md)**.
* Review all available functions and options in the **[Complete API Reference](api-reference.md)**.
