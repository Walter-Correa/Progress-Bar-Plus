# Animations & Visual FX

Progress Bar Plus includes an asynchronous visual effects engine built natively in Pawn. It delivers fluid 30 FPS value interpolation (**Smooth Lerp**), multi-stop **Dynamic Color Gradients**, cyclic **Auto-Fill** loops, and **Blinking Alerts** — all running on high-precision timers without external dependencies.

---

## 1. Smooth Value Interpolation (Lerp)

Value lerp eliminates jarring jumps when updating a progress bar. Instead of snapping instantly from 100% to 40%, the bar slides smoothly to its destination.

### Mathematical Ease-Out Curve
The interpolation engine uses a quadratic ease-out deceleration curve:

$$f(t) = t \cdot (2.0 - t) \quad \text{where} \quad t = \frac{\Delta t_{\text{elapsed}}}{\text{duration}}$$

This provides immediate responsiveness when the transition begins and a gradual, natural deceleration as it arrives at the target value.

### Function Signature
```pawn
stock InterpolatePlayerProgressBarValue(playerid, barid, Float:target_value, duration_ms = 500);
```

* **`target_value`:** Destination progress value (automatically clamped between `PB_MinValue` and `PB_MaxValue`).
* **`duration_ms`:** Transition time in milliseconds (defaults to `500` ms).
* **Refresh Rate:** 30 FPS (`PB_TICK_RATE = 33` ms).

### Control Functions
```pawn
// Stops an ongoing value interpolation immediately at its current position
StopPlayerProgressBarInterpolation(playerid, barid);

// Queries whether the bar is currently interpolating
new bool:isSliding = IsPlayerProgressBarInterpolating(playerid, barid);
```

> [!NOTE]
> **Mutual Exclusion & Auto-Show:** Activating `InterpolatePlayerProgressBarValue`, `AutoFillPlayerProgressBar`, or `BlinkPlayerProgressBar` automatically displays the bar (`ShowPlayerProgressBar`) if previously hidden. Starting an interpolation automatically halts any active AutoFill loop on that bar, and vice-versa.

---

## 2. Dynamic Multi-Stop Color Gradients

The gradient engine dynamically evaluates the bar's current fill percentage and blends across three color stops:

$$\text{Empty (0\%)} \longleftrightarrow \text{Midpoint (50\%)} \longleftrightarrow \text{Full (100\%)}$$

### Standard Defaults (Health / Fuel / Stamina)
* **0% (Empty):** Vivid Red (`0xEF4444FF`)
* **50% (Mid):** Golden Amber (`0xF59E0BFF`)
* **100% (Full):** Emerald Green (`0x10B981FF`)

### Polarity & Direction Modes
You can control the progression direction using `PB_GRAD_STANDARD` or `PB_GRAD_INVERTED`:

| Mode Constant | Polarity | Progression (0% $\to$ 50% $\to$ 100%) | Use Cases |
| :--- | :---: | :--- | :--- |
| `PB_GRAD_STANDARD` | `0` | Red $\to$ Amber $\to$ Green | Health, Armor, Oxygen, Stamina, Fuel |
| `PB_GRAD_INVERTED` | `1` | Green $\to$ Amber $\to$ Red | Weapon Overheat, Engine Temp, Threat Level |

### Function Signatures
```pawn
stock SetPlayerProgressBarGradient(
    playerid,
    barid,
    bool:enable,
    emptyColour = 0xEF4444FF,
    fullColour = 0x10B981FF,
    midColour = 0xF59E0BFF,
    bool:inverted = false
);
```

```pawn
// Switch between Standard (0) and Inverted (1) direction
SetPlayerProgressBarGradientDirection(playerid, barid, PB_GRAD_INVERTED);

// Toggle inversion flag
SetPlayerProgressBarGradientInverted(playerid, barid, true);

// Halt gradient calculations and return to fixed color
StopPlayerProgressBarGradient(playerid, barid);

// Query status
new bool:hasGrad = IsPlayerProgressBarGradientEnabled(playerid, barid);
```

> [!TIP]
> Dynamic Gradients synchronize in real-time with **Smooth Lerp**, **AutoFill animations**, and the **HUD Text Label** (when configured to follow the bar color).

---

## 3. Cyclic Auto-Fill Animations

Auto-Fill smoothly fills the progress bar in a recurring loop from 0% to 100% (or to a custom maximum threshold).

### Function Signature
```pawn
stock SetPlayerProgressBarAutoFill(
    playerid,
    barid,
    bool:enable,
    Float:max_value = -1.0,
    Float:step_pct = 1.0,
    interval_ms = 40
);
```

* **`max_value`:** Ceiling value to fill up to (`-1.0` loops to `PB_MaxValue`).
* **`step_pct`:** Percentage increment added on each tick (defaults to `1.0%`).
* **`interval_ms`:** Timer tick interval (defaults to `40` ms).

```pawn
// Halts the auto-fill animation
StopPlayerProgressBarAutoFill(playerid, barid);

// Checks if the animation is running
new bool:filling = IsPlayerProgressBarAutoFilling(playerid, barid);
```

---

## 4. Pulsing & Blinking Alerts

Blinking alerts draw urgent player attention when a resource reaches a critical threshold (e.g., low oxygen, empty clip, low fuel).

### Function Signature
```pawn
stock SetPlayerProgressBarBlink(
    playerid,
    barid,
    interval_ms = PB_BLINK_DEFAULT,
    duration_ms = 0,
    blink_colour = 0,
    blink_border_colour = 0
);
```

* **`interval_ms`:** Flash cycle frequency (defaults to `250` ms).
* **`duration_ms`:** Total duration in milliseconds before stopping automatically (`0` = infinite until manually stopped).
* **`blink_colour`:** Color shown during the "alternate" phase (`0` = toggle visibility on/off).
* **`blink_border_colour`:** Border color during the alternate phase.

```pawn
// Halts blinking and restores normal appearance
StopPlayerProgressBarBlink(playerid, barid);

// Queries blinking state
new bool:isAlert = IsPlayerProgressBarBlinking(playerid, barid);
```

---

## 5. Advanced Combined Example: Engine Overheat Gauge

This script demonstrates combining an **Inverted Gradient**, **Smooth Lerp**, and an **Emergency Blinking Alert** for a vehicle temperature meter:

```pawn
// Create an Engine Heat Gauge (0°C to 120°C)
new PlayerBar:g_EngineHeatBar[MAX_PLAYERS];

stock SetupEngineHeatGauge(playerid)
{
    g_EngineHeatBar[playerid] = CreatePlayerProgressBar(
        playerid,
        548.0, 390.0,
        60.0, 9.0,
        0x10B981FF,
        120.0,
        PB_DIR_RIGHT
    );

    // Set minimum temperature floor at 40°C
    SetPlayerProgressBarMinValue(playerid, g_EngineHeatBar[playerid], 40.0);

    // Inverted gradient: Green at 40°C -> Amber at 80°C -> Red at 120°C
    SetPlayerProgressBarGradient(playerid, g_EngineHeatBar[playerid], true, 0x10B981FF, 0xEF4444FF, 0xF59E0BFF, true);

    // Attach temperature label in °C
    SetPlayerProgressBarLabel(playerid, g_EngineHeatBar[playerid], true, "{VAL} °C");

    ShowPlayerProgressBar(playerid, g_EngineHeatBar[playerid]);
}

stock UpdateEngineHeat(playerid, Float:newTemp)
{
    new PlayerBar:bar = g_EngineHeatBar[playerid];
    if (bar == INVALID_PLAYER_BAR_ID) return;

    // Smoothly slide to new temperature over 400ms
    InterpolatePlayerProgressBarValue(playerid, bar, newTemp, 400);

    // If engine exceeds 105°C, pulse red alert!
    if (newTemp >= 105.0)
    {
        if (!IsPlayerProgressBarBlinking(playerid, bar))
        {
            SetPlayerProgressBarBlink(playerid, bar, 180, 0, 0xFF0000FF, 0xFFFFFFFF);
        }
    }
    else
    {
        if (IsPlayerProgressBarBlinking(playerid, bar))
        {
            StopPlayerProgressBarBlink(playerid, bar);
        }
    }
}
```
