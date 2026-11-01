// ============================================================================
// Sample Importable Pawn Code Snippet
// Drop any .pwn, .inc, or .txt file containing CreatePlayerProgressBar(...)
// calls into "scriptfiles/Progress Bars/Imports/" and import it in-game via:
//   PROJECT -> Import Wizard -> Import Pawn Code File (.pwn / .txt)
// Both Progress Bar Plus (13 args) and legacy progress2 (8 args) are parsed!
// ============================================================================

HungerBar[playerid] = CreatePlayerProgressBar(playerid, 548.0, 114.0, 60.5, 8.0, 0xF59E0BFF, 100.0, PB_DIR_RIGHT, 1.0, 0x0F172AE6, PB_STYLE_BAR, 24, 1.0);
ThirstBar[playerid] = CreatePlayerProgressBar(playerid, 548.0, 126.0, 60.5, 8.0, 0x38BDF8FF, 100.0, PB_DIR_RIGHT, 1.0, 0x0F172AE6, PB_STYLE_BAR, 24, 1.0);
RadarRing[playerid] = CreatePlayerProgressBar(playerid, 15.0, 315.0, 94.0, 117.5, 0x10B981FF, 100.0, PB_DIR_RIGHT, 0.8, 0x000000CC, PB_STYLE_RING, 28, 1.0);
