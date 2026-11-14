# In-Game Visual Editor Manual

**Progress Bar Plus - Editor** is a standalone, full-featured in-game visual HUD design suite. It eliminates manual coordinate math and trial-and-error server restarts by providing a real-time, interactive WYSIWYG (What You See Is What You Get) design environment inside GTA San Andreas.

---

## 1. Launching the Editor

The editor is available in two ready-to-run configurations located in the `Progress Bar Plus - Editor/` directory:

### As a Filterscript (Recommended for existing servers)
Add `FS_ProgressBarEditor` to your `server.cfg` or `config.json` filterscripts line, or load it via RCON:
```
loadfs FS_ProgressBarEditor
```

### As a Standalone Test Gamemode
Run the sandbox gamemode `GM_ProgressBarEditor` to launch a clean, lightweight local development server with godmode, weather control, and instant teleportation.

### Opening the Interface
Type the command in-game:
```
/pbe
```

> [!NOTE]
> **Concurrent Multi-User Sessions:** The editor supports up to $10$ simultaneous developers (`PBE_MAX_SESSIONS = 10`). An automatic **Project Lock** mechanism prevents multiple developers from accidentally overwriting the same project file at the same time.

### Commands Reference (`Pawn.CMD`)

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

---

## 2. Clickable 11-Button Dock

When you open `/pbe`, a floating interactive control dock appears on your screen:

```
[ PROJECT ] [ + CREATE ] [ LAYERS ] [ MOVE ] [ RESIZE ] [ STYLE ] [ COLORS ] [ ANIMATE ] [ TOOLS ] [ EXPORT ] [ VIEW ]
```

### Dock Buttons Reference
1. **`PROJECT`:** Manage workspace files: New, Open/Load project, Save, Save As, Delete, or Import existing Pawn code/PBP files.
2. **`+ CREATE`:** Add a new progress bar layer (supports up to $20$ layers per project) or instantiate ready-made HUD templates.
3. **`LAYERS`:** Manage active layers: select, rename, duplicate, reorder Z-Index (Bring Forward/Send Backward), toggle visibility, or delete.
4. **`MOVE`:** Open positioning menu: choose between **Interactive Keyboard Mode** (`WASD` / Arrow keys) for real-time movement, or **Enter Exact Screen Coordinates** $(X, Y)$ via dialog input.
5. **`RESIZE`:** Open resizing menu: choose between **Interactive Keyboard Mode** (`WASD` / Arrow keys) for real-time sizing with aspect lock, or **Enter Exact Dimensions** (Width, Height) via dialog input (automatically bounded by style minimums).
6. **`STYLE`:** Switch visual gauge style (Linear Bar, Radial Ring, Circular Disc), fill direction, ring segments ($4$ to $60$), ring scale ($0.10$ to $3.00$), interactive border thickness scrubber / exact thickness, and configure attached text labels.
7. **`COLORS`:** Open the 60-swatch palette or enter raw RGBA hex codes. Configure bar fill color, background dimming, border color, and Dynamic Health Gradients.
8. **`ANIMATE`:** Test Smooth Lerp transitions, AutoFill cyclic animations, Blinking alerts, interactive value scrubbing, and minimum/maximum value thresholds.
9. **`TOOLS`:** Precision alignment suite: Center horizontally/vertically/both, GTA:SA default HUD anchor slots, relative multi-bar edge alignment & stacking, 16:9 perfect circle ratio, integer snapping, and 1-step Undo.
10. **`EXPORT`:** Generate production-ready Pawn code formatted for Gamemodes or Filterscripts.
11. **`VIEW`:** Configure editor environment: toggle background preview grid, cycle dock position (Bottom, Top, Minimized HUD preview), view keybinding guide, or exit editor.

### Dock Modes & Live Telemetry
* **Dock Position:** You can cycle the dock between **Bottom Dock**, **Top Dock**, and **Minimized Preview** (hides all editor textdraws to let you inspect your clean HUD overlay).
* **Live Telemetry HUD:** Displays real-time layer data: Layer Name, Coordinates $(X, Y)$, Dimensions $(W, H)$, Fill Value, Zoom Factor, and a dirty indicator (`[Saved]` / `{EF4444}[Unsaved]`).

---

## 3. Real-Time 35ms Transform Engine

The transform engine allows you to manipulate progress bars smoothly using your keyboard at a crisp $35$ ms tick rate:

### Keyboard Controls
* **Movement / Sizing:** Use `W` / `A` / `S` / `D` or the **Arrow Keys** (Up, Down, Left, Right).
* **Speed Modifiers:**
  * **Precision Mode (`Alt` / Walk):** Steps by only $0.10$ pixels for sub-pixel alignment.
  * **Fast Mode (`Shift` / `Ctrl` / Sprint / Jump):** Steps by $2.50$ pixels for rapid positioning across the screen.

### Transform Modes
* **Move Mode:** Repositions the bar across the $640 \times 448$ canvas.
* **Resize Mode:** Adjusts bar width and height independently or with aspect-ratio lock.
* **Border Mode:** Dynamically thickens or thins the border outline in real-time.
* **Scrub Mode:** Slides the progress value from 0% to 100% to test visual fill aesthetics.

### Grid Snapping & Aspect Lock
* **Grid Snapping:** Toggle between `Off`, `1px`, and `5px` magnetic grid alignment.
* **Aspect Lock ($16:9$):** Automatically locks Radial Rings and Circular Gauges to maintain a true, distortion-free circle on widescreen monitors ($Height = Width \times 1.25$).

---

## 4. Multi-Layer Workspace & Undo

Complex HUD meters (such as combined speedometer + odometer + fuel ring) require multiple overlapping layers:

* **Layer Capacity:** Up to $20$ bar layers per project (`PBE_MAX_BARS = 20`).
* **Layer Selector:** Fast dialog to switch between layers or rename layer identifiers (e.g., `CarSpeed`, `CarFuel`, `CarTachometer`).
* **Z-Order Reordering:** Move layers forward or backward to control overlapping rendering order.
* **1-Step Snapshot Undo:** Instant rollback to recover from accidental deletions, movements, or style changes.

---

## 5. GTA:SA HUD Anchor Presets

Instead of manually placing bars near native GTA SA HUD elements, the **Align** menu features 8 one-click HUD Anchor presets:

1. **Radar / Minimap:** Aligns to the top or bottom of the GTA SA radar.
2. **Weapon Icon:** Positions right below the native weapon box.
3. **Cash Display:** Centers below the green cash digits.
4. **Health Bar:** Replaces or aligns beneath the standard GTA SA red health meter.
5. **Armour Bar:** Aligns beneath the native white armour meter.
6. **Breath Meter:** Positions in the native underwater lung capacity slot.
7. **Vehicle Name:** Anchors above the bottom-right vehicle title text.
8. **Center Screen:** Centers the bar horizontally and vertically on the display.

---

## 6. Universal Exporter

Once you finish designing, the **Export** menu automatically generates clean, organized Pawn code:

### Export Formats
* **Filterscript Format:** Generates self-contained code with arrays and `CreatePlayerProgressBar` calls ready to paste into any filterscript.
* **Gamemode Format:** Generates structured functions (`Create<Name>Bars(playerid)`) and handles with player lifecycle hooks.
* **Project File (`.pbp`):** Saves complete project state, names, and layers for future re-editing.
* **Reusable Template (`.pbt`):** Saves the bar design as a universal template that can be inserted into any other project with one click.

---

## 7. Network Performance & Anti-Kick Protection

In high-density radial rings ($45$ to $60$ segments), a single ring consists of up to $120$ individual TextDraw handles.

In unoptimized editors, moving or resizing such an object continuously destroys and recreates all $120$ TextDraws on every $35$ ms timer tick, generating over $7,000$ packets/second and triggering SA-MP / open.mp's kick:
`client exceeded 'ackslimit' ... Limit: 3000/sec`.

**Progress Bar Plus - Editor solves this with an intelligent throttling & auto-flush architecture:**
1. **Uninterrupted Coordinate Accumulation:** Position and scale math accumulates continuously on every tick without dropping keypresses, keeping telemetry numbers responsive at 30 FPS.
2. **Density-Aware Rebuild Throttling:** Rebuilding heavy radial rings during continuous movement is throttled to safe intervals ($200$ ms for $\ge 45$ segments, $120$ ms for $\ge 30$, $70$ ms for $< 30$).
3. **Immediate Key-Release Flush:** The moment arrow or WASD keys are released, any pending rebuild is immediately rendered on-screen, guaranteeing pixel-perfect alignment without delay.
4. **Result:** Packet volume drops to under $1,300$ packets/sec (well below the $3,000$ limit), guaranteeing **100% kick-free operation** and full visual fluidity even with 60-segment radial gauges!
