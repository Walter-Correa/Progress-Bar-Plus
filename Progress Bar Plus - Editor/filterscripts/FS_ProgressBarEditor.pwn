/*
================================================================================
    Progress Bar Plus - Editor (Filterscript)
    A complete in-game visual design, project management, import, and code
    generation suite for SA-MP and open.mp.

    Author:      Walter Corrêa
    Version:     2.2.0
    Repository:  https://github.com/Walter-Correa/Progress-Bar-Plus
    License:     Mozilla Public License 2.0 (MPL-2.0)

    Dependencies:
    - Progress Bar Plus (ProgressBar.inc v2.2.0+)
    - Pawn.CMD by urShadow (https://github.com/urShadow/Pawn.CMD)
================================================================================
*/

#define FILTERSCRIPT

#if !defined _samp_included && !defined _INC_open_mp
	#if __Pawn >= 0x030A
		#tryinclude <open.mp>
	#endif
	#if !defined _INC_open_mp
		#include <a_samp>
	#endif
#endif

#include <Pawn.CMD>

#if !defined PBE_MAX_BARS
	#define PBE_MAX_BARS (20)
#endif

// Scope internal ProgressBar.inc pool in this filterscript to editor capacity
#if !defined MAX_PLAYER_BARS
	#define MAX_PLAYER_BARS (PBE_MAX_BARS + 4)
#endif

#tryinclude "../../ProgressBar.inc"
#if !defined _progressbar_included && !defined _progressbarplus_included
	#tryinclude <ProgressBar>
#endif
#if !defined _progressbar_included && !defined _progressbarplus_included
	#error ProgressBar.inc not found! Copy ProgressBar.inc into pawno/include or qawno/include.
#endif

/*
================================================================================
    1. Configuration & Cross-Platform Compatibility Macros
================================================================================
*/

#if !defined PBE_DIALOG_BASE
	#define PBE_DIALOG_BASE (28400)
#endif

#if !defined PBE_MAX_SESSIONS
	#define PBE_MAX_SESSIONS (10)
#endif

#if !defined PBE_RCON_ONLY
	#define PBE_RCON_ONLY (0)
#endif

#define PBE_VERSION          PROGRESSBAR_VERSION_STRING
#define PBE_INVALID_SESSION  (-1)
#define PBE_MAX_NAME         (32)
#define PBE_MAX_PROJECT_NAME (40)
#define PBE_MAX_PATH         (128)
#define PBE_MAX_INDEX_ITEMS  (48)
#define PBE_DOCK_BUTTONS     (11)
#define PBE_TICK_RATE        (35)
#define PBE_RING_THROTTLE_MS (65)

#define PBE_DIR_ROOT         "Progress Bars/"
#define PBE_DIR_PROJECTS     "Progress Bars/Projects/"
#define PBE_DIR_TEMPLATES    "Progress Bars/Templates/"
#define PBE_DIR_EXPORTS      "Progress Bars/Exports/"
#define PBE_DIR_IMPORTS      "Progress Bars/Imports/"
#define PBE_PROJECT_INDEX    "Progress Bars/Projects/_index.lst"
#define PBE_TEMPLATE_INDEX   "Progress Bars/Templates/_index.lst"

#if defined _INC_open_mp
	#define PBE_FONT_1       TEXT_DRAW_FONT_1
	#define PBE_FONT_2       TEXT_DRAW_FONT_2
	#define PBE_FONT_SPRITE  TEXT_DRAW_FONT_SPRITE_DRAW
	#define PBE_ALIGN_CENTER TEXT_DRAW_ALIGN_CENTER
	#define PBE_TD_BOOL(%0)  (bool:(%0))
	#define PBE_DLG_STYLE    DIALOG_STYLE:
	#define PBE_KEY_TAG      KEY:
#else
	#define PBE_FONT_1       (1)
	#define PBE_FONT_2       (2)
	#if defined TEXT_DRAW_FONT_SPRITE_DRAW
		#define PBE_FONT_SPRITE TEXT_DRAW_FONT_SPRITE_DRAW
	#else
		#define PBE_FONT_SPRITE (4)
	#endif
	#define PBE_ALIGN_CENTER (2)
	#define PBE_TD_BOOL(%0)  (_:(%0))
	#define PBE_DLG_STYLE
	#define PBE_KEY_TAG
#endif

#if defined INVALID_PLAYER_TEXT_DRAW
	#define PBE_NO_PTD INVALID_PLAYER_TEXT_DRAW
#else
	#define PBE_NO_PTD (PlayerText:INVALID_TEXT_DRAW)
#endif

#define PBE_NO_TD (Text:INVALID_TEXT_DRAW)

#if !defined DIALOG_STYLE_TABLIST
	#define DIALOG_STYLE_TABLIST (4)
#endif

#if !defined DIALOG_STYLE_TABLIST_HEADERS
	#define DIALOG_STYLE_TABLIST_HEADERS (5)
#endif

#if defined TextDrawColour
	#define PBE_TDColor TextDrawColour
	#define PBE_TDBgColor TextDrawBackgroundColour
#else
	#define PBE_TDColor TextDrawColor
	#define PBE_TDBgColor TextDrawBackgroundColor
#endif

#if defined PlayerTextDrawColour
	#define PBE_PTDColor PlayerTextDrawColour
	#define PBE_PTDBgColor PlayerTextDrawBackgroundColour
#else
	#define PBE_PTDColor PlayerTextDrawColor
	#define PBE_PTDBgColor PlayerTextDrawBackgroundColor
#endif

// Chat & Editor UI Theme Colors
#define PBE_CHAT_BRAND       (0x38BDF8FF)
#define PBE_CHAT_OK          (0x10B981FF)
#define PBE_CHAT_WARN        (0xF59E0BFF)
#define PBE_CHAT_ERR         (0xEF4444FF)
#define PBE_CHAT_INFO        (0xE2E8F0FF)
#define PBE_UI_HOVER         (0x38BDF8FF)

/*
================================================================================
    2. Enumerations, Palettes & Compact Session Pool Structures
================================================================================
*/

enum
{
	PBE_DLG_PROJECT_MENU = PBE_DIALOG_BASE,
	PBE_DLG_NEW_CONFIRM,
	PBE_DLG_NEW_NAME,
	PBE_DLG_LOAD_LIST,
	PBE_DLG_LOAD_DIRECT,
	PBE_DLG_SAVE_AS,
	PBE_DLG_DELETE_PROJ_LIST,
	PBE_DLG_DELETE_PROJ_CONF,

	PBE_DLG_IMPORT_MENU,
	PBE_DLG_IMPORT_PBP_OPEN,
	PBE_DLG_IMPORT_PBP_MERGE,
	PBE_DLG_IMPORT_CODE_FILE,
	PBE_DLG_IMPORT_PASTE,

	PBE_DLG_EXPORT_MENU,
	PBE_DLG_EXPORT_NAME,

	PBE_DLG_CREATE_MENU,
	PBE_DLG_TEMPLATE_LIST,
	PBE_DLG_SAVE_TEMPLATE,

	PBE_DLG_LAYERS_LIST,
	PBE_DLG_LAYER_ACTIONS,
	PBE_DLG_RENAME_BAR,
	PBE_DLG_DELETE_BAR_CONF,

	PBE_DLG_STYLE_MENU,
	PBE_DLG_STYLE_PICK,
	PBE_DLG_DIRECTION_PICK,
	PBE_DLG_SEGMENTS_INPUT,
	PBE_DLG_SEG_SCALE_INPUT,
	PBE_DLG_BORDER_SIZE_INP,
	PBE_DLG_EXACT_POS_INPUT,
	PBE_DLG_EXACT_SIZE_INPUT,

	PBE_DLG_LABEL_MENU,
	PBE_DLG_LABEL_PRESETS,
	PBE_DLG_LABEL_TEXT_INP,
	PBE_DLG_LABEL_COLOR_PAL,
	PBE_DLG_LABEL_COLOR_HEX,
	PBE_DLG_LABEL_FONT_PICK,
	PBE_DLG_LABEL_ALIGN_PICK,
	PBE_DLG_LABEL_SCALE_INP,
	PBE_DLG_LABEL_OFFSET_INP,

	PBE_DLG_COLOR_MENU,
	PBE_DLG_MAIN_PALETTE,
	PBE_DLG_MAIN_HEX_INPUT,
	PBE_DLG_MAIN_ALPHA_PICK,
	PBE_DLG_BORDER_PALETTE,
	PBE_DLG_BORDER_HEX_INPUT,
	PBE_DLG_COPY_STYLE_PICK,

	PBE_DLG_ANIMATE_MENU,
	PBE_DLG_VALUE_PRESETS,
	PBE_DLG_VALUE_EXACT,
	PBE_DLG_MAX_VALUE_INPUT,
	PBE_DLG_MIN_VALUE_INPUT,
	PBE_DLG_AUTOFILL_INPUT,
	PBE_DLG_BLINK_MENU,
	PBE_DLG_BLINK_TIMING,
	PBE_DLG_BLINK_COL_PAL,
	PBE_DLG_BLINK_COL_HEX,
	PBE_DLG_BLINK_BCOL_PAL,
	PBE_DLG_BLINK_BCOL_HEX,

	PBE_DLG_TOOLS_MENU,
	PBE_DLG_GTA_ANCHORS,
	PBE_DLG_REL_TARGET_PICK,
	PBE_DLG_REL_ACTION_PICK,
	PBE_DLG_STACK_GAP_INPUT,

	PBE_DLG_VIEW_MENU,
	PBE_DLG_EXIT_CONFIRM,
	PBE_DLG_HELP_GUIDE,

	PBE_DIALOG_END
};

enum
{
	PBE_MODE_NONE = 0,
	PBE_MODE_MOVE,
	PBE_MODE_RESIZE,
	PBE_MODE_BORDER,
	PBE_MODE_SCRUB
};

enum
{
	PBE_DOCK_BOTTOM = 0,
	PBE_DOCK_TOP,
	PBE_DOCK_HIDDEN
};

enum
{
	PBE_EXP_GAMEMODE_PWN = 0,
	PBE_EXP_MODULAR_INC,
	PBE_EXP_RAW_SNIPPET
};

enum E_PBE_SWATCH
{
	Swatch_Name[36],
	Swatch_HexStr[7],
	Swatch_RGBA
};

static const g_PBESwatches[][E_PBE_SWATCH] =
{
	{"Modern Flat Crimson",     "E74C3C", 0xE74C3CFF},
	{"GTA Classic Health Red",  "B4191D", 0xB4191DFF},
	{"GTA Classic Money Green", "36682C", 0x36682CFF},
	{"GTA Classic Armour Grey", "E1E1E1", 0xE1E1E1FF},
	{"GTA Wanted Gold",         "906210", 0x906210FF},
	{"Emerald Vitality",        "10B981", 0x10B981FF},
	{"Neon Lime Surge",         "84CC16", 0x84CC16FF},
	{"Sky Cyan",                "38BDF8", 0x38BDF8FF},
	{"Royal Electric Blue",     "3B82F6", 0x3B82F6FF},
	{"Deep Cobalt Ocean",       "1D4ED8", 0x1D4ED8FF},
	{"Indigo Night",            "6366F1", 0x6366F1FF},
	{"Amethyst Arcane",         "8B5CF6", 0x8B5CF6FF},
	{"Fuchsia Pulse",           "D946EF", 0xD946EFFF},
	{"Rose Neon Pink",          "F43F5E", 0xF43F5EFF},
	{"Alert Scarlet Red",       "EF4444", 0xEF4444FF},
	{"Sunset Flame Orange",     "F97316", 0xF97316FF},
	{"Amber Speedometer",       "F59E0B", 0xF59E0BFF},
	{"Solar Yellow",            "FACC15", 0xFACC15FF},
	{"Teal Turquoise",          "14B8A6", 0x14B8A6FF},
	{"Pure Crisp White",        "FFFFFF", 0xFFFFFFFF},
	{"Silver Mist",             "CBD5E1", 0xCBD5E1FF},
	{"Cool Slate Grey",         "64748B", 0x64748BFF},
	{"Dark Obsidian Glass",     "0F172A", 0x0F172AE6},
	{"Pure Pitch Black",        "000000", 0x000000FF}
};

enum E_PBE_ANCHOR
{
	Anchor_Name[48],
	Anchor_Style,
	Float:Anchor_X,
	Float:Anchor_Y,
	Float:Anchor_W,
	Float:Anchor_H
};

static const g_PBEAnchors[][E_PBE_ANCHOR] =
{
	{"GTA Health Bar Slot",             PB_STYLE_BAR,    548.0,  68.0,  60.5,   8.0},
	{"GTA Armour Bar Slot",             PB_STYLE_BAR,    548.0,  45.0,  60.5,   8.0},
	{"Below GTA Money Readout",         PB_STYLE_BAR,    497.0, 104.0, 111.0,   8.0},
	{"Above GTA Radar Minimap",         PB_STYLE_BAR,     34.0, 308.0,  96.0,   8.0},
	{"Around GTA Radar Ring (16:9)",    PB_STYLE_RING,    15.0, 315.0,  94.0, 117.5},
	{"Bottom-Center Action Cast Bar",   PB_STYLE_BAR,    245.0, 378.0, 150.0,   9.5},
	{"Vehicle Speedometer Dial (16:9)", PB_STYLE_RING,   532.0, 312.0,  68.0,  85.0},
	{"Center Screen Skill Gauge (16:9)",PB_STYLE_CIRCLE, 300.0, 199.0,  40.0,  50.0}
};

static const g_PBEDockLabels[PBE_DOCK_BUTTONS][12] =
{
	"PROJECT",
	"+ CREATE",
	"LAYERS",
	"MOVE",
	"RESIZE",
	"STYLE",
	"COLORS",
	"ANIMATE",
	"TOOLS",
	"EXPORT",
	"VIEW"
};

enum E_PBE_BAR
{
	bool:EBar_Used,
	EBar_Handle,
	EBar_Name[PBE_MAX_NAME],
	EBar_Style,
	Float:EBar_X,
	Float:EBar_Y,
	Float:EBar_W,
	Float:EBar_H,
	EBar_Color,
	Float:EBar_Min,
	Float:EBar_Max,
	Float:EBar_Val,
	EBar_Dir,
	Float:EBar_Border,
	EBar_BorderColor,
	EBar_Segments,
	Float:EBar_SegScale,
	bool:EBar_Visible,
	bool:EBar_AutoFill,
	Float:EBar_AutoFillMax,
	bool:EBar_Blinking,
	EBar_BlinkInterval,
	EBar_BlinkDuration,
	EBar_BlinkColor,
	EBar_BlinkBorderColor,
	bool:EBar_LabelShow,
	bool:EBar_LabelAutoScale,
	bool:EBar_LabelFollowCol,
	EBar_LabelOrient,
	EBar_LabelText[32],
	EBar_LabelColor,
	EBar_LabelFont,
	EBar_LabelAlign,
	Float:EBar_LabelScaleX,
	Float:EBar_LabelScaleY,
	Float:EBar_LabelOffsetX,
	Float:EBar_LabelOffsetY,
	bool:EBar_Gradient,
	bool:EBar_GradInvert,
	EBar_GradEmpty,
	EBar_GradMid,
	EBar_GradFull
};

enum E_PBE_SESSION
{
	bool:EP_Active,
	EP_PlayerID,
	bool:EP_CursorOn,
	bool:EP_SuppressCancel,
	bool:EP_Dirty,
	bool:EP_ShowGrid,
	bool:EP_AspectLock,
	EP_GridSnapMode,
	EP_DockPos,
	EP_EditMode,
	EP_Timer,
	EP_Selected,
	EP_BarCount,
	EP_ExportFormat,
	EP_RelTargetSlot,
	EP_RelPendingAct,
	EP_DeleteTargetIdx,
	EP_LastRingRebuild,
	bool:EP_RingPendingRebuild,
	Float:EP_OrigX,
	Float:EP_OrigY,
	Float:EP_RawX,
	Float:EP_RawY,
	Float:EP_OrigW,
	Float:EP_OrigH,
	Float:EP_OrigBorder,
	Float:EP_OrigVal,
	EP_ProjectName[PBE_MAX_PROJECT_NAME],
	Text:EP_TDStatus,
	Text:EP_TDHelper
};

enum E_PBE_UNDO_META
{
	bool:EUndo_Available,
	EUndo_Selected,
	EUndo_BarCount,
	EUndo_Desc[48]
};

static bool:g_PBERconLocked = (PBE_RCON_ONLY != 0);

static Text:g_TD_DockBg[2]    = {PBE_NO_TD, ...};
static Text:g_TD_DockTrim[2]  = {PBE_NO_TD, ...};
static Text:g_TD_DockBtn[2][PBE_DOCK_BUTTONS];
static Text:g_TD_DockLbl[2][PBE_DOCK_BUTTONS];
static Text:g_TD_MiniPillBg   = PBE_NO_TD;
static Text:g_TD_MiniPillLbl  = PBE_NO_TD;
static Text:g_TD_GridLines[6] = {PBE_NO_TD, ...};

// Lightweight O(1) playerid -> session pool index lookup & welcome tracker
static g_PlayerSession[MAX_PLAYERS] = {PBE_INVALID_SESSION, ...};
static bool:g_PlayerWelcomed[MAX_PLAYERS];

// Compact Editor Session Pool (~137 KB total instead of ~14 MB)
static EditorSession[PBE_MAX_SESSIONS][E_PBE_SESSION];
static EditorBars[PBE_MAX_SESSIONS][PBE_MAX_BARS][E_PBE_BAR];
static EditorUndoMeta[PBE_MAX_SESSIONS][E_PBE_UNDO_META];
static EditorUndoBars[PBE_MAX_SESSIONS][PBE_MAX_BARS][E_PBE_BAR];
static g_PBEBrowserCache[PBE_MAX_SESSIONS][PBE_MAX_INDEX_ITEMS][PBE_MAX_PROJECT_NAME];
static g_PBEBrowserCount[PBE_MAX_SESSIONS];

// Shared non-reentrant dialog formatting buffers to keep stack usage tiny
static s_DlgBody[4096];
static s_DlgRow[512];

forward PBE_TransformTick(playerid);

/*
================================================================================
    3. Session Pool Lookup, String, Color & Sanitization Utilities
================================================================================
*/

static stock PBE_GetSlot(playerid)
{
	if (!(0 <= playerid < MAX_PLAYERS)) return PBE_INVALID_SESSION;
	new sid = g_PlayerSession[playerid];
	if (0 <= sid < PBE_MAX_SESSIONS && EditorSession[sid][EP_Active] && EditorSession[sid][EP_PlayerID] == playerid)
	{
		return sid;
	}
	return PBE_INVALID_SESSION;
}

static stock PBE_AllocSlot(playerid)
{
	new existing = PBE_GetSlot(playerid);
	if (existing != PBE_INVALID_SESSION) return existing;

	for (new sid = 0; sid < PBE_MAX_SESSIONS; sid++)
	{
		if (!EditorSession[sid][EP_Active])
		{
			g_PlayerSession[playerid] = sid;
			EditorSession[sid][EP_Active] = true;
			EditorSession[sid][EP_PlayerID] = playerid;
			return sid;
		}
	}
	return PBE_INVALID_SESSION;
}

static stock PBE_SendMsg(playerid, color, const prefix[], const text[])
{
	new out[145];
	format(out, sizeof out, "{38BDF8}[PB Editor]{FFFFFF} %s%s", prefix, text);
	SendClientMessage(playerid, color, out);
}

static stock PBE_FormatHex(color, dest[], size = sizeof dest)
{
	format(dest, size, "0x%04x%04x", (color >>> 16) & 0xFFFF, color & 0xFFFF);
}

static stock PBE_FormatRGBTag(color, dest[], size = sizeof dest)
{
	format(dest, size, "{%02x%02x%02x}", (color >>> 24) & 0xFF, (color >>> 16) & 0xFF, (color >>> 8) & 0xFF);
}

static stock bool:PBE_ParseHexColor(const str[], &outColor)
{
	new start = 0, len = strlen(str);
	while (start < len && str[start] <= ' ') start++;
	while (len > start && str[len - 1] <= ' ') len--;
	if (len - start >= 2 && str[start] == '0' && (str[start + 1] == 'x' || str[start + 1] == 'X'))
	{
		start += 2;
	}
	else if (len - start >= 1 && str[start] == '#')
	{
		start += 1;
	}
	new digits = len - start;
	if (digits != 6 && digits != 8) return false;
	new val = 0;
	for (new i = start; i < len; i++)
	{
		new ch = str[i], nib;
		if ('0' <= ch <= '9') nib = ch - '0';
		else if ('a' <= ch <= 'f') nib = ch - 'a' + 10;
		else if ('A' <= ch <= 'F') nib = ch - 'A' + 10;
		else return false;
		val = (val << 4) | nib;
	}
	if (digits == 6) val = (val << 8) | 0xFF;
	outColor = val;
	return true;
}

static stock PBE_StripNewline(str[])
{
	new len = strlen(str);
	while (len > 0 && (str[len - 1] == '\r' || str[len - 1] == '\n' || str[len - 1] == ' ' || str[len - 1] == '\t'))
	{
		str[--len] = '\0';
	}
}

static stock PBE_Trim(const src[], dest[], maxLen = sizeof dest)
{
	new start = 0, end = strlen(src);
	while (start < end && (src[start] == ' ' || src[start] == '\t' || src[start] == '\r' || src[start] == '\n')) start++;
	while (end > start && (src[end - 1] == ' ' || src[end - 1] == '\t' || src[end - 1] == '\r' || src[end - 1] == '\n')) end--;
	new outIdx = 0;
	for (new i = start; i < end && outIdx < maxLen - 1; i++)
	{
		dest[outIdx++] = src[i];
	}
	dest[outIdx] = '\0';
}

static stock bool:PBE_SplitTwoTokens(const src[], tok1[], len1, tok2[], len2)
{
	new clean[96];
	PBE_Trim(src, clean, sizeof clean);
	if (clean[0] == '\0') return false;

	new sep = strfind(clean, ",");
	if (sep == -1)
	{
		for (new i = 0; clean[i] != '\0'; i++)
		{
			if (clean[i] == ' ' || clean[i] == '\t')
			{
				sep = i;
				break;
			}
		}
	}
	if (sep <= 0) return false;

	new raw1[48], raw2[48];
	strmid(raw1, clean, 0, sep, sizeof raw1);
	strmid(raw2, clean, sep + 1, strlen(clean), sizeof raw2);
	PBE_Trim(raw1, tok1, len1);
	PBE_Trim(raw2, tok2, len2);
	return (tok1[0] != '\0' && tok2[0] != '\0');
}

static stock PBE_SanitizeFileName(const src[], dest[], maxLen = sizeof dest)
{
	new outIdx = 0;
	for (new i = 0; src[i] != '\0' && outIdx < maxLen - 1; i++)
	{
		new ch = src[i];
		if (('a' <= ch <= 'z') || ('A' <= ch <= 'Z') || ('0' <= ch <= '9') || ch == '_' || ch == '-' || ch == ' ')
		{
			if (ch == ' ' && outIdx == 0) continue;
			dest[outIdx++] = ch;
		}
	}
	while (outIdx > 0 && dest[outIdx - 1] == ' ') outIdx--;
	dest[outIdx] = '\0';
}

static stock PBE_NormalizeProjectName(const rawName[], dest[], maxLen = sizeof dest)
{
	new work[PBE_MAX_PROJECT_NAME + 16];
	format(work, sizeof work, "%s", rawName);
	PBE_Trim(work, work, sizeof work);
	new rawLen = strlen(work);
	if (rawLen > 8 && !strcmp(work[rawLen - 8], "_raw.txt", true))
	{
		work[rawLen - 8] = '\0';
	}
	else if (rawLen > 4 && (!strcmp(work[rawLen - 4], ".pbp", true) || !strcmp(work[rawLen - 4], ".pwn", true) || !strcmp(work[rawLen - 4], ".inc", true) || !strcmp(work[rawLen - 4], ".txt", true)))
	{
		work[rawLen - 4] = '\0';
	}
	PBE_SanitizeFileName(work, dest, maxLen);
}

static stock PBE_FindProjectLockOwner(const rawProjName[], excludeSid = PBE_INVALID_SESSION)
{
	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_NormalizeProjectName(rawProjName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return PBE_INVALID_SESSION;

	for (new s = 0; s < PBE_MAX_SESSIONS; s++)
	{
		if (s == excludeSid || !EditorSession[s][EP_Active]) continue;
		new ownerPid = EditorSession[s][EP_PlayerID];
		if (!IsPlayerConnected(ownerPid)) continue;
		if (EditorSession[s][EP_ProjectName][0] != '\0' && !strcmp(EditorSession[s][EP_ProjectName], cleanName, true))
		{
			return s;
		}
	}
	return PBE_INVALID_SESSION;
}

static stock bool:PBE_CheckProjectLocked(playerid, excludeSid, const rawProjName[])
{
	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_NormalizeProjectName(rawProjName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return false;

	new ownerSid = PBE_FindProjectLockOwner(cleanName, excludeSid);
	if (ownerSid == PBE_INVALID_SESSION) return false;

	new ownerPid = EditorSession[ownerSid][EP_PlayerID];
	new ownerName[MAX_PLAYER_NAME + 1];
	GetPlayerName(ownerPid, ownerName, sizeof ownerName);

	new msg[144];
	format(msg, sizeof msg, "{38BDF8}%s{FFFFFF} is currently open by {F59E0B}%s (ID %d){FFFFFF}.", cleanName, ownerName, ownerPid);
	PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Locked: ", msg);
	return true;
}

static stock PBE_MakeUniqueBlankName(excludeSid, dest[], maxLen = sizeof dest)
{
	new candidate[PBE_MAX_PROJECT_NAME];
	for (new n = 1; n <= 99; n++)
	{
		if (n == 1) format(candidate, sizeof candidate, "Untitled_HUD");
		else format(candidate, sizeof candidate, "Untitled_HUD_%d", n);

		if (PBE_FindProjectLockOwner(candidate, excludeSid) == PBE_INVALID_SESSION)
		{
			format(dest, maxLen, "%s", candidate);
			return;
		}
	}
	format(dest, maxLen, "Untitled_HUD_%d", excludeSid + 1);
}

static stock PBE_SanitizeVarName(const src[], dest[], maxLen = sizeof dest)
{
	new outIdx = 0;
	for (new i = 0; src[i] != '\0' && outIdx < maxLen - 1; i++)
	{
		new ch = src[i];
		if (('a' <= ch <= 'z') || ('A' <= ch <= 'Z') || ch == '_' || (outIdx > 0 && '0' <= ch <= '9'))
		{
			dest[outIdx++] = ch;
		}
		else if (ch == ' ' || ch == '-')
		{
			if (outIdx > 0 && dest[outIdx - 1] != '_') dest[outIdx++] = '_';
		}
	}
	if (outIdx == 0)
	{
		format(dest, maxLen, "ProgressBar_1");
		return;
	}
	dest[outIdx] = '\0';
}

static stock PBE_GetStyleShort(style, dest[], size = sizeof dest)
{
	switch (style)
	{
		case PB_STYLE_RING:   format(dest, size, "RING");
		case PB_STYLE_CIRCLE: format(dest, size, "CIRCLE");
		default:              format(dest, size, "BAR");
	}
}

static stock PBE_GetStyleConst(style, dest[], size = sizeof dest)
{
	switch (style)
	{
		case PB_STYLE_RING:   format(dest, size, "PB_STYLE_RING");
		case PB_STYLE_CIRCLE: format(dest, size, "PB_STYLE_CIRCLE");
		default:              format(dest, size, "PB_STYLE_BAR");
	}
}

static stock PBE_GetDirConst(dir, dest[], size = sizeof dest)
{
	switch (dir)
	{
		case PB_DIR_LEFT: format(dest, size, "PB_DIR_LEFT");
		case PB_DIR_UP:   format(dest, size, "PB_DIR_UP");
		case PB_DIR_DOWN: format(dest, size, "PB_DIR_DOWN");
		default:          format(dest, size, "PB_DIR_RIGHT");
	}
}

static stock Float:PBE_SnapValue(Float:val, snapMode)
{
	if (snapMode == 1) return float(floatround(val, floatround_round));
	if (snapMode == 2) return float(floatround(val / 5.0, floatround_round)) * 5.0;
	return val;
}

static stock bool:PBE_CheckAccess(playerid)
{
	if (!IsPlayerConnected(playerid)) return false;
	if (g_PBERconLocked && !IsPlayerAdmin(playerid))
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Access Denied: ", "This editor is currently restricted to RCON administrators.");
		return false;
	}
	return true;
}

static stock bool:PBE_HasActiveBar(sid)
{
	if (!(0 <= sid < PBE_MAX_SESSIONS) || !EditorSession[sid][EP_Active]) return false;
	new sel = EditorSession[sid][EP_Selected];
	return (0 <= sel < EditorSession[sid][EP_BarCount]) && EditorBars[sid][sel][EBar_Used];
}

/*
================================================================================
    4. Editor Toolbar, Alignment Grid & Live Telemetry HUD Engine
================================================================================
*/

static stock PBE_SetCursor(playerid, sid, bool:enable)
{
	if (!(0 <= sid < PBE_MAX_SESSIONS)) return;
	if (enable)
	{
		EditorSession[sid][EP_CursorOn] = true;
		SelectTextDraw(playerid, PBE_UI_HOVER);
	}
	else if (EditorSession[sid][EP_CursorOn])
	{
		EditorSession[sid][EP_CursorOn] = false;
		EditorSession[sid][EP_SuppressCancel] = true;
		CancelSelectTextDraw(playerid);
	}
}

static stock PBE_ShowDialog(playerid, dialogid, style, const caption[], const info[], const btn1[], const btn2[])
{
	new sid = PBE_GetSlot(playerid);
	if (sid != PBE_INVALID_SESSION && EditorSession[sid][EP_CursorOn])
	{
		PBE_SetCursor(playerid, sid, false);
	}
	new cBuf[192], b1Buf[64], b2Buf[64];
	format(cBuf, sizeof cBuf, "%s", caption);
	format(b1Buf, sizeof b1Buf, "%s", btn1);
	format(b2Buf, sizeof b2Buf, "%s", btn2);
	static s_InfoOut[4096];
	format(s_InfoOut, sizeof s_InfoOut, "%s", info);
	ShowPlayerDialog(playerid, dialogid, PBE_DLG_STYLE style, cBuf, s_InfoOut, b1Buf, b2Buf);
}

static stock Text:PBE_MakeGlobalSprite(Float:x, Float:y, Float:w, Float:h, color, bool:selectable)
{
	new spr[16];
	format(spr, sizeof spr, "LD_SPAC:white");
	new Text:td = TextDrawCreate(x, y, spr);
	if (td == PBE_NO_TD) return PBE_NO_TD;
	TextDrawFont(td, PBE_FONT_SPRITE);
	TextDrawTextSize(td, w, h);
	PBE_TDColor(td, color);
	TextDrawSetShadow(td, 0);
	TextDrawSetOutline(td, 0);
	TextDrawSetSelectable(td, PBE_TD_BOOL(selectable));
	return td;
}

static stock Text:PBE_MakeGlobalLabel(Float:x, Float:y, const text[], Float:lx, Float:ly, color)
{
	new buf[96];
	format(buf, sizeof buf, "%s", text);
	new Text:td = TextDrawCreate(x, y, buf);
	if (td == PBE_NO_TD) return PBE_NO_TD;
	TextDrawFont(td, PBE_FONT_2);
	TextDrawLetterSize(td, lx, ly);
	TextDrawAlignment(td, PBE_ALIGN_CENTER);
	PBE_TDColor(td, color);
	PBE_TDBgColor(td, 0x000000AA);
	TextDrawSetOutline(td, 1);
	TextDrawSetShadow(td, 0);
	TextDrawSetProportional(td, PBE_TD_BOOL(true));
	TextDrawSetSelectable(td, PBE_TD_BOOL(false));
	return td;
}

static stock Text:PBE_MakeSessionLabel(Float:x, Float:y, const text[], Float:lx, Float:ly)
{
	new buf[256];
	format(buf, sizeof buf, "%s", text);
	new Text:td = TextDrawCreate(x, y, buf);
	if (td == PBE_NO_TD) return PBE_NO_TD;
	TextDrawFont(td, PBE_FONT_1);
	TextDrawLetterSize(td, lx, ly);
	TextDrawTextSize(td, 0.0, 630.0);
	TextDrawAlignment(td, PBE_ALIGN_CENTER);
	PBE_TDColor(td, 0xF8FAFCFF);
	PBE_TDBgColor(td, 0x000000CC);
	TextDrawSetOutline(td, 1);
	TextDrawSetShadow(td, 0);
	TextDrawSetProportional(td, PBE_TD_BOOL(true));
	TextDrawSetSelectable(td, PBE_TD_BOOL(false));
	return td;
}

static stock PBE_KillGlobalTD(&Text:td)
{
	if (td != PBE_NO_TD)
	{
		TextDrawDestroy(td);
		td = PBE_NO_TD;
	}
}

static stock PBE_InitGlobalEditorUI()
{
	for (new d = 0; d < 2; d++)
	{
		new Float:baseY = (d == 0) ? 409.0 : 4.0;
		new Float:trimY = (d == 0) ? 409.0 : 37.5;
		new Float:btnY  = (d == 0) ? 424.5 : 18.5;

		g_TD_DockBg[d]   = PBE_MakeGlobalSprite(36.0, baseY, 568.0, 35.0, 0x0F172AEB, false);
		g_TD_DockTrim[d] = PBE_MakeGlobalSprite(36.0, trimY, 568.0, 1.5, 0x38BDF8FF, false);

		for (new b = 0; b < PBE_DOCK_BUTTONS; b++)
		{
			new Float:bx = 40.0 + float(b) * 51.1;
			new btnCol = 0x1E293BFF;
			if (b == 1) btnCol = 0x1D4ED8FF;
			else if (b == 9) btnCol = 0x047857FF;
			else if (b == 10) btnCol = 0x334155FF;

			g_TD_DockBtn[d][b] = PBE_MakeGlobalSprite(bx, btnY, 49.0, 16.0, btnCol, true);
			g_TD_DockLbl[d][b] = PBE_MakeGlobalLabel(bx + 24.5, btnY + 3.6, g_PBEDockLabels[b], 0.155, 0.84, 0xF8FAFCFF);
		}
	}

	g_TD_MiniPillBg  = PBE_MakeGlobalSprite(292.0, 3.0, 56.0, 13.0, 0x0F172AE0, true);
	g_TD_MiniPillLbl = PBE_MakeGlobalLabel(320.0, 5.2, "EDITOR UI", 0.145, 0.78, 0x38BDF8FF);

	g_TD_GridLines[0] = PBE_MakeGlobalSprite(319.75, 0.0, 0.5, 448.0, 0x38BDF877, false);
	g_TD_GridLines[1] = PBE_MakeGlobalSprite(0.0, 223.75, 640.0, 0.5, 0x38BDF877, false);
	g_TD_GridLines[2] = PBE_MakeGlobalSprite(213.30, 0.0, 0.4, 448.0, 0xF59E0B3A, false);
	g_TD_GridLines[3] = PBE_MakeGlobalSprite(426.60, 0.0, 0.4, 448.0, 0xF59E0B3A, false);
	g_TD_GridLines[4] = PBE_MakeGlobalSprite(0.0, 149.30, 640.0, 0.4, 0xF59E0B3A, false);
	g_TD_GridLines[5] = PBE_MakeGlobalSprite(0.0, 298.60, 640.0, 0.4, 0xF59E0B3A, false);
}

static stock PBE_DestroyGlobalEditorUI()
{
	for (new d = 0; d < 2; d++)
	{
		PBE_KillGlobalTD(g_TD_DockBg[d]);
		PBE_KillGlobalTD(g_TD_DockTrim[d]);
		for (new b = 0; b < PBE_DOCK_BUTTONS; b++)
		{
			PBE_KillGlobalTD(g_TD_DockBtn[d][b]);
			PBE_KillGlobalTD(g_TD_DockLbl[d][b]);
		}
	}
	PBE_KillGlobalTD(g_TD_MiniPillBg);
	PBE_KillGlobalTD(g_TD_MiniPillLbl);
	for (new g = 0; g < 6; g++) PBE_KillGlobalTD(g_TD_GridLines[g]);
}

static stock PBE_UpdateGridVisibility(playerid, sid)
{
	for (new g = 0; g < 6; g++)
	{
		if (g_TD_GridLines[g] == PBE_NO_TD) continue;
		if (EditorSession[sid][EP_Active] && EditorSession[sid][EP_ShowGrid])
		{
			TextDrawShowForPlayer(playerid, g_TD_GridLines[g]);
		}
		else
		{
			TextDrawHideForPlayer(playerid, g_TD_GridLines[g]);
		}
	}
}

static stock PBE_CreateSessionTDs(playerid, sid)
{
	#pragma unused playerid
	PBE_KillGlobalTD(EditorSession[sid][EP_TDStatus]);
	PBE_KillGlobalTD(EditorSession[sid][EP_TDHelper]);

	new dock = EditorSession[sid][EP_DockPos];
	new Float:statusY = (dock == PBE_DOCK_TOP) ? 6.2 : 412.2;
	new Float:helperY = (dock == PBE_DOCK_TOP) ? 43.0 : 393.5;

	EditorSession[sid][EP_TDStatus] = PBE_MakeSessionLabel(320.0, statusY, "Progress Bar Plus - Editor", 0.175, 0.86);
	EditorSession[sid][EP_TDHelper] = PBE_MakeSessionLabel(320.0, helperY, "_", 0.175, 0.88);
}

static stock PBE_HideAllDockTDs(playerid, sid)
{
	for (new d = 0; d < 2; d++)
	{
		if (g_TD_DockBg[d] != PBE_NO_TD) TextDrawHideForPlayer(playerid, g_TD_DockBg[d]);
		if (g_TD_DockTrim[d] != PBE_NO_TD) TextDrawHideForPlayer(playerid, g_TD_DockTrim[d]);
		for (new b = 0; b < PBE_DOCK_BUTTONS; b++)
		{
			if (g_TD_DockBtn[d][b] != PBE_NO_TD) TextDrawHideForPlayer(playerid, g_TD_DockBtn[d][b]);
			if (g_TD_DockLbl[d][b] != PBE_NO_TD) TextDrawHideForPlayer(playerid, g_TD_DockLbl[d][b]);
		}
	}
	if (g_TD_MiniPillBg != PBE_NO_TD) TextDrawHideForPlayer(playerid, g_TD_MiniPillBg);
	if (g_TD_MiniPillLbl != PBE_NO_TD) TextDrawHideForPlayer(playerid, g_TD_MiniPillLbl);
	if (EditorSession[sid][EP_TDStatus] != PBE_NO_TD) TextDrawHideForPlayer(playerid, EditorSession[sid][EP_TDStatus]);
	if (EditorSession[sid][EP_TDHelper] != PBE_NO_TD) TextDrawHideForPlayer(playerid, EditorSession[sid][EP_TDHelper]);
}

static stock PBE_RefreshStatusHUD(playerid, sid)
{
	if (!EditorSession[sid][EP_Active]) return;

	new dock = EditorSession[sid][EP_DockPos];
	if (dock == PBE_DOCK_HIDDEN)
	{
		if (EditorSession[sid][EP_TDStatus] != PBE_NO_TD) TextDrawHideForPlayer(playerid, EditorSession[sid][EP_TDStatus]);
	}
	else if (EditorSession[sid][EP_TDStatus] != PBE_NO_TD)
	{
		new stateTag[24];
		if (EditorSession[sid][EP_Dirty])
		{
			format(stateTag, sizeof stateTag, "~y~[Unsaved]~w~");
		}
		else
		{
			format(stateTag, sizeof stateTag, "~g~~h~[Saved]~w~");
		}

		new usedTDs = PB_GetUsedPlayerTextDraws(playerid);
		new line[256];
		if (PBE_HasActiveBar(sid))
		{
			new s = EditorSession[sid][EP_Selected];
			new stName[12];
			PBE_GetStyleShort(EditorBars[sid][s][EBar_Style], stName);
			format(line, sizeof line,
				"%s ~b~~h~%s ~w~(%d/%d - ~p~%d/256 TD~w~)   ~y~#%d %s ~w~(%s)   Pos: ~g~~h~%.1f, %.1f~w~   Size: ~g~~h~%.1f x %.1f~w~   Val: ~b~~h~%.0f/%.0f",
				stateTag,
				EditorSession[sid][EP_ProjectName],
				EditorSession[sid][EP_BarCount],
				PBE_MAX_BARS,
				usedTDs,
				s + 1,
				EditorBars[sid][s][EBar_Name],
				stName,
				EditorBars[sid][s][EBar_X],
				EditorBars[sid][s][EBar_Y],
				EditorBars[sid][s][EBar_W],
				EditorBars[sid][s][EBar_H],
				EditorBars[sid][s][EBar_Val],
				EditorBars[sid][s][EBar_Max]
			);
		}
		else
		{
			format(line, sizeof line,
				"%s ~b~~h~%s ~w~(0/%d Bars - ~p~%d/256 TD~w~) - ~y~Click ~w~+ CREATE ~y~to add a bar or ~w~PROJECT ~y~to open/import",
				stateTag,
				EditorSession[sid][EP_ProjectName],
				PBE_MAX_BARS,
				usedTDs
			);
		}
		TextDrawSetString(EditorSession[sid][EP_TDStatus], line);
		TextDrawShowForPlayer(playerid, EditorSession[sid][EP_TDStatus]);
	}

	new mode = EditorSession[sid][EP_EditMode];
	if (mode == PBE_MODE_NONE || !PBE_HasActiveBar(sid))
	{
		if (EditorSession[sid][EP_TDHelper] != PBE_NO_TD) TextDrawHideForPlayer(playerid, EditorSession[sid][EP_TDHelper]);
		return;
	}

	if (EditorSession[sid][EP_TDHelper] != PBE_NO_TD)
	{
		new helper[256], s = EditorSession[sid][EP_Selected];
		new lockTag[8];
		if (EditorSession[sid][EP_AspectLock]) format(lockTag, sizeof lockTag, "ON");
		else format(lockTag, sizeof lockTag, "OFF");

		if (mode == PBE_MODE_MOVE)
		{
			new snapStr[10];
			switch (EditorSession[sid][EP_GridSnapMode])
			{
				case 1:  format(snapStr, sizeof snapStr, "1.0px");
				case 2:  format(snapStr, sizeof snapStr, "5.0px");
				default: format(snapStr, sizeof snapStr, "OFF");
			}
			format(helper, sizeof helper,
				"~y~MOVE~w~ X:~g~~h~%.1f~w~ Y:~g~~h~%.1f~w~ - ~y~(WASD)~w~Move - ~y~(SHIFT/CTRL)~w~Fast - ~y~(ALT)~w~Fine - ~y~(C)~w~Snap:~b~~h~%s~w~ - ~g~~h~(F)~w~Save - ~r~~h~(N)~w~Cancel",
				EditorBars[sid][s][EBar_X],
				EditorBars[sid][s][EBar_Y],
				snapStr
			);
		}
		else if (mode == PBE_MODE_RESIZE)
		{
			if (EditorBars[sid][s][EBar_Style] != PB_STYLE_BAR)
			{
				format(helper, sizeof helper,
					"~y~RESIZE~w~ W:~g~~h~%.1f~w~ H:~g~~h~%.1f~w~ - ~y~(WASD)~w~Size - ~y~(SHIFT/CTRL)~w~Fast - ~y~(ALT)~w~Fine - ~y~(C)~w~16:9:~b~~h~%s~w~ - ~g~~h~(F)~w~Save - ~r~~h~(N)~w~Cancel",
					EditorBars[sid][s][EBar_W],
					EditorBars[sid][s][EBar_H],
					lockTag
				);
			}
			else
			{
				format(helper, sizeof helper,
					"~y~RESIZE~w~ W:~g~~h~%.1f~w~ H:~g~~h~%.1f~w~ - ~y~(WASD)~w~Size - ~y~(SHIFT/CTRL)~w~Fast - ~y~(ALT)~w~Fine - ~g~~h~(F)~w~Save - ~r~~h~(N)~w~Cancel",
					EditorBars[sid][s][EBar_W],
					EditorBars[sid][s][EBar_H]
				);
			}
		}
		else if (mode == PBE_MODE_BORDER)
		{
			format(helper, sizeof helper,
				"~y~BORDER~w~ ~g~~h~%.2fpx~w~ (0.5-5.0) - ~y~(WASD)~w~Size - ~y~(SHIFT/CTRL)~w~Fast - ~y~(ALT)~w~Fine - ~g~~h~(F)~w~Save - ~r~~h~(N)~w~Cancel",
				EditorBars[sid][s][EBar_Border]
			);
		}
		else if (mode == PBE_MODE_SCRUB)
		{
			format(helper, sizeof helper,
				"~y~VALUE~w~ ~g~~h~%.1f/%.1f~w~ - ~y~(WASD)~w~Value - ~y~(SHIFT/CTRL)~w~Fast - ~y~(ALT)~w~Fine - ~g~~h~(F)~w~Save - ~r~~h~(N)~w~Cancel",
				EditorBars[sid][s][EBar_Val],
				EditorBars[sid][s][EBar_Max]
			);
		}
		TextDrawSetString(EditorSession[sid][EP_TDHelper], helper);
		TextDrawShowForPlayer(playerid, EditorSession[sid][EP_TDHelper]);
	}
}

static stock PBE_RenderEditorDock(playerid, sid)
{
	PBE_HideAllDockTDs(playerid, sid);
	if (!EditorSession[sid][EP_Active]) return;

	PBE_CreateSessionTDs(playerid, sid);
	new dock = EditorSession[sid][EP_DockPos];
	if (dock == PBE_DOCK_HIDDEN)
	{
		if (g_TD_MiniPillBg != PBE_NO_TD) TextDrawShowForPlayer(playerid, g_TD_MiniPillBg);
		if (g_TD_MiniPillLbl != PBE_NO_TD) TextDrawShowForPlayer(playerid, g_TD_MiniPillLbl);
	}
	else
	{
		new d = (dock == PBE_DOCK_TOP) ? 1 : 0;
		if (g_TD_DockBg[d] != PBE_NO_TD) TextDrawShowForPlayer(playerid, g_TD_DockBg[d]);
		if (g_TD_DockTrim[d] != PBE_NO_TD) TextDrawShowForPlayer(playerid, g_TD_DockTrim[d]);
		for (new b = 0; b < PBE_DOCK_BUTTONS; b++)
		{
			if (g_TD_DockBtn[d][b] != PBE_NO_TD) TextDrawShowForPlayer(playerid, g_TD_DockBtn[d][b]);
			if (g_TD_DockLbl[d][b] != PBE_NO_TD) TextDrawShowForPlayer(playerid, g_TD_DockLbl[d][b]);
		}
	}
	PBE_UpdateGridVisibility(playerid, sid);
	PBE_RefreshStatusHUD(playerid, sid);
}

/*
================================================================================
    5. Bar Instance Lifecycle, Z-Order Layer Engine & Snapshot Undo
================================================================================
*/

static stock PBE_DestroySlotHandle(playerid, sid, slot)
{
	new handle = EditorBars[sid][slot][EBar_Handle];
	if (handle != INVALID_PLAYER_BAR_ID && IsValidPlayerProgressBar(playerid, handle))
	{
		DestroyPlayerProgressBar(playerid, handle);
	}
	EditorBars[sid][slot][EBar_Handle] = INVALID_PLAYER_BAR_ID;
}

static stock PBE_DestroyAllSlotHandles(playerid, sid)
{
	for (new i = 0; i < PBE_MAX_BARS; i++)
	{
		PBE_DestroySlotHandle(playerid, sid, i);
	}
}

static stock bool:PBE_SpawnSlotHandle(playerid, sid, slot)
{
	if (!EditorBars[sid][slot][EBar_Used]) return false;
	PBE_DestroySlotHandle(playerid, sid, slot);

	new handle = CreatePlayerProgressBar(
		playerid,
		EditorBars[sid][slot][EBar_X],
		EditorBars[sid][slot][EBar_Y],
		EditorBars[sid][slot][EBar_W],
		EditorBars[sid][slot][EBar_H],
		EditorBars[sid][slot][EBar_Color],
		EditorBars[sid][slot][EBar_Max],
		EditorBars[sid][slot][EBar_Dir],
		EditorBars[sid][slot][EBar_Border],
		EditorBars[sid][slot][EBar_BorderColor],
		EditorBars[sid][slot][EBar_Style],
		EditorBars[sid][slot][EBar_Segments],
		EditorBars[sid][slot][EBar_SegScale]
	);

	if (handle == INVALID_PLAYER_BAR_ID)
	{
		EditorBars[sid][slot][EBar_Handle] = INVALID_PLAYER_BAR_ID;
		return false;
	}

	EditorBars[sid][slot][EBar_Handle] = handle;
	if (EditorBars[sid][slot][EBar_Min] != 0.0)
	{
		SetPlayerProgressBarMinValue(playerid, handle, EditorBars[sid][slot][EBar_Min]);
	}
	SetPlayerProgressBarValue(playerid, handle, EditorBars[sid][slot][EBar_Val]);
	if (EditorBars[sid][slot][EBar_Gradient])
	{
		SetPlayerProgressBarGradient(playerid, handle, true, EditorBars[sid][slot][EBar_GradEmpty], EditorBars[sid][slot][EBar_GradFull], EditorBars[sid][slot][EBar_GradMid], EditorBars[sid][slot][EBar_GradInvert]);
	}
	if (EditorBars[sid][slot][EBar_LabelShow])
	{
		SetPlayerProgressBarLabel(
			playerid,
			handle,
			true,
			EditorBars[sid][slot][EBar_LabelText],
			EditorBars[sid][slot][EBar_LabelColor],
			EditorBars[sid][slot][EBar_LabelAlign],
			EditorBars[sid][slot][EBar_LabelFont],
			EditorBars[sid][slot][EBar_LabelScaleX],
			EditorBars[sid][slot][EBar_LabelScaleY],
			EditorBars[sid][slot][EBar_LabelOffsetX],
			EditorBars[sid][slot][EBar_LabelOffsetY]
		);
		SetPlayerProgressBarLabelAutoScale(playerid, handle, EditorBars[sid][slot][EBar_LabelAutoScale]);
		SetPlayerProgressBarLabelFollowColour(playerid, handle, EditorBars[sid][slot][EBar_LabelFollowCol]);
		SetPlayerProgressBarLabelOrientation(playerid, handle, EditorBars[sid][slot][EBar_LabelOrient]);
	}

	if (EditorBars[sid][slot][EBar_Visible]) ShowPlayerProgressBar(playerid, handle);
	else HidePlayerProgressBar(playerid, handle);

	if (EditorBars[sid][slot][EBar_AutoFill])
	{
		AutoFillPlayerProgressBar(playerid, handle, EditorBars[sid][slot][EBar_AutoFillMax]);
	}

	if (EditorBars[sid][slot][EBar_Blinking])
	{
		BlinkPlayerProgressBar(
			playerid,
			handle,
			EditorBars[sid][slot][EBar_BlinkInterval],
			EditorBars[sid][slot][EBar_BlinkDuration],
			EditorBars[sid][slot][EBar_BlinkColor],
			EditorBars[sid][slot][EBar_BlinkBorderColor]
		);
	}
	return true;
}

static stock PBE_RebuildWorkspace(playerid, sid)
{
	PBE_DestroyAllSlotHandles(playerid, sid);
	new count = EditorSession[sid][EP_BarCount];
	for (new i = 0; i < count; i++)
	{
		if (EditorBars[sid][i][EBar_Used])
		{
			PBE_SpawnSlotHandle(playerid, sid, i);
		}
	}
	if (EditorSession[sid][EP_Active])
	{
		PBE_RenderEditorDock(playerid, sid);
	}
}

static stock PBE_SaveUndo(sid, const desc[])
{
	EditorUndoMeta[sid][EUndo_Available] = true;
	EditorUndoMeta[sid][EUndo_Selected]  = EditorSession[sid][EP_Selected];
	EditorUndoMeta[sid][EUndo_BarCount]  = EditorSession[sid][EP_BarCount];
	format(EditorUndoMeta[sid][EUndo_Desc], 48, "%s", desc);

	for (new i = 0; i < PBE_MAX_BARS; i++)
	{
		EditorUndoBars[sid][i] = EditorBars[sid][i];
		EditorUndoBars[sid][i][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	}
}

static stock bool:PBE_PerformUndo(playerid, sid)
{
	if (!EditorUndoMeta[sid][EUndo_Available])
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Undo: ", "No previous action is available to undo.");
		return false;
	}

	PBE_DestroyAllSlotHandles(playerid, sid);
	EditorSession[sid][EP_BarCount] = EditorUndoMeta[sid][EUndo_BarCount];
	EditorSession[sid][EP_Selected] = EditorUndoMeta[sid][EUndo_Selected];

	for (new i = 0; i < PBE_MAX_BARS; i++)
	{
		EditorBars[sid][i] = EditorUndoBars[sid][i];
		EditorBars[sid][i][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	}

	EditorUndoMeta[sid][EUndo_Available] = false;
	EditorSession[sid][EP_Dirty] = true;
	PBE_RebuildWorkspace(playerid, sid);

	new msg[256];
	format(msg, sizeof msg, "Reverted last action: {38BDF8}%s{FFFFFF}.", EditorUndoMeta[sid][EUndo_Desc]);
	PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Undo Restored: ", msg);
	return true;
}

static stock PBE_ClearWorkspace(playerid, sid, const newProjName[] = "Untitled_HUD")
{
	PBE_DestroyAllSlotHandles(playerid, sid);
	for (new i = 0; i < PBE_MAX_BARS; i++)
	{
		EditorBars[sid][i][EBar_Used] = false;
		EditorBars[sid][i][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	}
	EditorSession[sid][EP_BarCount] = 0;
	EditorSession[sid][EP_Selected] = -1;
	EditorSession[sid][EP_Dirty] = true;
	EditorUndoMeta[sid][EUndo_Available] = false;
	format(EditorSession[sid][EP_ProjectName], PBE_MAX_PROJECT_NAME, "%s", newProjName);
	PBE_RefreshStatusHUD(playerid, sid);
}

static stock PBE_GenerateUniqueBarName(sid, const basePrefix[], dest[], maxLen = sizeof dest)
{
	new cleanBase[24];
	PBE_SanitizeVarName(basePrefix, cleanBase, sizeof cleanBase);
	for (new n = 1; n <= 99; n++)
	{
		if (n == 1) format(dest, maxLen, "%s", cleanBase);
		else format(dest, maxLen, "%s_%d", cleanBase, n);

		new bool:exists = false;
		for (new i = 0; i < EditorSession[sid][EP_BarCount]; i++)
		{
			if (EditorBars[sid][i][EBar_Used] && !strcmp(EditorBars[sid][i][EBar_Name], dest, true))
			{
				exists = true;
				break;
			}
		}
		if (!exists) return;
	}
	format(dest, maxLen, "ProgressBar_%d", EditorSession[sid][EP_BarCount] + 1);
}

static stock PBE_AddNewBar(playerid, sid, style = PB_STYLE_BAR)
{
	new count = EditorSession[sid][EP_BarCount];
	if (count >= PBE_MAX_BARS)
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Limit Reached: ", "A single workspace project can hold up to 20 bar layers.");
		return -1;
	}

	new neededTDs = PB_GetBarRequiredTextDraws(style, PB_RING_SEGMENTS, false);
	new freeTDs = PB_GetFreePlayerTextDraws(playerid);
	if (freeTDs < neededTDs + PB_TD_SAFETY_HEADROOM)
	{
		new err[128];
		format(err, sizeof err, "PlayerTextDraw limit reached (256 max). Needed: %d, Available: %d.", neededTDs, freeTDs);
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Allocation Failed: ", err);
		return -1;
	}

	PBE_SaveUndo(sid, "Create Bar Layer");

	new slot = count;
	new baseName[24];
	if (style == PB_STYLE_RING) format(baseName, sizeof baseName, "RadialRing");
	else if (style == PB_STYLE_CIRCLE) format(baseName, sizeof baseName, "CircleGauge");
	else format(baseName, sizeof baseName, "ProgressBar");

	EditorBars[sid][slot][EBar_Used]             = true;
	EditorBars[sid][slot][EBar_Handle]           = INVALID_PLAYER_BAR_ID;
	PBE_GenerateUniqueBarName(sid, baseName, EditorBars[sid][slot][EBar_Name], PBE_MAX_NAME);
	EditorBars[sid][slot][EBar_Style]            = style;

	if (style == PB_STYLE_RING)
	{
		EditorBars[sid][slot][EBar_W]            = 56.0;
		EditorBars[sid][slot][EBar_H]            = 70.0;
		EditorBars[sid][slot][EBar_X]            = 292.0 + float(slot % 5) * 6.0;
		EditorBars[sid][slot][EBar_Y]            = 189.0 + float(slot % 5) * 6.0;
		EditorBars[sid][slot][EBar_Color]        = 0xF59E0BFF;
		EditorBars[sid][slot][EBar_Border]       = 0.8;
	}
	else if (style == PB_STYLE_CIRCLE)
	{
		EditorBars[sid][slot][EBar_W]            = 40.0;
		EditorBars[sid][slot][EBar_H]            = 50.0;
		EditorBars[sid][slot][EBar_X]            = 300.0 + float(slot % 5) * 6.0;
		EditorBars[sid][slot][EBar_Y]            = 199.0 + float(slot % 5) * 6.0;
		EditorBars[sid][slot][EBar_Color]        = 0x38BDF8FF;
		EditorBars[sid][slot][EBar_Border]       = 1.0;
	}
	else
	{
		EditorBars[sid][slot][EBar_W]            = 80.0;
		EditorBars[sid][slot][EBar_H]            = 9.0;
		EditorBars[sid][slot][EBar_X]            = 280.0;
		EditorBars[sid][slot][EBar_Y]            = 210.0 + float(slot % 6) * 14.0;
		EditorBars[sid][slot][EBar_Color]        = PB_DEFAULT_COLOUR;
		EditorBars[sid][slot][EBar_Border]       = PB_BORDER_DEFAULT;
	}

	EditorBars[sid][slot][EBar_Min]              = 0.0;
	EditorBars[sid][slot][EBar_Max]              = 100.0;
	EditorBars[sid][slot][EBar_Val]              = 70.0;
	EditorBars[sid][slot][EBar_Dir]              = PB_DIR_RIGHT;
	EditorBars[sid][slot][EBar_BorderColor]      = 0x0F172AE6;
	EditorBars[sid][slot][EBar_Segments]         = PB_RING_SEGMENTS;
	EditorBars[sid][slot][EBar_SegScale]         = PB_RING_SEGMENT_SCALE;
	EditorBars[sid][slot][EBar_Visible]          = true;
	EditorBars[sid][slot][EBar_AutoFill]         = false;
	EditorBars[sid][slot][EBar_AutoFillMax]      = -1.0;
	EditorBars[sid][slot][EBar_Blinking]         = false;
	EditorBars[sid][slot][EBar_BlinkInterval]    = PB_BLINK_DEFAULT;
	EditorBars[sid][slot][EBar_BlinkDuration]    = 0;
	EditorBars[sid][slot][EBar_BlinkColor]       = 0;
	EditorBars[sid][slot][EBar_BlinkBorderColor] = 0;
	EditorBars[sid][slot][EBar_LabelShow]        = false;
	EditorBars[sid][slot][EBar_LabelAutoScale]   = true;
	EditorBars[sid][slot][EBar_LabelFollowCol]   = false;
	EditorBars[sid][slot][EBar_LabelOrient]      = PB_LABEL_ORIENT_AUTO;
	format(EditorBars[sid][slot][EBar_LabelText], 32, "{PERCENT}%%");
	EditorBars[sid][slot][EBar_LabelColor]       = 0xFFFFFFFF;
	EditorBars[sid][slot][EBar_LabelFont]        = 1;
	EditorBars[sid][slot][EBar_LabelAlign]       = 2;
	EditorBars[sid][slot][EBar_LabelScaleX]      = 0.0;
	EditorBars[sid][slot][EBar_LabelScaleY]      = 0.0;
	EditorBars[sid][slot][EBar_LabelOffsetX]     = 0.0;
	EditorBars[sid][slot][EBar_LabelOffsetY]     = 0.0;
	EditorBars[sid][slot][EBar_Gradient]         = false;
	EditorBars[sid][slot][EBar_GradInvert]       = false;
	EditorBars[sid][slot][EBar_GradEmpty]        = 0xE74C3CFF;
	EditorBars[sid][slot][EBar_GradMid]          = 0xF1C40FFF;
	EditorBars[sid][slot][EBar_GradFull]         = 0x2ECC71FF;

	EditorSession[sid][EP_BarCount]++;
	EditorSession[sid][EP_Selected] = slot;
	EditorSession[sid][EP_Dirty] = true;

	if (!PBE_SpawnSlotHandle(playerid, sid, slot))
	{
		EditorBars[sid][slot][EBar_Used] = false;
		EditorSession[sid][EP_BarCount]--;
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Allocation Failed: ", "PlayerTextDraw limit reached! Reduce ring segments or bar count.");
		return -1;
	}

	PBE_RenderEditorDock(playerid, sid);
	return slot;
}

static stock PBE_DuplicateBarLayer(playerid, sid, srcSlot)
{
	new count = EditorSession[sid][EP_BarCount];
	if (!(0 <= srcSlot < count) || !EditorBars[sid][srcSlot][EBar_Used]) return -1;
	if (count >= PBE_MAX_BARS)
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Limit Reached: ", "Cannot duplicate; maximum 20 bar layers reached.");
		return -1;
	}

	new neededTDs = PB_GetBarRequiredTextDraws(EditorBars[sid][srcSlot][EBar_Style], EditorBars[sid][srcSlot][EBar_Segments], EditorBars[sid][srcSlot][EBar_LabelShow]);
	new freeTDs = PB_GetFreePlayerTextDraws(playerid);
	if (freeTDs < neededTDs + PB_TD_SAFETY_HEADROOM)
	{
		new err[128];
		format(err, sizeof err, "PlayerTextDraw limit reached (256 max). Needed: %d, Available: %d.", neededTDs, freeTDs);
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Allocation Failed: ", err);
		return -1;
	}

	PBE_SaveUndo(sid, "Duplicate Layer");

	new dst = count;
	EditorBars[sid][dst] = EditorBars[sid][srcSlot];
	EditorBars[sid][dst][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	EditorBars[sid][dst][EBar_X] += 8.0;
	EditorBars[sid][dst][EBar_Y] += 10.0;
	PBE_GenerateUniqueBarName(sid, EditorBars[sid][srcSlot][EBar_Name], EditorBars[sid][dst][EBar_Name], PBE_MAX_NAME);

	EditorSession[sid][EP_BarCount]++;
	EditorSession[sid][EP_Selected] = dst;
	EditorSession[sid][EP_Dirty] = true;

	if (!PBE_SpawnSlotHandle(playerid, sid, dst))
	{
		EditorBars[sid][dst][EBar_Used] = false;
		EditorSession[sid][EP_BarCount]--;
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Allocation Failed: ", "Not enough PlayerTextDraws available to clone this layer.");
		return -1;
	}

	PBE_RenderEditorDock(playerid, sid);
	return dst;
}

static stock PBE_DeleteBarLayer(playerid, sid, slot)
{
	new count = EditorSession[sid][EP_BarCount];
	if (!(0 <= slot < count)) return;

	PBE_SaveUndo(sid, "Delete Layer");
	PBE_DestroySlotHandle(playerid, sid, slot);

	for (new i = slot; i < count - 1; i++)
	{
		EditorBars[sid][i] = EditorBars[sid][i + 1];
	}
	EditorBars[sid][count - 1][EBar_Used] = false;
	EditorBars[sid][count - 1][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	EditorSession[sid][EP_BarCount]--;

	if (EditorSession[sid][EP_BarCount] <= 0)
	{
		EditorSession[sid][EP_Selected] = -1;
	}
	else if (EditorSession[sid][EP_Selected] >= EditorSession[sid][EP_BarCount])
	{
		EditorSession[sid][EP_Selected] = EditorSession[sid][EP_BarCount] - 1;
	}

	EditorSession[sid][EP_Dirty] = true;
	PBE_RefreshStatusHUD(playerid, sid);
}

static stock bool:PBE_MoveBarLayerZOrder(playerid, sid, slot, newSlot)
{
	new count = EditorSession[sid][EP_BarCount];
	if (!(0 <= slot < count) || !(0 <= newSlot < count) || slot == newSlot) return false;

	PBE_SaveUndo(sid, "Reorder Z-Layer");

	new temp[E_PBE_BAR];
	temp = EditorBars[sid][slot];
	if (newSlot < slot)
	{
		for (new i = slot; i > newSlot; i--)
		{
			EditorBars[sid][i] = EditorBars[sid][i - 1];
		}
	}
	else
	{
		for (new i = slot; i < newSlot; i++)
		{
			EditorBars[sid][i] = EditorBars[sid][i + 1];
		}
	}
	EditorBars[sid][newSlot] = temp;
	EditorSession[sid][EP_Selected] = newSlot;
	EditorSession[sid][EP_Dirty] = true;

	PBE_RebuildWorkspace(playerid, sid);
	return true;
}

/*
================================================================================
    6. Real-Time 35ms Interactive Transform Engine
================================================================================
*/

static stock PBE_KillTransformTimer(sid)
{
	if (EditorSession[sid][EP_Timer] != 0)
	{
		KillTimer(EditorSession[sid][EP_Timer]);
		EditorSession[sid][EP_Timer] = 0;
	}
}

static stock PBE_StartTransformMode(playerid, sid, mode)
{
	if (!PBE_HasActiveBar(sid))
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Active Layer: ", "Create or select a progress bar layer first.");
		PBE_SetCursor(playerid, sid, true);
		return;
	}

	PBE_KillTransformTimer(sid);
	PBE_SetCursor(playerid, sid, false);
	TogglePlayerControllable(playerid, PBE_TD_BOOL(false));

	new s = EditorSession[sid][EP_Selected];
	if (mode == PBE_MODE_MOVE) PBE_SaveUndo(sid, "Move Bar");
	else if (mode == PBE_MODE_RESIZE) PBE_SaveUndo(sid, "Resize Bar");
	else PBE_SaveUndo(sid, "Adjust Bar");

	EditorSession[sid][EP_OrigX]      = EditorBars[sid][s][EBar_X];
	EditorSession[sid][EP_OrigY]      = EditorBars[sid][s][EBar_Y];
	EditorSession[sid][EP_RawX]       = EditorBars[sid][s][EBar_X];
	EditorSession[sid][EP_RawY]       = EditorBars[sid][s][EBar_Y];
	EditorSession[sid][EP_OrigW]      = EditorBars[sid][s][EBar_W];
	EditorSession[sid][EP_OrigH]      = EditorBars[sid][s][EBar_H];
	EditorSession[sid][EP_OrigBorder] = EditorBars[sid][s][EBar_Border];
	EditorSession[sid][EP_OrigVal]    = EditorBars[sid][s][EBar_Val];
	EditorSession[sid][EP_LastRingRebuild]    = 0;
	EditorSession[sid][EP_RingPendingRebuild] = false;

	if (mode == PBE_MODE_RESIZE)
	{
		if (EditorBars[sid][s][EBar_Style] == PB_STYLE_BAR)
		{
			EditorSession[sid][EP_AspectLock] = false;
		}
		else
		{
			new Float:ratio = EditorBars[sid][s][EBar_H] / ((EditorBars[sid][s][EBar_W] > 0.1) ? EditorBars[sid][s][EBar_W] : 1.0);
			if (1.20 <= ratio <= 1.30) EditorSession[sid][EP_AspectLock] = true;
		}
	}

	EditorSession[sid][EP_EditMode] = mode;
	EditorSession[sid][EP_Timer]    = SetTimerEx("PBE_TransformTick", PBE_TICK_RATE, PBE_TD_BOOL(true), "i", playerid);

	PBE_RefreshStatusHUD(playerid, sid);
}

static stock PBE_StopTransformMode(playerid, sid, bool:revertChanges, bool:restoreCursor = true)
{
	new prevMode = EditorSession[sid][EP_EditMode];
	if (prevMode == PBE_MODE_NONE) return;

	PBE_KillTransformTimer(sid);
	EditorSession[sid][EP_EditMode] = PBE_MODE_NONE;
	TogglePlayerControllable(playerid, PBE_TD_BOOL(true));

	if (PBE_HasActiveBar(sid))
	{
		new s = EditorSession[sid][EP_Selected];
		new h = EditorBars[sid][s][EBar_Handle];
		if (revertChanges)
		{
			EditorBars[sid][s][EBar_X]      = EditorSession[sid][EP_OrigX];
			EditorBars[sid][s][EBar_Y]      = EditorSession[sid][EP_OrigY];
			EditorBars[sid][s][EBar_W]      = EditorSession[sid][EP_OrigW];
			EditorBars[sid][s][EBar_H]      = EditorSession[sid][EP_OrigH];
			EditorBars[sid][s][EBar_Border] = EditorSession[sid][EP_OrigBorder];
			EditorBars[sid][s][EBar_Val]    = EditorSession[sid][EP_OrigVal];

			if (IsValidPlayerProgressBar(playerid, h))
			{
				switch (prevMode)
				{
					case PBE_MODE_MOVE:   SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					case PBE_MODE_RESIZE: SetPlayerProgressBarSize(playerid, h, EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
					case PBE_MODE_BORDER: SetPlayerProgressBarBorder(playerid, h, EditorBars[sid][s][EBar_Border]);
					case PBE_MODE_SCRUB:  SetPlayerProgressBarValue(playerid, h, EditorBars[sid][s][EBar_Val]);
				}
			}
		}
		else
		{
			if (IsValidPlayerProgressBar(playerid, h) && EditorBars[sid][s][EBar_Style] == PB_STYLE_RING && EditorSession[sid][EP_RingPendingRebuild])
			{
				EditorSession[sid][EP_RingPendingRebuild] = false;
				switch (prevMode)
				{
					case PBE_MODE_MOVE:   SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					case PBE_MODE_RESIZE: SetPlayerProgressBarSize(playerid, h, EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
					case PBE_MODE_BORDER: SetPlayerProgressBarBorder(playerid, h, EditorBars[sid][s][EBar_Border]);
				}
			}
			EditorSession[sid][EP_Dirty] = true;
		}
	}

	PBE_RefreshStatusHUD(playerid, sid);
	if (restoreCursor && EditorSession[sid][EP_Active])
	{
		PBE_SetCursor(playerid, sid, true);
	}
}

public PBE_TransformTick(playerid)
{
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION) return 0;

	if (!IsPlayerConnected(playerid) || EditorSession[sid][EP_EditMode] == PBE_MODE_NONE)
	{
		PBE_KillTransformTimer(sid);
		return 0;
	}
	if (!PBE_HasActiveBar(sid))
	{
		PBE_StopTransformMode(playerid, sid, false, true);
		return 0;
	}

	new mode = EditorSession[sid][EP_EditMode];
	new s = EditorSession[sid][EP_Selected];
	new h = EditorBars[sid][s][EBar_Handle];
	if (!IsValidPlayerProgressBar(playerid, h)) return 1;

	new bool:isRing = (EditorBars[sid][s][EBar_Style] == PB_STYLE_RING);
	new now = GetTickCount();

	new PBE_KEY_TAG keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);

	// Speed modifiers: ALT (Walk) = 0.10 Fine | SHIFT or CTRL (Jump/Sprint/Fire/Action/Handbrake) = 2.50 Fast
	new Float:step = 0.50;
	if (_:keys & _:KEY_WALK)
	{
		step = 0.10;
	}
	else if (_:keys & (_:KEY_JUMP | _:KEY_SPRINT | _:KEY_FIRE | _:KEY_ACTION | _:KEY_HANDBRAKE))
	{
		step = 2.50;
	}

	new Float:dx = 0.0, Float:dy = 0.0;
	if (leftright < 0) dx -= step;
	else if (leftright > 0) dx += step;

	if (updown < 0) dy -= step;
	else if (updown > 0) dy += step;

	if (dx == 0.0 && dy == 0.0)
	{
		if (isRing && EditorSession[sid][EP_RingPendingRebuild])
		{
			EditorSession[sid][EP_RingPendingRebuild] = false;
			EditorSession[sid][EP_LastRingRebuild] = now;
			switch (mode)
			{
				case PBE_MODE_MOVE:   SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
				case PBE_MODE_RESIZE: SetPlayerProgressBarSize(playerid, h, EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
				case PBE_MODE_BORDER: SetPlayerProgressBarBorder(playerid, h, EditorBars[sid][s][EBar_Border]);
			}
		}
		return 1;
	}

	new bool:canRebuild = true;
	if (isRing && mode != PBE_MODE_SCRUB)
	{
		new throttleMs = 70;
		new segs = EditorBars[sid][s][EBar_Segments];
		if (segs >= 45) throttleMs = 200;
		else if (segs >= 30) throttleMs = 120;
		if (now - EditorSession[sid][EP_LastRingRebuild] < throttleMs)
		{
			canRebuild = false;
		}
	}

	if (mode == PBE_MODE_MOVE)
	{
		new Float:nx = EditorSession[sid][EP_RawX] + dx;
		new Float:ny = EditorSession[sid][EP_RawY] + dy;
		if (nx < -120.0) nx = -120.0;
		if (nx > 635.0) nx = 635.0;
		if (ny < -120.0) ny = -120.0;
		if (ny > 445.0) ny = 445.0;
		EditorSession[sid][EP_RawX] = nx;
		EditorSession[sid][EP_RawY] = ny;

		new Float:snappedX = PBE_SnapValue(nx, EditorSession[sid][EP_GridSnapMode]);
		new Float:snappedY = PBE_SnapValue(ny, EditorSession[sid][EP_GridSnapMode]);

		EditorBars[sid][s][EBar_X] = snappedX;
		EditorBars[sid][s][EBar_Y] = snappedY;

		if (canRebuild)
		{
			SetPlayerProgressBarPos(playerid, h, snappedX, snappedY);
			if (isRing) EditorSession[sid][EP_LastRingRebuild] = now;
			EditorSession[sid][EP_RingPendingRebuild] = false;
		}
		else
		{
			EditorSession[sid][EP_RingPendingRebuild] = true;
		}
	}
	else if (mode == PBE_MODE_RESIZE)
	{
		new Float:nw, Float:nh;
		if (EditorBars[sid][s][EBar_Style] != PB_STYLE_BAR && EditorSession[sid][EP_AspectLock])
		{
			new Float:delta = (dx != 0.0) ? dx : -dy;
			nw = EditorBars[sid][s][EBar_W] + delta;
			new Float:maxW = 448.0 / PB_BORDER_Y_RATIO;
			if (nw < 3.0) nw = 3.0;
			if (nw > maxW) nw = maxW;
			nh = nw * PB_BORDER_Y_RATIO;
		}
		else
		{
			nw = EditorBars[sid][s][EBar_W] + dx;
			nh = EditorBars[sid][s][EBar_H] + dy;
			if (nw < 3.0) nw = 3.0;
			if (nw > 640.0) nw = 640.0;
			if (nh < 3.0) nh = 3.0;
			if (nh > 448.0) nh = 448.0;
		}

		EditorBars[sid][s][EBar_W] = nw;
		EditorBars[sid][s][EBar_H] = nh;

		if (canRebuild)
		{
			SetPlayerProgressBarSize(playerid, h, nw, nh);
			if (isRing) EditorSession[sid][EP_LastRingRebuild] = now;
			EditorSession[sid][EP_RingPendingRebuild] = false;
		}
		else
		{
			EditorSession[sid][EP_RingPendingRebuild] = true;
		}
	}
	else if (mode == PBE_MODE_BORDER)
	{
		new Float:axis = (dx != 0.0) ? dx : -dy;
		new Float:nb = EditorBars[sid][s][EBar_Border] + (axis * 0.2);
		if (nb < PB_BORDER_MIN) nb = PB_BORDER_MIN;
		if (nb > PB_BORDER_MAX) nb = PB_BORDER_MAX;
		EditorBars[sid][s][EBar_Border] = nb;

		if (canRebuild)
		{
			SetPlayerProgressBarBorder(playerid, h, nb);
			if (isRing) EditorSession[sid][EP_LastRingRebuild] = now;
			EditorSession[sid][EP_RingPendingRebuild] = false;
		}
		else
		{
			EditorSession[sid][EP_RingPendingRebuild] = true;
		}
	}
	else if (mode == PBE_MODE_SCRUB)
	{
		new Float:axis = (dx != 0.0) ? dx : -dy;
		new Float:maxV = EditorBars[sid][s][EBar_Max];
		new Float:nv = EditorBars[sid][s][EBar_Val] + (axis * (maxV / 100.0) * 2.0);
		if (nv < 0.0) nv = 0.0;
		if (nv > maxV) nv = maxV;
		EditorBars[sid][s][EBar_Val] = nv;
		SetPlayerProgressBarValue(playerid, h, nv);
	}

	PBE_RefreshStatusHUD(playerid, sid);
	return 1;
}

static stock PBE_ReadIndexEntries(const indexPath[], const folder[], const ext[], outList[][PBE_MAX_PROJECT_NAME], maxItems = PBE_MAX_INDEX_ITEMS)
{
	if (!fexist(indexPath)) return 0;
	new File:fp = fopen(indexPath, io_read);
	if (!fp) return 0;

	new line[96], clean[PBE_MAX_PROJECT_NAME], checkPath[PBE_MAX_PATH], count = 0;
	while (fread(fp, line, sizeof line) && count < maxItems)
	{
		PBE_Trim(line, clean, sizeof clean);
		if (clean[0] == '\0' || clean[0] == ';' || clean[0] == '#') continue;

		format(checkPath, sizeof checkPath, "%s%s%s", folder, clean, ext);
		if (!fexist(checkPath)) continue;

		new bool:dup = false;
		for (new i = 0; i < count; i++)
		{
			if (!strcmp(outList[i], clean, true))
			{
				dup = true;
				break;
			}
		}
		if (!dup)
		{
			format(outList[count], PBE_MAX_PROJECT_NAME, "%s", clean);
			count++;
		}
	}
	fclose(fp);
	return count;
}

static stock PBE_RegisterIndexEntry(const indexPath[], const folder[], const ext[], const itemName[])
{
	static s_Entries[PBE_MAX_INDEX_ITEMS][PBE_MAX_PROJECT_NAME];
	new count = PBE_ReadIndexEntries(indexPath, folder, ext, s_Entries, PBE_MAX_INDEX_ITEMS);

	for (new i = 0; i < count; i++)
	{
		if (!strcmp(s_Entries[i], itemName, true)) return;
	}

	if (count < PBE_MAX_INDEX_ITEMS)
	{
		format(s_Entries[count], PBE_MAX_PROJECT_NAME, "%s", itemName);
		count++;
	}

	new File:fp = fopen(indexPath, io_write);
	if (!fp) return;
	new row[64];
	for (new i = 0; i < count; i++)
	{
		format(row, sizeof row, "%s\r\n", s_Entries[i]);
		fwrite(fp, row);
	}
	fclose(fp);
}

static stock PBE_RemoveIndexEntry(const indexPath[], const folder[], const ext[], const itemName[])
{
	static s_Entries[PBE_MAX_INDEX_ITEMS][PBE_MAX_PROJECT_NAME];
	new count = PBE_ReadIndexEntries(indexPath, folder, ext, s_Entries, PBE_MAX_INDEX_ITEMS);

	new File:fp = fopen(indexPath, io_write);
	if (!fp) return;
	new row[64];
	for (new i = 0; i < count; i++)
	{
		if (!strcmp(s_Entries[i], itemName, true)) continue;
		format(row, sizeof row, "%s\r\n", s_Entries[i]);
		fwrite(fp, row);
	}
	fclose(fp);
}

static stock PBE_WriteBarKVBlock(File:fp, sid, slot)
{
	new line[128], hexCol[16], hexBCol[16], hexBlCol[16], hexBlBCol[16];
	PBE_FormatHex(EditorBars[sid][slot][EBar_Color], hexCol);
	PBE_FormatHex(EditorBars[sid][slot][EBar_BorderColor], hexBCol);
	PBE_FormatHex(EditorBars[sid][slot][EBar_BlinkColor], hexBlCol);
	PBE_FormatHex(EditorBars[sid][slot][EBar_BlinkBorderColor], hexBlBCol);

	format(line, sizeof line, "Name=%s\r\n", EditorBars[sid][slot][EBar_Name]);
	fwrite(fp, line);
	format(line, sizeof line, "Style=%d\r\n", EditorBars[sid][slot][EBar_Style]);
	fwrite(fp, line);
	format(line, sizeof line, "PosX=%.4f\r\nPosY=%.4f\r\n", EditorBars[sid][slot][EBar_X], EditorBars[sid][slot][EBar_Y]);
	fwrite(fp, line);
	format(line, sizeof line, "Width=%.4f\r\nHeight=%.4f\r\n", EditorBars[sid][slot][EBar_W], EditorBars[sid][slot][EBar_H]);
	fwrite(fp, line);
	format(line, sizeof line, "Color=%s\r\n", hexCol);
	fwrite(fp, line);
	format(line, sizeof line, "MaxValue=%.4f\r\nValue=%.4f\r\n", EditorBars[sid][slot][EBar_Max], EditorBars[sid][slot][EBar_Val]);
	fwrite(fp, line);
	format(line, sizeof line, "Direction=%d\r\n", EditorBars[sid][slot][EBar_Dir]);
	fwrite(fp, line);
	format(line, sizeof line, "BorderSize=%.4f\r\nBorderColor=%s\r\n", EditorBars[sid][slot][EBar_Border], hexBCol);
	fwrite(fp, line);
	format(line, sizeof line, "Segments=%d\r\nSegmentScale=%.4f\r\n", EditorBars[sid][slot][EBar_Segments], EditorBars[sid][slot][EBar_SegScale]);
	fwrite(fp, line);
	format(line, sizeof line, "Visible=%d\r\n", EditorBars[sid][slot][EBar_Visible] ? 1 : 0);
	fwrite(fp, line);
	format(line, sizeof line, "AutoFill=%d\r\nAutoFillMax=%.4f\r\n", EditorBars[sid][slot][EBar_AutoFill] ? 1 : 0, EditorBars[sid][slot][EBar_AutoFillMax]);
	fwrite(fp, line);
	format(line, sizeof line, "Blinking=%d\r\nBlinkInterval=%d\r\nBlinkDuration=%d\r\n", EditorBars[sid][slot][EBar_Blinking] ? 1 : 0, EditorBars[sid][slot][EBar_BlinkInterval], EditorBars[sid][slot][EBar_BlinkDuration]);
	fwrite(fp, line);
	format(line, sizeof line, "BlinkColor=%s\r\nBlinkBorderColor=%s\r\n", hexBlCol, hexBlBCol);
	fwrite(fp, line);
	format(line, sizeof line, "MinValue=%.4f\r\n", EditorBars[sid][slot][EBar_Min]);
	fwrite(fp, line);
	if (EditorBars[sid][slot][EBar_LabelShow])
	{
		new hexLblCol[16];
		PBE_FormatHex(EditorBars[sid][slot][EBar_LabelColor], hexLblCol);
		format(line, sizeof line, "LabelShow=1\r\nLabelText=%s\r\nLabelColor=%s\r\nLabelFont=%d\r\nLabelAlign=%d\r\n",
			EditorBars[sid][slot][EBar_LabelText],
			hexLblCol,
			EditorBars[sid][slot][EBar_LabelFont],
			EditorBars[sid][slot][EBar_LabelAlign]
		);
		fwrite(fp, line);
		format(line, sizeof line, "LabelScaleX=%.4f\r\nLabelScaleY=%.4f\r\nLabelOffsetX=%.4f\r\nLabelOffsetY=%.4f\r\nLabelAutoScale=%d\r\nLabelFollowCol=%d\r\nLabelOrient=%d\r\n",
			EditorBars[sid][slot][EBar_LabelScaleX],
			EditorBars[sid][slot][EBar_LabelScaleY],
			EditorBars[sid][slot][EBar_LabelOffsetX],
			EditorBars[sid][slot][EBar_LabelOffsetY],
			EditorBars[sid][slot][EBar_LabelAutoScale] ? 1 : 0,
			EditorBars[sid][slot][EBar_LabelFollowCol] ? 1 : 0,
			EditorBars[sid][slot][EBar_LabelOrient]
		);
		fwrite(fp, line);
	}
	if (EditorBars[sid][slot][EBar_Gradient])
	{
		new hexGE[16], hexGM[16], hexGF[16];
		PBE_FormatHex(EditorBars[sid][slot][EBar_GradEmpty], hexGE);
		PBE_FormatHex(EditorBars[sid][slot][EBar_GradMid], hexGM);
		PBE_FormatHex(EditorBars[sid][slot][EBar_GradFull], hexGF);
		format(line, sizeof line, "Gradient=1\r\nGradInvert=%d\r\nGradEmpty=%s\r\nGradMid=%s\r\nGradFull=%s\r\n",
			EditorBars[sid][slot][EBar_GradInvert] ? 1 : 0, hexGE, hexGM, hexGF);
		fwrite(fp, line);
	}
}

static stock PBE_InitDefaultBarStruct(bar[E_PBE_BAR])
{
	bar[EBar_Used]             = true;
	bar[EBar_Handle]           = INVALID_PLAYER_BAR_ID;
	format(bar[EBar_Name], PBE_MAX_NAME, "ProgressBar");
	bar[EBar_Style]            = PB_STYLE_BAR;
	bar[EBar_X]                = 290.0;
	bar[EBar_Y]                = 220.0;
	bar[EBar_W]                = 60.0;
	bar[EBar_H]                = 8.0;
	bar[EBar_Color]            = PB_DEFAULT_COLOUR;
	bar[EBar_Max]              = 100.0;
	bar[EBar_Val]              = 70.0;
	bar[EBar_Dir]              = PB_DIR_RIGHT;
	bar[EBar_Border]           = PB_BORDER_DEFAULT;
	bar[EBar_BorderColor]      = 0;
	bar[EBar_Segments]         = PB_RING_SEGMENTS;
	bar[EBar_SegScale]         = PB_RING_SEGMENT_SCALE;
	bar[EBar_Visible]          = true;
	bar[EBar_AutoFill]         = false;
	bar[EBar_AutoFillMax]      = -1.0;
	bar[EBar_Blinking]         = false;
	bar[EBar_BlinkInterval]    = PB_BLINK_DEFAULT;
	bar[EBar_BlinkDuration]    = 0;
	bar[EBar_Min]              = 0.0;
	bar[EBar_BlinkColor]       = 0;
	bar[EBar_BlinkBorderColor] = 0;
	bar[EBar_LabelShow]        = false;
	bar[EBar_LabelAutoScale]   = true;
	bar[EBar_LabelFollowCol]   = false;
	bar[EBar_LabelOrient]      = PB_LABEL_ORIENT_AUTO;
	format(bar[EBar_LabelText], 32, "{PERCENT}%%");
	bar[EBar_LabelColor]       = 0xFFFFFFFF;
	bar[EBar_LabelFont]        = 1;
	bar[EBar_LabelAlign]       = 2;
	bar[EBar_LabelScaleX]      = 0.0;
	bar[EBar_LabelScaleY]      = 0.0;
	bar[EBar_LabelOffsetX]     = 0.0;
	bar[EBar_LabelOffsetY]     = 0.0;
	bar[EBar_Gradient]         = false;
	bar[EBar_GradInvert]       = false;
	bar[EBar_GradEmpty]        = 0xE74C3CFF;
	bar[EBar_GradMid]          = 0xF1C40FFF;
	bar[EBar_GradFull]         = 0x2ECC71FF;
}

static stock PBE_ApplyKVToBarStruct(bar[E_PBE_BAR], const key[], const val[])
{
	new parsedCol;
	if (!strcmp(key, "Name", true)) PBE_SanitizeVarName(val, bar[EBar_Name], PBE_MAX_NAME);
	else if (!strcmp(key, "Style", true)) bar[EBar_Style] = strval(val);
	else if (!strcmp(key, "PosX", true)) bar[EBar_X] = floatstr(val);
	else if (!strcmp(key, "PosY", true)) bar[EBar_Y] = floatstr(val);
	else if (!strcmp(key, "Width", true)) bar[EBar_W] = floatstr(val);
	else if (!strcmp(key, "Height", true)) bar[EBar_H] = floatstr(val);
	else if (!strcmp(key, "Color", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_Color] = parsedCol;
		else bar[EBar_Color] = strval(val);
	}
	else if (!strcmp(key, "MinValue", true)) bar[EBar_Min] = floatstr(val);
	else if (!strcmp(key, "MaxValue", true))
	{
		bar[EBar_Max] = floatstr(val);
		if (bar[EBar_Max] <= 0.0) bar[EBar_Max] = 100.0;
	}
	else if (!strcmp(key, "LabelShow", true)) bar[EBar_LabelShow] = (strval(val) != 0);
	else if (!strcmp(key, "LabelText", true)) format(bar[EBar_LabelText], 32, "%s", val);
	else if (!strcmp(key, "LabelColor", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_LabelColor] = parsedCol;
		else bar[EBar_LabelColor] = strval(val);
	}
	else if (!strcmp(key, "LabelFont", true)) bar[EBar_LabelFont] = strval(val);
	else if (!strcmp(key, "LabelAlign", true)) bar[EBar_LabelAlign] = strval(val);
	else if (!strcmp(key, "LabelScaleX", true)) bar[EBar_LabelScaleX] = floatstr(val);
	else if (!strcmp(key, "LabelScaleY", true)) bar[EBar_LabelScaleY] = floatstr(val);
	else if (!strcmp(key, "LabelOffsetX", true)) bar[EBar_LabelOffsetX] = floatstr(val);
	else if (!strcmp(key, "LabelOffsetY", true)) bar[EBar_LabelOffsetY] = floatstr(val);
	else if (!strcmp(key, "LabelAutoScale", true)) bar[EBar_LabelAutoScale] = (strval(val) != 0);
	else if (!strcmp(key, "LabelFollowCol", true)) bar[EBar_LabelFollowCol] = (strval(val) != 0);
	else if (!strcmp(key, "LabelOrient", true)) bar[EBar_LabelOrient] = strval(val);
	else if (!strcmp(key, "Gradient", true)) bar[EBar_Gradient] = (strval(val) != 0);
	else if (!strcmp(key, "GradInvert", true)) bar[EBar_GradInvert] = (strval(val) != 0);
	else if (!strcmp(key, "GradEmpty", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_GradEmpty] = parsedCol;
	}
	else if (!strcmp(key, "GradMid", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_GradMid] = parsedCol;
	}
	else if (!strcmp(key, "GradFull", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_GradFull] = parsedCol;
	}
	else if (!strcmp(key, "Value", true)) bar[EBar_Val] = floatstr(val);
	else if (!strcmp(key, "Direction", true)) bar[EBar_Dir] = strval(val);
	else if (!strcmp(key, "BorderSize", true)) bar[EBar_Border] = floatstr(val);
	else if (!strcmp(key, "BorderColor", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_BorderColor] = parsedCol;
		else bar[EBar_BorderColor] = strval(val);
	}
	else if (!strcmp(key, "Segments", true)) bar[EBar_Segments] = strval(val);
	else if (!strcmp(key, "SegmentScale", true)) bar[EBar_SegScale] = floatstr(val);
	else if (!strcmp(key, "Visible", true)) bar[EBar_Visible] = (strval(val) != 0);
	else if (!strcmp(key, "AutoFill", true)) bar[EBar_AutoFill] = (strval(val) != 0);
	else if (!strcmp(key, "AutoFillMax", true)) bar[EBar_AutoFillMax] = floatstr(val);
	else if (!strcmp(key, "Blinking", true)) bar[EBar_Blinking] = (strval(val) != 0);
	else if (!strcmp(key, "BlinkInterval", true)) bar[EBar_BlinkInterval] = strval(val);
	else if (!strcmp(key, "BlinkDuration", true)) bar[EBar_BlinkDuration] = strval(val);
	else if (!strcmp(key, "BlinkColor", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_BlinkColor] = parsedCol;
		else bar[EBar_BlinkColor] = strval(val);
	}
	else if (!strcmp(key, "BlinkBorderColor", true))
	{
		if (PBE_ParseHexColor(val, parsedCol)) bar[EBar_BlinkBorderColor] = parsedCol;
		else bar[EBar_BlinkBorderColor] = strval(val);
	}
}

static stock bool:PBE_SaveProjectFile(playerid, sid, const projName[])
{
	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_NormalizeProjectName(projName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return false;
	if (PBE_FindProjectLockOwner(cleanName, sid) != PBE_INVALID_SESSION) return false;

	new path[PBE_MAX_PATH];
	format(path, sizeof path, "%s%s.pbp", PBE_DIR_PROJECTS, cleanName);

	new File:fp = fopen(path, io_write);
	if (!fp) return false;

	new authorName[MAX_PLAYER_NAME + 1];
	GetPlayerName(playerid, authorName, sizeof authorName);

	new line[256];
	fwrite(fp, "; ============================================================================\r\n");
	fwrite(fp, "; Progress Bar Plus - Editor Project File (.pbp)\r\n");
	fwrite(fp, "; Format Version: " PBE_VERSION "\r\n");
	fwrite(fp, "; ============================================================================\r\n\r\n");

	fwrite(fp, "[Project]\r\n");
	format(line, sizeof line, "Name=%s\r\nAuthor=%s\r\nBarCount=%d\r\n\r\n", cleanName, authorName, EditorSession[sid][EP_BarCount]);
	fwrite(fp, line);

	for (new i = 0; i < EditorSession[sid][EP_BarCount]; i++)
	{
		if (!EditorBars[sid][i][EBar_Used]) continue;
		format(line, sizeof line, "[Bar_%d]\r\n", i);
		fwrite(fp, line);
		PBE_WriteBarKVBlock(fp, sid, i);
		fwrite(fp, "\r\n");
	}
	fclose(fp);

	format(EditorSession[sid][EP_ProjectName], PBE_MAX_PROJECT_NAME, "%s", cleanName);
	EditorSession[sid][EP_Dirty] = false;
	PBE_RegisterIndexEntry(PBE_PROJECT_INDEX, PBE_DIR_PROJECTS, ".pbp", cleanName);
	PBE_RefreshStatusHUD(playerid, sid);
	return true;
}

static stock bool:PBE_LoadProjectFile(playerid, sid, const folder[], const projName[], bool:mergeOnly)
{
	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_NormalizeProjectName(projName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return false;
	if (!mergeOnly && PBE_FindProjectLockOwner(cleanName, sid) != PBE_INVALID_SESSION) return false;

	new path[PBE_MAX_PATH];
	format(path, sizeof path, "%s%s.pbp", folder, cleanName);
	if (!fexist(path)) return false;

	new File:fp = fopen(path, io_read);
	if (!fp) return false;

	if (mergeOnly) PBE_SaveUndo(sid, "Merge Project");
	else PBE_ClearWorkspace(playerid, sid, cleanName);

	new line[256], trimmed[256], key[48], val[160];
	new currentSlot = -1;
	new loadedBars = 0;

	while (fread(fp, line, sizeof line))
	{
		PBE_Trim(line, trimmed, sizeof trimmed);
		if (trimmed[0] == '\0' || trimmed[0] == ';' || trimmed[0] == '#') continue;

		if (trimmed[0] == '[')
		{
			if (!strcmp(trimmed, "[Bar_", true, 5))
			{
				if (EditorSession[sid][EP_BarCount] < PBE_MAX_BARS)
				{
					currentSlot = EditorSession[sid][EP_BarCount];
					PBE_InitDefaultBarStruct(EditorBars[sid][currentSlot]);
					EditorSession[sid][EP_BarCount]++;
					loadedBars++;
				}
				else
				{
					currentSlot = -1;
				}
			}
			else
			{
				currentSlot = -1;
			}
			continue;
		}

		new eq = strfind(trimmed, "=");
		if (eq <= 0) continue;

		strmid(key, trimmed, 0, eq, sizeof key);
		strmid(val, trimmed, eq + 1, strlen(trimmed), sizeof val);
		PBE_Trim(key, key, sizeof key);
		PBE_Trim(val, val, sizeof val);

		if (currentSlot >= 0)
		{
			PBE_ApplyKVToBarStruct(EditorBars[sid][currentSlot], key, val);
			if (mergeOnly && !strcmp(key, "Name", true))
			{
				new uniq[PBE_MAX_NAME];
				EditorBars[sid][currentSlot][EBar_Used] = false;
				PBE_GenerateUniqueBarName(sid, val, uniq, sizeof uniq);
				EditorBars[sid][currentSlot][EBar_Used] = true;
				format(EditorBars[sid][currentSlot][EBar_Name], PBE_MAX_NAME, "%s", uniq);
			}
		}
	}
	fclose(fp);

	if (EditorSession[sid][EP_BarCount] > 0)
	{
		EditorSession[sid][EP_Selected] = EditorSession[sid][EP_BarCount] - 1;
	}
	EditorSession[sid][EP_Dirty] = mergeOnly;

	if (!mergeOnly && !strcmp(folder, PBE_DIR_PROJECTS, true))
	{
		PBE_RegisterIndexEntry(PBE_PROJECT_INDEX, PBE_DIR_PROJECTS, ".pbp", cleanName);
	}

	PBE_RebuildWorkspace(playerid, sid);
	return (loadedBars >= 0);
}

static stock bool:PBE_SaveTemplateFile(sid, slot, const tplName[])
{
	if (!(0 <= slot < EditorSession[sid][EP_BarCount]) || !EditorBars[sid][slot][EBar_Used]) return false;

	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_SanitizeFileName(tplName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return false;

	new path[PBE_MAX_PATH];
	format(path, sizeof path, "%s%s.pbt", PBE_DIR_TEMPLATES, cleanName);

	new File:fp = fopen(path, io_write);
	if (!fp) return false;

	fwrite(fp, "; Progress Bar Plus - Bar Template (.pbt)\r\n[Template]\r\n");
	PBE_WriteBarKVBlock(fp, sid, slot);
	fclose(fp);

	PBE_RegisterIndexEntry(PBE_TEMPLATE_INDEX, PBE_DIR_TEMPLATES, ".pbt", cleanName);
	return true;
}

static stock bool:PBE_LoadTemplateFile(playerid, sid, const tplName[])
{
	if (EditorSession[sid][EP_BarCount] >= PBE_MAX_BARS)
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Limit Reached: ", "Workspace already holds the maximum 20 bar layers.");
		return false;
	}

	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_SanitizeFileName(tplName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return false;

	new path[PBE_MAX_PATH];
	format(path, sizeof path, "%s%s.pbt", PBE_DIR_TEMPLATES, cleanName);
	if (!fexist(path)) return false;

	new File:fp = fopen(path, io_read);
	if (!fp) return false;

	PBE_SaveUndo(sid, "Spawn From Template");

	new line[256], trimmed[256], key[48], val[160];
	new initialBarCount = EditorSession[sid][EP_BarCount];
	new currentSlot = initialBarCount;
	new loadedBars = 0;
	new bool:multiSection = false;

	PBE_InitDefaultBarStruct(EditorBars[sid][currentSlot]);

	while (fread(fp, line, sizeof line))
	{
		PBE_Trim(line, trimmed, sizeof trimmed);
		if (trimmed[0] == '\0' || trimmed[0] == ';' || trimmed[0] == '#') continue;

		if (trimmed[0] == '[')
		{
			if (!strcmp(trimmed, "[Bar_", true, 5) || !strcmp(trimmed, "[Template_", true, 10))
			{
				if (!multiSection && loadedBars == 0)
				{
					multiSection = true;
					currentSlot = initialBarCount;
					PBE_InitDefaultBarStruct(EditorBars[sid][currentSlot]);
					EditorSession[sid][EP_BarCount]++;
					loadedBars++;
				}
				else
				{
					multiSection = true;
					if (EditorSession[sid][EP_BarCount] < PBE_MAX_BARS)
					{
						currentSlot = EditorSession[sid][EP_BarCount];
						PBE_InitDefaultBarStruct(EditorBars[sid][currentSlot]);
						EditorSession[sid][EP_BarCount]++;
						loadedBars++;
					}
					else
					{
						currentSlot = -1;
					}
				}
			}
			continue;
		}

		new eq = strfind(trimmed, "=");
		if (eq <= 0) continue;

		strmid(key, trimmed, 0, eq, sizeof key);
		strmid(val, trimmed, eq + 1, strlen(trimmed), sizeof val);
		PBE_Trim(key, key, sizeof key);
		PBE_Trim(val, val, sizeof val);

		if (currentSlot >= 0)
		{
			PBE_ApplyKVToBarStruct(EditorBars[sid][currentSlot], key, val);
		}
	}
	fclose(fp);

	if (!multiSection)
	{
		EditorSession[sid][EP_BarCount]++;
		loadedBars = 1;
	}

	new bool:anyFailed = false;
	for (new s = initialBarCount; s < initialBarCount + loadedBars; s++)
	{
		new uniq[PBE_MAX_NAME];
		EditorBars[sid][s][EBar_Used] = false;
		PBE_GenerateUniqueBarName(sid, EditorBars[sid][s][EBar_Name], uniq, sizeof uniq);
		EditorBars[sid][s][EBar_Used] = true;
		format(EditorBars[sid][s][EBar_Name], PBE_MAX_NAME, "%s", uniq);

		new neededTDs = PB_GetBarRequiredTextDraws(EditorBars[sid][s][EBar_Style], EditorBars[sid][s][EBar_Segments], EditorBars[sid][s][EBar_LabelShow]);
		if (!PB_CanAllocatePlayerTextDraws(playerid, neededTDs + PB_TD_SAFETY_HEADROOM) || !PBE_SpawnSlotHandle(playerid, sid, s))
		{
			anyFailed = true;
			for (new r = s; r < initialBarCount + loadedBars; r++)
			{
				EditorBars[sid][r][EBar_Used] = false;
			}
			EditorSession[sid][EP_BarCount] = s;
			break;
		}
	}

	if (EditorSession[sid][EP_BarCount] > initialBarCount)
	{
		EditorSession[sid][EP_Selected] = EditorSession[sid][EP_BarCount] - 1;
	}
	EditorSession[sid][EP_Dirty] = true;

	if (anyFailed)
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Allocation Stopped: ", "PlayerTextDraw limit reached for remaining bars!");
	}

	PBE_RenderEditorDock(playerid, sid);
	return (loadedBars > 0);
}

static stock Float:PBE_ParseTaggedFloat(const token[], Float:fallback)
{
	new clean[48];
	PBE_Trim(token, clean, sizeof clean);
	if (clean[0] == '\0') return fallback;
	new colon = strfind(clean, ":");
	if (colon >= 0 && colon + 1 < strlen(clean))
	{
		return floatstr(clean[colon + 1]);
	}
	return floatstr(clean);
}

static stock bool:PBE_ParsePawnCreateCall(playerid, sid, const stmt[], bool:rebuildNow)
{
	if (EditorSession[sid][EP_BarCount] >= PBE_MAX_BARS) return false;

	new callPos = strfind(stmt, "CreatePlayerProgressBar", true);
	if (callPos == -1) return false;

	new rawVarName[PBE_MAX_NAME];
	format(rawVarName, sizeof rawVarName, "ImportedBar");
	new eqPos = -1;
	for (new i = callPos - 1; i >= 0; i--)
	{
		if (stmt[i] == '=')
		{
			eqPos = i;
			break;
		}
	}
	if (eqPos > 0)
	{
		new lhs[64];
		new lhsStart = (eqPos > 60) ? (eqPos - 60) : 0;
		strmid(lhs, stmt, lhsStart, eqPos, sizeof lhs);
		new brk = strfind(lhs, "[");
		if (brk > 0) lhs[brk] = '\0';
		PBE_Trim(lhs, lhs, sizeof lhs);
		new sp = -1;
		for (new k = strlen(lhs) - 1; k >= 0; k--)
		{
			if (lhs[k] == ' ' || lhs[k] == '\t' || lhs[k] == ':')
			{
				sp = k;
				break;
			}
		}
		if (sp >= 0 && sp + 1 < strlen(lhs)) PBE_SanitizeVarName(lhs[sp + 1], rawVarName, sizeof rawVarName);
		else if (lhs[0] != '\0') PBE_SanitizeVarName(lhs, rawVarName, sizeof rawVarName);
	}

	new openParen = -1, closeParen = -1, depth = 0;
	new len = strlen(stmt);
	for (new i = callPos + 23; i < len; i++)
	{
		if (stmt[i] == '(')
		{
			if (depth == 0) openParen = i;
			depth++;
		}
		else if (stmt[i] == ')')
		{
			depth--;
			if (depth == 0 && openParen != -1)
			{
				closeParen = i;
				break;
			}
		}
	}
	if (openParen == -1 || closeParen == -1 || closeParen <= openParen + 1) return false;

	static s_Args[14][48];
	new argCount = 0, argStart = openParen + 1;
	depth = 0;
	for (new i = openParen + 1; i <= closeParen && argCount < 14; i++)
	{
		if (i < closeParen)
		{
			if (stmt[i] == '(') depth++;
			else if (stmt[i] == ')') depth--;
		}
		if ((i == closeParen) || (stmt[i] == ',' && depth == 0))
		{
			new rawArg[48];
			strmid(rawArg, stmt, argStart, i, sizeof rawArg);
			PBE_Trim(rawArg, s_Args[argCount], 48);
			argCount++;
			argStart = i + 1;
		}
	}
	if (argCount < 3) return false;

	new slot = EditorSession[sid][EP_BarCount];
	PBE_InitDefaultBarStruct(EditorBars[sid][slot]);

	EditorBars[sid][slot][EBar_Used] = false;
	PBE_GenerateUniqueBarName(sid, rawVarName, EditorBars[sid][slot][EBar_Name], PBE_MAX_NAME);
	EditorBars[sid][slot][EBar_Used] = true;

	EditorBars[sid][slot][EBar_X] = PBE_ParseTaggedFloat(s_Args[1], 290.0);
	EditorBars[sid][slot][EBar_Y] = PBE_ParseTaggedFloat(s_Args[2], 220.0);

	if (argCount > 3 && s_Args[3][0] != '\0') EditorBars[sid][slot][EBar_W] = PBE_ParseTaggedFloat(s_Args[3], 60.0);
	if (argCount > 4 && s_Args[4][0] != '\0') EditorBars[sid][slot][EBar_H] = PBE_ParseTaggedFloat(s_Args[4], 8.0);

	if (argCount > 5 && s_Args[5][0] != '\0')
	{
		new parsedCol;
		if (!strcmp(s_Args[5], "PB_DEFAULT_COLOUR", true)) EditorBars[sid][slot][EBar_Color] = PB_DEFAULT_COLOUR;
		else if (PBE_ParseHexColor(s_Args[5], parsedCol)) EditorBars[sid][slot][EBar_Color] = parsedCol;
		else EditorBars[sid][slot][EBar_Color] = strval(s_Args[5]);
	}

	if (argCount > 6 && s_Args[6][0] != '\0')
	{
		new Float:mv = PBE_ParseTaggedFloat(s_Args[6], 100.0);
		EditorBars[sid][slot][EBar_Max] = (mv > 0.0) ? mv : 100.0;
		EditorBars[sid][slot][EBar_Val] = EditorBars[sid][slot][EBar_Max] * 0.70;
	}

	if (argCount > 7 && s_Args[7][0] != '\0')
	{
		if (strfind(s_Args[7], "LEFT", true) != -1 || !strcmp(s_Args[7], "1")) EditorBars[sid][slot][EBar_Dir] = PB_DIR_LEFT;
		else if (strfind(s_Args[7], "UP", true) != -1 || !strcmp(s_Args[7], "2")) EditorBars[sid][slot][EBar_Dir] = PB_DIR_UP;
		else if (strfind(s_Args[7], "DOWN", true) != -1 || !strcmp(s_Args[7], "3")) EditorBars[sid][slot][EBar_Dir] = PB_DIR_DOWN;
		else EditorBars[sid][slot][EBar_Dir] = PB_DIR_RIGHT;
	}

	if (argCount > 8 && s_Args[8][0] != '\0')
	{
		if (!strcmp(s_Args[8], "PB_BORDER_DEFAULT", true)) EditorBars[sid][slot][EBar_Border] = PB_BORDER_DEFAULT;
		else EditorBars[sid][slot][EBar_Border] = PBE_ParseTaggedFloat(s_Args[8], PB_BORDER_DEFAULT);
	}

	if (argCount > 9 && s_Args[9][0] != '\0')
	{
		new parsedBCol;
		if (PBE_ParseHexColor(s_Args[9], parsedBCol)) EditorBars[sid][slot][EBar_BorderColor] = parsedBCol;
		else EditorBars[sid][slot][EBar_BorderColor] = strval(s_Args[9]);
	}

	if (argCount > 10 && s_Args[10][0] != '\0')
	{
		if (strfind(s_Args[10], "RING", true) != -1 || !strcmp(s_Args[10], "1")) EditorBars[sid][slot][EBar_Style] = PB_STYLE_RING;
		else if (strfind(s_Args[10], "CIRCLE", true) != -1 || !strcmp(s_Args[10], "2")) EditorBars[sid][slot][EBar_Style] = PB_STYLE_CIRCLE;
		else EditorBars[sid][slot][EBar_Style] = PB_STYLE_BAR;
	}

	if (argCount > 11 && s_Args[11][0] != '\0')
	{
		if (!strcmp(s_Args[11], "PB_RING_SEGMENTS", true)) EditorBars[sid][slot][EBar_Segments] = PB_RING_SEGMENTS;
		else EditorBars[sid][slot][EBar_Segments] = strval(s_Args[11]);
	}

	if (argCount > 12 && s_Args[12][0] != '\0')
	{
		if (!strcmp(s_Args[12], "PB_RING_SEGMENT_SCALE", true)) EditorBars[sid][slot][EBar_SegScale] = PB_RING_SEGMENT_SCALE;
		else EditorBars[sid][slot][EBar_SegScale] = PBE_ParseTaggedFloat(s_Args[12], PB_RING_SEGMENT_SCALE);
	}

	EditorSession[sid][EP_BarCount]++;
	EditorSession[sid][EP_Selected] = slot;
	EditorSession[sid][EP_Dirty] = true;

	if (rebuildNow)
	{
		PBE_SpawnSlotHandle(playerid, sid, slot);
		PBE_RenderEditorDock(playerid, sid);
	}
	return true;
}

static stock PBE_ImportPawnCodeFile(playerid, sid, const fileName[])
{
	new cleanFile[64];
	new outIdx = 0;
	for (new i = 0; fileName[i] != '\0' && outIdx < sizeof(cleanFile) - 1; i++)
	{
		new ch = fileName[i];
		if (('a' <= ch <= 'z') || ('A' <= ch <= 'Z') || ('0' <= ch <= '9') || ch == '_' || ch == '-' || ch == ' ' || ch == '.')
		{
			if (ch == '.' && fileName[i + 1] == '.') continue;
			cleanFile[outIdx++] = ch;
		}
	}
	cleanFile[outIdx] = '\0';
	if (cleanFile[0] == '\0') return -1;

	new path[PBE_MAX_PATH];
	format(path, sizeof path, "%s%s", PBE_DIR_IMPORTS, cleanFile);
	if (!fexist(path))
	{
		format(path, sizeof path, "%s%s.pwn", PBE_DIR_IMPORTS, cleanFile);
		if (!fexist(path))
		{
			format(path, sizeof path, "%s%s.inc", PBE_DIR_IMPORTS, cleanFile);
			if (!fexist(path))
			{
				format(path, sizeof path, "%s%s.txt", PBE_DIR_IMPORTS, cleanFile);
				if (!fexist(path)) return -1;
			}
		}
	}

	new File:fp = fopen(path, io_read);
	if (!fp) return -1;

	PBE_SaveUndo(sid, "Import Pawn Code File");

	static s_Accum[640];
	s_Accum[0] = '\0';
	new bool:collecting = false;
	new imported = 0;
	static s_ReadLine[256], s_TrimLine[256];

	while (fread(fp, s_ReadLine, sizeof s_ReadLine))
	{
		PBE_StripNewline(s_ReadLine);
		new cmt = strfind(s_ReadLine, "//");
		if (cmt >= 0) s_ReadLine[cmt] = '\0';
		PBE_Trim(s_ReadLine, s_TrimLine, sizeof s_TrimLine);
		if (s_TrimLine[0] == '\0') continue;

		if (!collecting)
		{
			if (strfind(s_TrimLine, "CreatePlayerProgressBar", true) != -1)
			{
				format(s_Accum, sizeof s_Accum, "%s", s_TrimLine);
				new d = 0, seenOpen = 0;
				for (new k = 0; s_Accum[k] != '\0'; k++)
				{
					if (s_Accum[k] == '(') { d++; seenOpen = 1; }
					else if (s_Accum[k] == ')') d--;
				}
				if (seenOpen && d <= 0)
				{
					if (PBE_ParsePawnCreateCall(playerid, sid, s_Accum, false)) imported++;
					s_Accum[0] = '\0';
				}
				else
				{
					collecting = true;
				}
			}
		}
		else
		{
			strcat(s_Accum, " ", sizeof s_Accum);
			strcat(s_Accum, s_TrimLine, sizeof s_Accum);
			new d = 0, seenOpen = 0;
			for (new k = 0; s_Accum[k] != '\0'; k++)
			{
				if (s_Accum[k] == '(') { d++; seenOpen = 1; }
				else if (s_Accum[k] == ')') d--;
			}
			if (seenOpen && d <= 0)
			{
				if (PBE_ParsePawnCreateCall(playerid, sid, s_Accum, false)) imported++;
				s_Accum[0] = '\0';
				collecting = false;
			}
		}
	}
	fclose(fp);

	if (imported > 0) PBE_RebuildWorkspace(playerid, sid);
	return imported;
}

static stock bool:PBE_ExportProjectCode(sid, const outName[], formatType, outPath[], pathSize = sizeof outPath)
{
	new count = EditorSession[sid][EP_BarCount];
	if (count <= 0) return false;

	new cleanName[PBE_MAX_PROJECT_NAME];
	PBE_SanitizeFileName(outName, cleanName, sizeof cleanName);
	if (cleanName[0] == '\0') return false;

	new funcIdent[PBE_MAX_PROJECT_NAME];
	PBE_SanitizeVarName(cleanName, funcIdent, sizeof funcIdent);

	if (formatType == PBE_EXP_MODULAR_INC) format(outPath, pathSize, "%s%s.inc", PBE_DIR_EXPORTS, cleanName);
	else if (formatType == PBE_EXP_RAW_SNIPPET) format(outPath, pathSize, "%s%s_raw.txt", PBE_DIR_EXPORTS, cleanName);
	else format(outPath, pathSize, "%s%s.pwn", PBE_DIR_EXPORTS, cleanName);

	new File:fp = fopen(outPath, io_write);
	if (!fp) return false;

	static s_OutLine[320];
	new hexCol[16], hexBCol[16], dirConst[20], styleConst[20];
	new hexBlCol[16], hexBlBCol[16];

	fwrite(fp, "/*\r\n");
	fwrite(fp, "================================================================================\r\n");
	fwrite(fp, "    Generated by Progress Bar Plus - Editor v" PBE_VERSION "\r\n");
	format(s_OutLine, sizeof s_OutLine, "    Project:     %s\r\n    Total Bars:  %d\r\n", cleanName, count);
	fwrite(fp, s_OutLine);
	fwrite(fp, "    Repository:  https://github.com/Walter-Correa/Progress-Bar-Plus\r\n");
	fwrite(fp, "================================================================================\r\n");
	fwrite(fp, "*/\r\n\r\n");

	if (formatType == PBE_EXP_MODULAR_INC)
	{
		format(s_OutLine, sizeof s_OutLine, "#if defined _pb_hud_%s_included\r\n\t#endinput\r\n#endif\r\n#define _pb_hud_%s_included\r\n\r\n", funcIdent, funcIdent);
		fwrite(fp, s_OutLine);
		fwrite(fp, "#include <ProgressBar>\r\n\r\n");
	}
	else if (formatType == PBE_EXP_GAMEMODE_PWN)
	{
		fwrite(fp, "#include <a_samp>\r\n#include <ProgressBar>\r\n\r\n");
	}

	for (new i = 0; i < count; i++)
	{
		if (!EditorBars[sid][i][EBar_Used]) continue;
		format(s_OutLine, sizeof s_OutLine, "new %s[MAX_PLAYERS] = {INVALID_PLAYER_BAR_ID, ...};\r\n", EditorBars[sid][i][EBar_Name]);
		fwrite(fp, s_OutLine);
	}
	fwrite(fp, "\r\n");

	if (formatType == PBE_EXP_RAW_SNIPPET)
	{
		for (new i = 0; i < count; i++)
		{
			if (!EditorBars[sid][i][EBar_Used]) continue;
			PBE_FormatHex(EditorBars[sid][i][EBar_Color], hexCol);
			PBE_FormatHex(EditorBars[sid][i][EBar_BorderColor], hexBCol);
			PBE_GetDirConst(EditorBars[sid][i][EBar_Dir], dirConst);
			PBE_GetStyleConst(EditorBars[sid][i][EBar_Style], styleConst);

			format(s_OutLine, sizeof s_OutLine, "%s[playerid] = CreatePlayerProgressBar(playerid, %.2f, %.2f, %.2f, %.2f, %s, %.2f, %s, %.2f, %s, %s, %d, %.2f);\r\n",
				EditorBars[sid][i][EBar_Name],
				EditorBars[sid][i][EBar_X], EditorBars[sid][i][EBar_Y],
				EditorBars[sid][i][EBar_W], EditorBars[sid][i][EBar_H],
				hexCol, EditorBars[sid][i][EBar_Max], dirConst,
				EditorBars[sid][i][EBar_Border], hexBCol, styleConst,
				EditorBars[sid][i][EBar_Segments], EditorBars[sid][i][EBar_SegScale]
			);
			fwrite(fp, s_OutLine);
			if (EditorBars[sid][i][EBar_Min] != 0.0)
			{
				format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarMinValue(playerid, %s[playerid], %.2f);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_Min]);
				fwrite(fp, s_OutLine);
			}
			format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarValue(playerid, %s[playerid], %.2f);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_Val]);
			fwrite(fp, s_OutLine);
			if (EditorBars[sid][i][EBar_LabelShow])
			{
				new hexLblCol[16];
				PBE_FormatHex(EditorBars[sid][i][EBar_LabelColor], hexLblCol);
				format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarLabel(playerid, %s[playerid], true, \"%s\", %s, %d, %d, %.2f, %.2f, %.2f, %.2f);\r\n",
					EditorBars[sid][i][EBar_Name],
					EditorBars[sid][i][EBar_LabelText],
					hexLblCol,
					EditorBars[sid][i][EBar_LabelAlign],
					EditorBars[sid][i][EBar_LabelFont],
					EditorBars[sid][i][EBar_LabelScaleX],
					EditorBars[sid][i][EBar_LabelScaleY],
					EditorBars[sid][i][EBar_LabelOffsetX],
					EditorBars[sid][i][EBar_LabelOffsetY]
				);
				fwrite(fp, s_OutLine);
				if (EditorBars[sid][i][EBar_LabelFollowCol])
				{
					format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarLabelFollowColour(playerid, %s[playerid], true);\r\n", EditorBars[sid][i][EBar_Name]);
					fwrite(fp, s_OutLine);
				}
				if (EditorBars[sid][i][EBar_LabelOrient] != PB_LABEL_ORIENT_AUTO)
				{
					format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarLabelOrientation(playerid, %s[playerid], %d);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_LabelOrient]);
					fwrite(fp, s_OutLine);
				}
			}
			if (EditorBars[sid][i][EBar_Visible])
			{
				format(s_OutLine, sizeof s_OutLine, "ShowPlayerProgressBar(playerid, %s[playerid]);\r\n", EditorBars[sid][i][EBar_Name]);
				fwrite(fp, s_OutLine);
			}
			if (EditorBars[sid][i][EBar_Gradient])
			{
				new hexGE[16], hexGM[16], hexGF[16];
				PBE_FormatHex(EditorBars[sid][i][EBar_GradEmpty], hexGE);
				PBE_FormatHex(EditorBars[sid][i][EBar_GradMid], hexGM);
				PBE_FormatHex(EditorBars[sid][i][EBar_GradFull], hexGF);
				if (EditorBars[sid][i][EBar_GradInvert])
				{
					format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarGradient(playerid, %s[playerid], true, %s, %s, %s, true);\r\n", EditorBars[sid][i][EBar_Name], hexGE, hexGF, hexGM);
				}
				else
				{
					format(s_OutLine, sizeof s_OutLine, "SetPlayerProgressBarGradient(playerid, %s[playerid], true, %s, %s, %s);\r\n", EditorBars[sid][i][EBar_Name], hexGE, hexGF, hexGM);
				}
				fwrite(fp, s_OutLine);
			}
			if (EditorBars[sid][i][EBar_AutoFill])
			{
				format(s_OutLine, sizeof s_OutLine, "AutoFillPlayerProgressBar(playerid, %s[playerid], %.2f);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_AutoFillMax]);
				fwrite(fp, s_OutLine);
			}
			if (EditorBars[sid][i][EBar_Blinking])
			{
				PBE_FormatHex(EditorBars[sid][i][EBar_BlinkColor], hexBlCol);
				PBE_FormatHex(EditorBars[sid][i][EBar_BlinkBorderColor], hexBlBCol);
				format(s_OutLine, sizeof s_OutLine, "BlinkPlayerProgressBar(playerid, %s[playerid], %d, %d, %s, %s);\r\n",
					EditorBars[sid][i][EBar_Name],
					EditorBars[sid][i][EBar_BlinkInterval],
					EditorBars[sid][i][EBar_BlinkDuration],
					hexBlCol,
					hexBlBCol
				);
				fwrite(fp, s_OutLine);
			}
			fwrite(fp, "\r\n");
		}
		fclose(fp);
		return true;
	}

	format(s_OutLine, sizeof s_OutLine, "stock Create%sBars(playerid)\r\n{\r\n", funcIdent);
	fwrite(fp, s_OutLine);

	for (new i = 0; i < count; i++)
	{
		if (!EditorBars[sid][i][EBar_Used]) continue;
		PBE_FormatHex(EditorBars[sid][i][EBar_Color], hexCol);
		PBE_FormatHex(EditorBars[sid][i][EBar_BorderColor], hexBCol);
		PBE_GetDirConst(EditorBars[sid][i][EBar_Dir], dirConst);
		PBE_GetStyleConst(EditorBars[sid][i][EBar_Style], styleConst);

		format(s_OutLine, sizeof s_OutLine, "\t%s[playerid] = CreatePlayerProgressBar(playerid, %.2f, %.2f, %.2f, %.2f, %s, %.2f, %s, %.2f, %s, %s, %d, %.2f);\r\n",
			EditorBars[sid][i][EBar_Name],
			EditorBars[sid][i][EBar_X], EditorBars[sid][i][EBar_Y],
			EditorBars[sid][i][EBar_W], EditorBars[sid][i][EBar_H],
			hexCol, EditorBars[sid][i][EBar_Max], dirConst,
			EditorBars[sid][i][EBar_Border], hexBCol, styleConst,
			EditorBars[sid][i][EBar_Segments], EditorBars[sid][i][EBar_SegScale]
		);
		fwrite(fp, s_OutLine);

		if (EditorBars[sid][i][EBar_Min] != 0.0)
		{
			format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarMinValue(playerid, %s[playerid], %.2f);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_Min]);
			fwrite(fp, s_OutLine);
		}
		format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarValue(playerid, %s[playerid], %.2f);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_Val]);
		fwrite(fp, s_OutLine);
		if (EditorBars[sid][i][EBar_LabelShow])
		{
			new hexLblCol[16];
			PBE_FormatHex(EditorBars[sid][i][EBar_LabelColor], hexLblCol);
			format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarLabel(playerid, %s[playerid], true, \"%s\", %s, %d, %d, %.2f, %.2f, %.2f, %.2f);\r\n",
				EditorBars[sid][i][EBar_Name],
				EditorBars[sid][i][EBar_LabelText],
				hexLblCol,
				EditorBars[sid][i][EBar_LabelAlign],
				EditorBars[sid][i][EBar_LabelFont],
				EditorBars[sid][i][EBar_LabelScaleX],
				EditorBars[sid][i][EBar_LabelScaleY],
				EditorBars[sid][i][EBar_LabelOffsetX],
				EditorBars[sid][i][EBar_LabelOffsetY]
			);
			fwrite(fp, s_OutLine);
			if (EditorBars[sid][i][EBar_LabelFollowCol])
			{
				format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarLabelFollowColour(playerid, %s[playerid], true);\r\n", EditorBars[sid][i][EBar_Name]);
				fwrite(fp, s_OutLine);
			}
			if (EditorBars[sid][i][EBar_LabelOrient] != PB_LABEL_ORIENT_AUTO)
			{
				format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarLabelOrientation(playerid, %s[playerid], %d);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_LabelOrient]);
				fwrite(fp, s_OutLine);
			}
		}

		if (EditorBars[sid][i][EBar_Visible])
		{
			format(s_OutLine, sizeof s_OutLine, "\tShowPlayerProgressBar(playerid, %s[playerid]);\r\n", EditorBars[sid][i][EBar_Name]);
			fwrite(fp, s_OutLine);
		}
		if (EditorBars[sid][i][EBar_Gradient])
		{
			new hexGE[16], hexGM[16], hexGF[16];
			PBE_FormatHex(EditorBars[sid][i][EBar_GradEmpty], hexGE);
			PBE_FormatHex(EditorBars[sid][i][EBar_GradMid], hexGM);
			PBE_FormatHex(EditorBars[sid][i][EBar_GradFull], hexGF);
			if (EditorBars[sid][i][EBar_GradInvert])
			{
				format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarGradient(playerid, %s[playerid], true, %s, %s, %s, true);\r\n", EditorBars[sid][i][EBar_Name], hexGE, hexGF, hexGM);
			}
			else
			{
				format(s_OutLine, sizeof s_OutLine, "\tSetPlayerProgressBarGradient(playerid, %s[playerid], true, %s, %s, %s);\r\n", EditorBars[sid][i][EBar_Name], hexGE, hexGF, hexGM);
			}
			fwrite(fp, s_OutLine);
		}
		if (EditorBars[sid][i][EBar_AutoFill])
		{
			format(s_OutLine, sizeof s_OutLine, "\tAutoFillPlayerProgressBar(playerid, %s[playerid], %.2f);\r\n", EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_AutoFillMax]);
			fwrite(fp, s_OutLine);
		}
		if (EditorBars[sid][i][EBar_Blinking])
		{
			PBE_FormatHex(EditorBars[sid][i][EBar_BlinkColor], hexBlCol);
			PBE_FormatHex(EditorBars[sid][i][EBar_BlinkBorderColor], hexBlBCol);
			format(s_OutLine, sizeof s_OutLine, "\tBlinkPlayerProgressBar(playerid, %s[playerid], %d, %d, %s, %s);\r\n",
				EditorBars[sid][i][EBar_Name],
				EditorBars[sid][i][EBar_BlinkInterval],
				EditorBars[sid][i][EBar_BlinkDuration],
				hexBlCol,
				hexBlBCol
			);
			fwrite(fp, s_OutLine);
		}
		if (i + 1 < count) fwrite(fp, "\r\n");
	}
	fwrite(fp, "\treturn 1;\r\n}\r\n\r\n");

	format(s_OutLine, sizeof s_OutLine, "stock Show%sBars(playerid)\r\n{\r\n", funcIdent);
	fwrite(fp, s_OutLine);
	for (new i = 0; i < count; i++)
	{
		if (!EditorBars[sid][i][EBar_Used]) continue;
		format(s_OutLine, sizeof s_OutLine, "\tShowPlayerProgressBar(playerid, %s[playerid]);\r\n", EditorBars[sid][i][EBar_Name]);
		fwrite(fp, s_OutLine);
	}
	fwrite(fp, "\treturn 1;\r\n}\r\n\r\n");

	format(s_OutLine, sizeof s_OutLine, "stock Hide%sBars(playerid)\r\n{\r\n", funcIdent);
	fwrite(fp, s_OutLine);
	for (new i = 0; i < count; i++)
	{
		if (!EditorBars[sid][i][EBar_Used]) continue;
		format(s_OutLine, sizeof s_OutLine, "\tHidePlayerProgressBar(playerid, %s[playerid]);\r\n", EditorBars[sid][i][EBar_Name]);
		fwrite(fp, s_OutLine);
	}
	fwrite(fp, "\treturn 1;\r\n}\r\n\r\n");

	format(s_OutLine, sizeof s_OutLine, "stock Destroy%sBars(playerid)\r\n{\r\n", funcIdent);
	fwrite(fp, s_OutLine);
	for (new i = 0; i < count; i++)
	{
		if (!EditorBars[sid][i][EBar_Used]) continue;
		format(s_OutLine, sizeof s_OutLine, "\tDestroyPlayerProgressBar(playerid, %s[playerid]);\r\n\t%s[playerid] = INVALID_PLAYER_BAR_ID;\r\n",
			EditorBars[sid][i][EBar_Name], EditorBars[sid][i][EBar_Name]);
		fwrite(fp, s_OutLine);
	}
	fwrite(fp, "\treturn 1;\r\n}\r\n");

	fclose(fp);
	return true;
}

/*
================================================================================
    8. Interactive Editor Dialog Renderers
================================================================================
*/

static stock PBE_OnOffTag(bool:flag, dest[], size = sizeof dest)
{
	if (flag) format(dest, size, "{10B981}ON");
	else format(dest, size, "{94A3B8}OFF");
}

static stock PBE_GetDirShort(dir, dest[], size = sizeof dest)
{
	switch (dir)
	{
		case PB_DIR_LEFT: format(dest, size, "LEFT");
		case PB_DIR_UP:   format(dest, size, "UP");
		case PB_DIR_DOWN: format(dest, size, "DOWN");
		default:          format(dest, size, "RIGHT");
	}
}

static stock PBE_OpenProjectMenu(playerid, sid)
{
	new dirtyStr[48];
	if (EditorSession[sid][EP_Dirty]) format(dirtyStr, sizeof dirtyStr, "{F59E0B}Unsaved Changes");
	else format(dirtyStr, sizeof dirtyStr, "{10B981}Saved / Clean");

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Action\tWorkspace Details\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}New Blank Project\t{94A3B8}Reset workspace and start a fresh HUD\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Open Saved Project (.pbp)\t{94A3B8}Browse scriptfiles/Progress Bars/Projects/\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Quick Save Project\t{FFFFFF}%s.pbp (%s{FFFFFF})\n", EditorSession[sid][EP_ProjectName], dirtyStr);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}Save Project As...\t{94A3B8}Save under a new project filename\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Import Hub (Projects & Pawn Code)\t{94A3B8}Merge .pbp or parse CreatePlayerProgressBar code\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Export Production Pawn Code\t{94A3B8}Generate .pwn / .inc / snippet (%d bars)\n", EditorSession[sid][EP_BarCount]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{EF4444}Delete Saved Project\t{94A3B8}Remove a .pbp project from disk", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_PROJECT_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Project Manager", s_DlgBody, "Select", "Close");
}

static stock PBE_OpenLoadProjectBrowser(playerid, sid, bool:forDelete = false)
{
	g_PBEBrowserCount[sid] = PBE_ReadIndexEntries(PBE_PROJECT_INDEX, PBE_DIR_PROJECTS, ".pbp", g_PBEBrowserCache[sid], PBE_MAX_INDEX_ITEMS);

	if (forDelete && g_PBEBrowserCount[sid] <= 0)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Projects Found: ", "There are no indexed .pbp projects to delete.");
		PBE_OpenProjectMenu(playerid, sid);
		return;
	}

	s_DlgBody[0] = '\0';
	if (!forDelete)
	{
		strcat(s_DlgBody, "Project Name\tLocation\n", sizeof s_DlgBody);
		strcat(s_DlgBody, "{F59E0B}[Type Project Filename Manually...]\t{94A3B8}Load any .pbp file by name\n", sizeof s_DlgBody);
	}
	else
	{
		strcat(s_DlgBody, "Project Name\tAction\n", sizeof s_DlgBody);
	}

	for (new i = 0; i < g_PBEBrowserCount[sid]; i++)
	{
		new ownerSid = PBE_FindProjectLockOwner(g_PBEBrowserCache[sid][i], sid);
		if (ownerSid != PBE_INVALID_SESSION)
		{
			new ownerPid = EditorSession[ownerSid][EP_PlayerID];
			new ownerName[MAX_PLAYER_NAME + 1];
			GetPlayerName(ownerPid, ownerName, sizeof ownerName);
			format(s_DlgRow, sizeof s_DlgRow, "{94A3B8}%s\t{F59E0B}[LOCKED - In Use by %s (ID %d)]\n", g_PBEBrowserCache[sid][i], ownerName, ownerPid);
		}
		else if (!forDelete)
		{
			if (!strcmp(EditorSession[sid][EP_ProjectName], g_PBEBrowserCache[sid][i], true))
			{
				format(s_DlgRow, sizeof s_DlgRow, "{10B981}%s\t{10B981}[Active in Your Workspace] {94A3B8}%s%s.pbp\n", g_PBEBrowserCache[sid][i], PBE_DIR_PROJECTS, g_PBEBrowserCache[sid][i]);
			}
			else
			{
				format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}%s\t{94A3B8}%s%s.pbp\n", g_PBEBrowserCache[sid][i], PBE_DIR_PROJECTS, g_PBEBrowserCache[sid][i]);
			}
		}
		else
		{
			format(s_DlgRow, sizeof s_DlgRow, "{EF4444}%s\t{94A3B8}Click to delete .pbp file\n", g_PBEBrowserCache[sid][i]);
		}
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}

	if (!forDelete)
	{
		PBE_ShowDialog(playerid, PBE_DLG_LOAD_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Open Project (.pbp)", s_DlgBody, "Load", "Back");
	}
	else
	{
		PBE_ShowDialog(playerid, PBE_DLG_DELETE_PROJ_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{EF4444}PB Editor {FFFFFF}- Delete Saved Project", s_DlgBody, "Delete", "Back");
	}
}

static stock PBE_OpenImportMenu(playerid)
{
	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Import Method\tSource & Behavior\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Open .pbp Project from Imports/\t{94A3B8}Replaces current workspace with imported .pbp\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Merge .pbp Project Layers\t{94A3B8}Appends bars from another .pbp into active project\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Import Pawn Source File (.pwn/.inc/.txt)\t{94A3B8}Parses CreatePlayerProgressBar calls in Imports/\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Paste CreatePlayerProgressBar Code\t{94A3B8}Paste a single Pawn code line directly in-game", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_IMPORT_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Universal Import Hub", s_DlgBody, "Select", "Back");
}

static stock PBE_OpenExportMenu(playerid, sid)
{
	if (EditorSession[sid][EP_BarCount] <= 0)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Empty Workspace: ", "Add at least one progress bar before exporting code.");
		PBE_SetCursor(playerid, sid, true);
		return;
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Export Format\tOutput Structure\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Complete Pawn Script (.pwn)\t{94A3B8}Includes + Arrays + Create/Show/Hide/Destroy stocks\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Modular Include Header (.inc)\t{94A3B8}Include-guarded HUD module ready for #include\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Raw Code Snippet (_raw.txt)\t{94A3B8}Direct Create/SetValue/Show lines for copy-paste", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_EXPORT_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{10B981}PB Editor {FFFFFF}- Export Code Generator", s_DlgBody, "Next", "Close");
}

static stock PBE_OpenCreateMenu(playerid, sid)
{
	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "New Layer Type\tDescription\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Linear Progress Bar\t{94A3B8}Classic horizontal or vertical bar (PB_STYLE_BAR)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Radial Segmented Ring\t{94A3B8}Circular 4-60 segment speedometer/gauge (PB_STYLE_RING)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Circular Disc Gauge\t{94A3B8}Smooth round sprite fill disc (PB_STYLE_CIRCLE)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}From Template Library (.pbt)\t{94A3B8}Spawn a pre-styled bar from Templates/\n", sizeof s_DlgBody);

	if (PBE_HasActiveBar(sid))
	{
		new s = EditorSession[sid][EP_Selected];
		format(s_DlgRow, sizeof s_DlgRow, "{94A3B8}Duplicate Active Layer\t{FFFFFF}Clone #%d %s", s + 1, EditorBars[sid][s][EBar_Name]);
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}
	else
	{
		strcat(s_DlgBody, "{94A3B8}Duplicate Active Layer\t{94A3B8}(No active layer selected)", sizeof s_DlgBody);
	}

	PBE_ShowDialog(playerid, PBE_DLG_CREATE_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Create New Layer", s_DlgBody, "Create", "Close");
}

static stock PBE_OpenTemplateBrowser(playerid, sid)
{
	g_PBEBrowserCount[sid] = PBE_ReadIndexEntries(PBE_TEMPLATE_INDEX, PBE_DIR_TEMPLATES, ".pbt", g_PBEBrowserCache[sid], PBE_MAX_INDEX_ITEMS);
	if (g_PBEBrowserCount[sid] <= 0)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Templates Found: ", "Save any bar layer as a template (.pbt) to build your library!");
		PBE_OpenCreateMenu(playerid, sid);
		return;
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Template Preset\tSource File\n", sizeof s_DlgBody);
	for (new i = 0; i < g_PBEBrowserCount[sid]; i++)
	{
		format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}%s\t{94A3B8}%s.pbt\n", g_PBEBrowserCache[sid][i], g_PBEBrowserCache[sid][i]);
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}

	PBE_ShowDialog(playerid, PBE_DLG_TEMPLATE_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Template Library (.pbt)", s_DlgBody, "Spawn", "Back");
}

static stock PBE_OpenLayersMenu(playerid, sid)
{
	new count = EditorSession[sid][EP_BarCount];
	if (count <= 0)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Layers: ", "Your workspace has no progress bars yet. Opening '+ CREATE'...");
		PBE_OpenCreateMenu(playerid, sid);
		return;
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Layer & Variable\tStyle\tPosition & Size\tStatus\n", sizeof s_DlgBody);

	new stShort[16], rgbTag[16], selPrefix[24], visTag[48];
	for (new i = 0; i < count; i++)
	{
		PBE_GetStyleShort(EditorBars[sid][i][EBar_Style], stShort);
		PBE_FormatRGBTag(EditorBars[sid][i][EBar_Color], rgbTag);

		if (i == EditorSession[sid][EP_Selected]) format(selPrefix, sizeof selPrefix, "{10B981}>> ");
		else format(selPrefix, sizeof selPrefix, "{94A3B8}");

		if (EditorBars[sid][i][EBar_Visible]) format(visTag, sizeof visTag, "{10B981}Visible");
		else format(visTag, sizeof visTag, "{EF4444}Hidden");

		format(s_DlgRow, sizeof s_DlgRow, "%s#%d {FFFFFF}%s\t%s%s\t{94A3B8}(%.1f, %.1f)  %.1fx%.1f\t%s\n",
			selPrefix,
			i + 1,
			EditorBars[sid][i][EBar_Name],
			rgbTag,
			stShort,
			EditorBars[sid][i][EBar_X],
			EditorBars[sid][i][EBar_Y],
			EditorBars[sid][i][EBar_W],
			EditorBars[sid][i][EBar_H],
			visTag
		);
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}

	PBE_ShowDialog(playerid, PBE_DLG_LAYERS_LIST, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Layer Stack (Bottom -> Top)", s_DlgBody, "Manage", "Close");
}

static stock PBE_OpenLayerActionsMenu(playerid, sid)
{
	if (!PBE_HasActiveBar(sid))
	{
		PBE_OpenLayersMenu(playerid, sid);
		return;
	}

	new s = EditorSession[sid][EP_Selected];
	new visStr[64], title[192];
	if (EditorBars[sid][s][EBar_Visible]) format(visStr, sizeof visStr, "{10B981}Visible (Click to Hide)");
	else format(visStr, sizeof visStr, "{EF4444}Hidden (Click to Show)");

	format(title, sizeof title, "{38BDF8}Layer #%d {FFFFFF}- %s", s + 1, EditorBars[sid][s][EBar_Name]);

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Layer Operation\tDetails\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Keep Active & Return to Canvas\t{94A3B8}Edit this layer using the Editor Dock\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Rename Variable Identifier\t{FFFFFF}%s\n", EditorBars[sid][s][EBar_Name]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{38BDF8}Duplicate / Clone Layer\t{94A3B8}Create an offset copy of this bar\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Toggle Visibility\t%s\n", visStr);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{FFFFFF}Bring Forward (Z-Order +1)\t{94A3B8}Render above the next layer\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}Send Backward (Z-Order -1)\t{94A3B8}Render behind the previous layer\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}Bring to Front (Topmost)\t{94A3B8}Move to top of rendering stack\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}Send to Back (Background)\t{94A3B8}Move to bottom of rendering stack\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Save as Reusable Template (.pbt)\t{94A3B8}Store in scriptfiles/Progress Bars/Templates/\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{EF4444}Delete Layer\t{94A3B8}Remove this progress bar from workspace", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_LAYER_ACTIONS, DIALOG_STYLE_TABLIST_HEADERS, title, s_DlgBody, "Execute", "Layers");
}

static stock PBE_OpenStyleMenu(playerid, sid)
{
	if (!PBE_HasActiveBar(sid))
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Active Layer: ", "Create or select a progress bar layer first.");
		PBE_SetCursor(playerid, sid, true);
		return;
	}

	new s = EditorSession[sid][EP_Selected];
	new stConst[24], dirConst[24];
	PBE_GetStyleConst(EditorBars[sid][s][EBar_Style], stConst);
	PBE_GetDirConst(EditorBars[sid][s][EBar_Dir], dirConst);

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Geometry & Style Property\tCurrent Value\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Visual Gauge Style\t{FFFFFF}%s\n", stConst);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Fill Direction\t{FFFFFF}%s\n", dirConst);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Ring Segment Count\t{FFFFFF}%d segments (Range: 4 - 60)\n", EditorBars[sid][s][EBar_Segments]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Ring Segment Scale\t{FFFFFF}%.2f (Overlap/dot size)\n", EditorBars[sid][s][EBar_SegScale]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Interactive Border Scrubber\t{FFFFFF}%.2f px (Live WASD / Arrows)\n", EditorBars[sid][s][EBar_Border]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Exact Border Thickness\t{94A3B8}%.2f px (0.50 - 5.00)\n", EditorBars[sid][s][EBar_Border]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Exact Screen Coordinates (X, Y)\t{94A3B8}%.2f, %.2f\n", EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Exact Dimensions (Width, Height)\t{94A3B8}%.2f x %.2f\n", EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	new lblTag[64];
	if (EditorBars[sid][s][EBar_LabelShow]) format(lblTag, sizeof lblTag, "{10B981}ON {FFFFFF}(\"%s\")", EditorBars[sid][s][EBar_LabelText]);
	else format(lblTag, sizeof lblTag, "{EF4444}OFF");
	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}HUD Value / Text Label\t%s", lblTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_STYLE_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Style & Geometry Inspector", s_DlgBody, "Edit", "Close");
}

static stock PBE_SyncLabel(playerid, sid, slot)
{
	new h = EditorBars[sid][slot][EBar_Handle];
	if (!IsValidPlayerProgressBar(playerid, h)) return;
	SetPlayerProgressBarLabel(
		playerid,
		h,
		EditorBars[sid][slot][EBar_LabelShow],
		EditorBars[sid][slot][EBar_LabelText],
		EditorBars[sid][slot][EBar_LabelColor],
		EditorBars[sid][slot][EBar_LabelAlign],
		EditorBars[sid][slot][EBar_LabelFont],
		EditorBars[sid][slot][EBar_LabelScaleX],
		EditorBars[sid][slot][EBar_LabelScaleY],
		EditorBars[sid][slot][EBar_LabelOffsetX],
		EditorBars[sid][slot][EBar_LabelOffsetY]
	);
	SetPlayerProgressBarLabelAutoScale(playerid, h, EditorBars[sid][slot][EBar_LabelAutoScale]);
	SetPlayerProgressBarLabelFollowColour(playerid, h, EditorBars[sid][slot][EBar_LabelFollowCol]);
	SetPlayerProgressBarLabelOrientation(playerid, h, EditorBars[sid][slot][EBar_LabelOrient]);
}

static stock PBE_OpenLabelMenu(playerid, sid)
{
	if (!PBE_HasActiveBar(sid)) return;
	new s = EditorSession[sid][EP_Selected];

	new enTag[24];
	PBE_OnOffTag(EditorBars[sid][s][EBar_LabelShow], enTag);

	new hexCol[16], rgbTag[16];
	PBE_FormatHex(EditorBars[sid][s][EBar_LabelColor], hexCol);
	PBE_FormatRGBTag(EditorBars[sid][s][EBar_LabelColor], rgbTag);

	new followTag[24];
	PBE_OnOffTag(EditorBars[sid][s][EBar_LabelFollowCol], followTag);

	new alignName[16];
	if (EditorBars[sid][s][EBar_LabelAlign] == 1) format(alignName, sizeof alignName, "Left (1)");
	else if (EditorBars[sid][s][EBar_LabelAlign] == 3) format(alignName, sizeof alignName, "Right (3)");
	else format(alignName, sizeof alignName, "Center (2)");

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Label Property\tCurrent Setting\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Toggle Value / Text Label\t%s\n", enTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Format Template / Text\t{FFFFFF}\"%s\"\n", EditorBars[sid][s][EBar_LabelText]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{38BDF8}Quick Template Presets\t{94A3B8}{PERCENT}%, {VAL}/{MAX}, HP, etc.\n", sizeof s_DlgBody);

	if (EditorBars[sid][s][EBar_LabelFollowCol])
	{
		format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Text Color (Palette / Hex)\t{10B981}Match Bar Color (Auto)\n");
	}
	else
	{
		format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Text Color (Palette / Hex)\t%s|||| {FFFFFF}%s\n", rgbTag, hexCol);
	}
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Sync Color with Bar / Gradient\t%s\n", followTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Font Style\t{94A3B8}Font %d\n", EditorBars[sid][s][EBar_LabelFont]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Horizontal Alignment\t{94A3B8}%s\n", alignName);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	new fitTag[24], scaleDesc[48];
	PBE_OnOffTag(EditorBars[sid][s][EBar_LabelAutoScale], fitTag);
	if (EditorBars[sid][s][EBar_LabelAutoScale]) format(scaleDesc, sizeof scaleDesc, "{10B981}Auto-Fit to Bar");
	else format(scaleDesc, sizeof scaleDesc, "Manual (%.2f x %.2f)", EditorBars[sid][s][EBar_LabelScaleX], EditorBars[sid][s][EBar_LabelScaleY]);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Auto-Fit Font Size to Bar Bounds\t%s\n", fitTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Manual Letter Size (Scale X, Y)\t{94A3B8}%s\n", scaleDesc);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Position Offset (X, Y)\t{94A3B8}%.2f, %.2f", EditorBars[sid][s][EBar_LabelOffsetX], EditorBars[sid][s][EBar_LabelOffsetY]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_LABEL_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- HUD Value / Text Label", s_DlgBody, "Select", "Back");
}

static stock PBE_OpenSwatchPalette(playerid, dialogid, const title[], bool:includeAutoZero)
{
	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Color Swatch\tHex RGBA\n", sizeof s_DlgBody);

	if (includeAutoZero)
	{
		strcat(s_DlgBody, "{94A3B8}[0] Automatic / Default Derived\t{94A3B8}0x00000000\n", sizeof s_DlgBody);
	}

	new hexOut[16];
	for (new i = 0; i < sizeof(g_PBESwatches); i++)
	{
		PBE_FormatHex(g_PBESwatches[i][Swatch_RGBA], hexOut);
		format(s_DlgRow, sizeof s_DlgRow, "{%s}||||  {FFFFFF}%s\t{94A3B8}%s\n",
			g_PBESwatches[i][Swatch_HexStr],
			g_PBESwatches[i][Swatch_Name],
			hexOut
		);
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}

	PBE_ShowDialog(playerid, dialogid, DIALOG_STYLE_TABLIST_HEADERS, title, s_DlgBody, "Apply", "Back");
}

static stock PBE_OpenColorMenu(playerid, sid)
{
	if (!PBE_HasActiveBar(sid))
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Active Layer: ", "Create or select a progress bar layer first.");
		PBE_SetCursor(playerid, sid, true);
		return;
	}

	new s = EditorSession[sid][EP_Selected];
	new mainHex[16], mainTag[16], bdrDesc[80];
	PBE_FormatHex(EditorBars[sid][s][EBar_Color], mainHex);
	PBE_FormatRGBTag(EditorBars[sid][s][EBar_Color], mainTag);
	new alpha = EditorBars[sid][s][EBar_Color] & 0xFF;

	if (EditorBars[sid][s][EBar_BorderColor] == 0)
	{
		format(bdrDesc, sizeof bdrDesc, "{94A3B8}Auto-Darkened (0)");
	}
	else
	{
		new bHex[16], bTag[16];
		PBE_FormatHex(EditorBars[sid][s][EBar_BorderColor], bHex);
		PBE_FormatRGBTag(EditorBars[sid][s][EBar_BorderColor], bTag);
		format(bdrDesc, sizeof bdrDesc, "%s|||| {FFFFFF}%s", bTag, bHex);
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Color Channel\tActive Value\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Main Color - Preset Swatches\t%s|||| {FFFFFF}%s\n", mainTag, mainHex);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Main Color - Custom Hex RGBA\t{94A3B8}Enter 0xRRGGBBAA or #RRGGBB\n");
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Main Color - Opacity / Alpha\t{FFFFFF}%d / 255 (%d%%)\n", alpha, (alpha * 100) / 255);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Border Color - Preset Swatches\t%s\n", bdrDesc);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{F59E0B}Border Color - Custom Hex RGBA\t{94A3B8}Enter 0xRRGGBBAA or 0 for Auto\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Copy Theme from Another Layer\t{94A3B8}Clone main & border colors + border size\n", sizeof s_DlgBody);

	new gradTag[24], dirTag[64];
	PBE_OnOffTag(EditorBars[sid][s][EBar_Gradient], gradTag);
	if (EditorBars[sid][s][EBar_GradInvert])
	{
		format(dirTag, sizeof dirTag, "{EF4444}Inverted {94A3B8}(Low=Green -> High=Red)");
	}
	else
	{
		format(dirTag, sizeof dirTag, "{10B981}Standard {94A3B8}(Low=Red -> High=Green)");
	}
	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Dynamic Health Gradient\t%s\n", gradTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Gradient Direction / Polarity\t%s", dirTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_COLOR_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Color & Theme Designer", s_DlgBody, "Select", "Close");
}

static stock PBE_OpenAnimateMenu(playerid, sid)
{
	if (!PBE_HasActiveBar(sid))
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Active Layer: ", "Create or select a progress bar layer first.");
		PBE_SetCursor(playerid, sid, true);
		return;
	}

	new s = EditorSession[sid][EP_Selected];
	new afTag[24], blTag[24], afMaxDesc[64];
	PBE_OnOffTag(EditorBars[sid][s][EBar_AutoFill], afTag);
	PBE_OnOffTag(EditorBars[sid][s][EBar_Blinking], blTag);

	if (EditorBars[sid][s][EBar_AutoFillMax] <= 0.0) format(afMaxDesc, sizeof afMaxDesc, "Full Max (%.1f)", EditorBars[sid][s][EBar_Max]);
	else format(afMaxDesc, sizeof afMaxDesc, "%.2f", EditorBars[sid][s][EBar_AutoFillMax]);

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Value & Animation Control\tCurrent State\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Quick Value Presets (0%% - 100%%)\t{FFFFFF}%.2f / %.2f\n", EditorBars[sid][s][EBar_Val], EditorBars[sid][s][EBar_Max]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}Interactive Live Value Scrubber\t{94A3B8}Scrub fill level with WASD / Arrow keys\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Set Exact Current Value\t{94A3B8}%.2f\n", EditorBars[sid][s][EBar_Val]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Set Maximum Value Capacity\t{94A3B8}%.2f\n", EditorBars[sid][s][EBar_Max]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{FFFFFF}Set Minimum Value Floor\t{94A3B8}%.2f\n", EditorBars[sid][s][EBar_Min]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Toggle Auto-Fill Ping-Pong\t%s\n", afTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Set Auto-Fill Ceiling\t{FFFFFF}%s\n", afMaxDesc);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{EF4444}Blink & Alert Effect Designer\t%s {94A3B8}(%dms)\n", blTag, EditorBars[sid][s][EBar_BlinkInterval]);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{38BDF8}Smooth Value Lerp Preview (600ms)\t{94A3B8}Test smooth sliding value transition", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_ANIMATE_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Value, Auto-Fill & Blink", s_DlgBody, "Select", "Close");
}

static stock PBE_OpenBlinkMenu(playerid, sid)
{
	if (!PBE_HasActiveBar(sid)) return;
	new s = EditorSession[sid][EP_Selected];

	new blTag[24], cDesc[80], bcDesc[80], durDesc[64];
	PBE_OnOffTag(EditorBars[sid][s][EBar_Blinking], blTag);

	if (EditorBars[sid][s][EBar_BlinkDuration] <= 0) format(durDesc, sizeof durDesc, "Infinite (0)");
	else format(durDesc, sizeof durDesc, "%d ms", EditorBars[sid][s][EBar_BlinkDuration]);

	if (EditorBars[sid][s][EBar_BlinkColor] == 0) format(cDesc, sizeof cDesc, "{94A3B8}Classic Hide/Dim (0)");
	else
	{
		new hx[16], tg[16];
		PBE_FormatHex(EditorBars[sid][s][EBar_BlinkColor], hx);
		PBE_FormatRGBTag(EditorBars[sid][s][EBar_BlinkColor], tg);
		format(cDesc, sizeof cDesc, "%s|||| {FFFFFF}%s", tg, hx);
	}

	if (EditorBars[sid][s][EBar_BlinkBorderColor] == 0) format(bcDesc, sizeof bcDesc, "{94A3B8}Keep Static Border (0)");
	else
	{
		new bhx[16], btg[16];
		PBE_FormatHex(EditorBars[sid][s][EBar_BlinkBorderColor], bhx);
		PBE_FormatRGBTag(EditorBars[sid][s][EBar_BlinkBorderColor], btg);
		format(bcDesc, sizeof bcDesc, "%s|||| {FFFFFF}%s", btg, bhx);
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Blink Parameter\tCurrent Setting\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}Toggle Blink Effect\t%s\n", blTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Interval & Duration\t{FFFFFF}%d ms  |  %s\n", EditorBars[sid][s][EBar_BlinkInterval], durDesc);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Phase-B Fill Color (Palette)\t%s\n", cDesc);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{F59E0B}Phase-B Fill Color (Custom Hex)\t{94A3B8}Enter 0xRRGGBBAA or 0\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{EF4444}Phase-B Border Color (Palette)\t%s\n", bcDesc);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{EF4444}Phase-B Border Color (Custom Hex)\t{94A3B8}Enter 0xRRGGBBAA or 0", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_BLINK_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{EF4444}PB Editor {FFFFFF}- Blink Effect Designer", s_DlgBody, "Select", "Back");
}

static stock PBE_OpenToolsMenu(playerid, sid)
{
	new undoStr[128];
	if (EditorUndoMeta[sid][EUndo_Available])
	{
		format(undoStr, sizeof undoStr, "{10B981}Revert: %s", EditorUndoMeta[sid][EUndo_Desc]);
	}
	else
	{
		format(undoStr, sizeof undoStr, "{94A3B8}Nothing to undo");
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Precision Layout Tool\tDescription\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Undo Last Workspace Action\t%s\n", undoStr);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{38BDF8}Center Horizontally on Screen\t{94A3B8}Align active bar X to 320.0 center\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Center Vertically on Screen\t{94A3B8}Align active bar Y to 224.0 center\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}True Screen Center (X & Y)\t{94A3B8}Place active bar dead-center on screen\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}GTA:SA HUD Anchor Presets\t{94A3B8}Snap to Health, Armour, Money, Radar or Speedo\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Relative Multi-Bar Align & Stack\t{94A3B8}Align edges, match sizes, or stack with pixel gap\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Apply 16:9 Perfect Circle Ratio\t{94A3B8}Set Height = Width * 1.25 for round Rings/Circles\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}Round Coords & Size to Integers\t{94A3B8}Snap X, Y, Width, Height to clean 1.0px values", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_TOOLS_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- Precision Alignment & Tools", s_DlgBody, "Apply", "Close");
}

static stock PBE_OpenGTAAnchorsMenu(playerid)
{
	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "GTA:SA HUD Anchor Preset\tCoordinates & Size\n", sizeof s_DlgBody);

	new stShort[16];
	for (new i = 0; i < sizeof(g_PBEAnchors); i++)
	{
		PBE_GetStyleShort(g_PBEAnchors[i][Anchor_Style], stShort);
		format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}%s\t{94A3B8}[%s]  X:%.1f Y:%.1f  (%.1fx%.1f)\n",
			g_PBEAnchors[i][Anchor_Name],
			stShort,
			g_PBEAnchors[i][Anchor_X],
			g_PBEAnchors[i][Anchor_Y],
			g_PBEAnchors[i][Anchor_W],
			g_PBEAnchors[i][Anchor_H]
		);
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}

	PBE_ShowDialog(playerid, PBE_DLG_GTA_ANCHORS, DIALOG_STYLE_TABLIST_HEADERS, "{10B981}PB Editor {FFFFFF}- GTA:SA Native HUD Anchors", s_DlgBody, "Snap", "Back");
}

static stock PBE_OpenRelTargetPicker(playerid, sid)
{
	if (!PBE_HasActiveBar(sid) || EditorSession[sid][EP_BarCount] < 2)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Need 2+ Layers: ", "Relative alignment requires at least two progress bar layers.");
		PBE_OpenToolsMenu(playerid, sid);
		return;
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Reference Layer\tPosition & Dimensions\n", sizeof s_DlgBody);

	new activeSlot = EditorSession[sid][EP_Selected];
	for (new i = 0; i < EditorSession[sid][EP_BarCount]; i++)
	{
		if (i == activeSlot) continue;
		format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}#%d %s\t{94A3B8}X:%.1f Y:%.1f  (%.1fx%.1f)\n",
			i + 1,
			EditorBars[sid][i][EBar_Name],
			EditorBars[sid][i][EBar_X],
			EditorBars[sid][i][EBar_Y],
			EditorBars[sid][i][EBar_W],
			EditorBars[sid][i][EBar_H]
		);
		strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
	}

	PBE_ShowDialog(playerid, PBE_DLG_REL_TARGET_PICK, DIALOG_STYLE_TABLIST_HEADERS, "{F59E0B}PB Editor {FFFFFF}- Select Reference Layer", s_DlgBody, "Next", "Back");
}

static stock PBE_OpenRelActionPicker(playerid, sid)
{
	new ref = EditorSession[sid][EP_RelTargetSlot];
	if (!(0 <= ref < EditorSession[sid][EP_BarCount]))
	{
		PBE_OpenToolsMenu(playerid, sid);
		return;
	}

	new title[192];
	format(title, sizeof title, "{F59E0B}Align Active Bar {FFFFFF}-> #%d %s", ref + 1, EditorBars[sid][ref][EBar_Name]);

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Alignment / Distribution Operation\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Align Left Edges (X = Ref.X)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Align Right Edges (X + W = Ref.X + Ref.W)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Align Top Edges (Y = Ref.Y)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Align Bottom Edges (Y + H = Ref.Y + Ref.H)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Align Horizontal Centers\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}Align Vertical Centers\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Match Reference Width\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Match Reference Height\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{10B981}Match Both Width & Height\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Stack Directly Below Reference (Custom Gap...)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Stack Directly Above Reference (Custom Gap...)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Stack to the Right of Reference (Custom Gap...)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{F59E0B}Stack to the Left of Reference (Custom Gap...)", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_REL_ACTION_PICK, DIALOG_STYLE_TABLIST_HEADERS, title, s_DlgBody, "Apply", "Back");
}

static stock PBE_OpenViewMenu(playerid, sid)
{
	new dockTag[32], gridTag[32], snapTag[48], lockTag[32];
	if (EditorSession[sid][EP_DockPos] == PBE_DOCK_TOP) format(dockTag, sizeof dockTag, "{38BDF8}TOP");
	else format(dockTag, sizeof dockTag, "{38BDF8}BOTTOM");

	PBE_OnOffTag(EditorSession[sid][EP_ShowGrid], gridTag);
	PBE_OnOffTag(EditorSession[sid][EP_AspectLock], lockTag);

	switch (EditorSession[sid][EP_GridSnapMode])
	{
		case 1:  format(snapTag, sizeof snapTag, "{10B981}1.0 px");
		case 2:  format(snapTag, sizeof snapTag, "{F59E0B}5.0 px");
		default: format(snapTag, sizeof snapTag, "{94A3B8}OFF (Free)");
	}

	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "Workspace & View Option\tCurrent State\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Flip Editor Dock Position\t%s\n", dockTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}Fullscreen Clean HUD Preview\t{94A3B8}Minimize Dock to top 'EDITOR UI' pill\n", sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}Alignment Crosshair & Thirds Grid\t%s\n", gridTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{F59E0B}Movement Grid Snapping\t%s\n", snapTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	format(s_DlgRow, sizeof s_DlgRow, "{10B981}16:9 Circle Aspect Ratio Lock (Rings/Circles)\t%s\n", lockTag);
	strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);

	strcat(s_DlgBody, "{FFFFFF}Editor Controls & Quick Reference\t{94A3B8}View hotkeys, folders & commands\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{EF4444}Exit Progress Bar Plus - Editor\t{94A3B8}Close editor and clean up session", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_VIEW_MENU, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}PB Editor {FFFFFF}- View, Preferences & Exit", s_DlgBody, "Select", "Close");
}

static stock PBE_OpenHelpGuide(playerid)
{
	s_DlgBody[0] = '\0';
	strcat(s_DlgBody, "{38BDF8}Progress Bar Plus - Editor v" PBE_VERSION "\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{94A3B8}----------------------------------------------------------------------\n\n", sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}1. Interactive Editor Cursor & Free-Walk Mode\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - Click any button on the {38BDF8}Editor Dock{FFFFFF} to create, style, animate, or export bars.\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - Press {F59E0B}ESC{FFFFFF} anytime to pause the cursor and test your HUD while walking/driving.\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - Press {38BDF8}Y{FFFFFF} (or type {38BDF8}/pbselect{FFFFFF}) anytime to bring the Editor Cursor right back!\n\n", sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}2. Real-Time Move, Resize & Scrub Hotkeys\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - {38BDF8}W/A/S/D{FFFFFF} or {38BDF8}Arrow Keys{FFFFFF}: Adjust position, dimensions, border, or value.\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - Hold {F59E0B}SHIFT{FFFFFF} or {F59E0B}CTRL{FFFFFF} for 5x fast movement  |  Hold {F59E0B}ALT{FFFFFF} for 0.1px fine precision.\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - Press {38BDF8}C{FFFFFF} during Move to cycle Grid Snap, or during Ring/Circle Resize to lock {10B981}16:9 Circle Ratio{FFFFFF}.\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - Press {10B981}F / ENTER{FFFFFF} to Save changes, or {EF4444}N{FFFFFF} to Cancel and revert.\n\n", sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}3. Organized File Hierarchy (scriptfiles/Progress Bars/)\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - {38BDF8}Projects/{FFFFFF}   Saved multi-bar editor workspaces ({94A3B8}.pbp{FFFFFF})\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - {38BDF8}Templates/{FFFFFF}  Reusable single-bar presets ({94A3B8}.pbt{FFFFFF})\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - {38BDF8}Imports/{FFFFFF}    Drop existing {94A3B8}.pwn / .inc / .txt / .pbp{FFFFFF} files here to import\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{FFFFFF}  - {38BDF8}Exports/{FFFFFF}    Generated production-ready {94A3B8}.pwn / .inc / _raw.txt{FFFFFF} code\n\n", sizeof s_DlgBody);

	strcat(s_DlgBody, "{10B981}4. Pawn.CMD Quick Commands\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}  /pbeditor (/pbe)  /pbselect  /pbnew  /pbload  /pbsave\n", sizeof s_DlgBody);
	strcat(s_DlgBody, "{38BDF8}  /pbimport  /pbexport  /pbadd  /pbpreview  /pbundo  /pblock  /pbexit", sizeof s_DlgBody);

	PBE_ShowDialog(playerid, PBE_DLG_HELP_GUIDE, DIALOG_STYLE_MSGBOX, "{38BDF8}Progress Bar Plus - Editor {FFFFFF}| Reference Manual", s_DlgBody, "Got It", "");
}

/*
================================================================================
    9. Editor Session Lifecycle & Multi-Bar Alignment Helpers
================================================================================
*/

static stock PBE_MapOtherLayerListitem(sid, listitem)
{
	new activeSlot = EditorSession[sid][EP_Selected];
	new seen = 0;
	for (new i = 0; i < EditorSession[sid][EP_BarCount]; i++)
	{
		if (i == activeSlot) continue;
		if (seen == listitem) return i;
		seen++;
	}
	return -1;
}

static stock PBE_ApplyRelativeAlignment(playerid, sid, action, Float:gap = 4.0)
{
	if (!PBE_HasActiveBar(sid)) return;
	new s = EditorSession[sid][EP_Selected];
	new ref = EditorSession[sid][EP_RelTargetSlot];
	if (!(0 <= ref < EditorSession[sid][EP_BarCount]) || ref == s || !EditorBars[sid][ref][EBar_Used]) return;

	PBE_SaveUndo(sid, "Relative Align/Stack");

	switch (action)
	{
		case 0: EditorBars[sid][s][EBar_X] = EditorBars[sid][ref][EBar_X];
		case 1: EditorBars[sid][s][EBar_X] = (EditorBars[sid][ref][EBar_X] + EditorBars[sid][ref][EBar_W]) - EditorBars[sid][s][EBar_W];
		case 2: EditorBars[sid][s][EBar_Y] = EditorBars[sid][ref][EBar_Y];
		case 3: EditorBars[sid][s][EBar_Y] = (EditorBars[sid][ref][EBar_Y] + EditorBars[sid][ref][EBar_H]) - EditorBars[sid][s][EBar_H];
		case 4: EditorBars[sid][s][EBar_X] = EditorBars[sid][ref][EBar_X] + (EditorBars[sid][ref][EBar_W] - EditorBars[sid][s][EBar_W]) * 0.5;
		case 5: EditorBars[sid][s][EBar_Y] = EditorBars[sid][ref][EBar_Y] + (EditorBars[sid][ref][EBar_H] - EditorBars[sid][s][EBar_H]) * 0.5;
		case 6: EditorBars[sid][s][EBar_W] = EditorBars[sid][ref][EBar_W];
		case 7: EditorBars[sid][s][EBar_H] = EditorBars[sid][ref][EBar_H];
		case 8:
		{
			EditorBars[sid][s][EBar_W] = EditorBars[sid][ref][EBar_W];
			EditorBars[sid][s][EBar_H] = EditorBars[sid][ref][EBar_H];
		}
		case 9:
		{
			EditorBars[sid][s][EBar_X] = EditorBars[sid][ref][EBar_X];
			EditorBars[sid][s][EBar_Y] = EditorBars[sid][ref][EBar_Y] + EditorBars[sid][ref][EBar_H] + gap;
		}
		case 10:
		{
			EditorBars[sid][s][EBar_X] = EditorBars[sid][ref][EBar_X];
			EditorBars[sid][s][EBar_Y] = EditorBars[sid][ref][EBar_Y] - EditorBars[sid][s][EBar_H] - gap;
		}
		case 11:
		{
			EditorBars[sid][s][EBar_X] = EditorBars[sid][ref][EBar_X] + EditorBars[sid][ref][EBar_W] + gap;
			EditorBars[sid][s][EBar_Y] = EditorBars[sid][ref][EBar_Y];
		}
		case 12:
		{
			EditorBars[sid][s][EBar_X] = EditorBars[sid][ref][EBar_X] - EditorBars[sid][s][EBar_W] - gap;
			EditorBars[sid][s][EBar_Y] = EditorBars[sid][ref][EBar_Y];
		}
	}

	EditorSession[sid][EP_Dirty] = true;
	new h = EditorBars[sid][s][EBar_Handle];
	if (IsValidPlayerProgressBar(playerid, h))
	{
		SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
		SetPlayerProgressBarSize(playerid, h, EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
	}
	PBE_RefreshStatusHUD(playerid, sid);
}

static stock bool:PBE_OpenEditorSession(playerid)
{
	if (!PBE_CheckAccess(playerid)) return false;

	new existing = PBE_GetSlot(playerid);
	if (existing != PBE_INVALID_SESSION)
	{
		if (EditorSession[existing][EP_EditMode] != PBE_MODE_NONE)
		{
			PBE_StopTransformMode(playerid, existing, false, false);
		}
		if (EditorSession[existing][EP_DockPos] == PBE_DOCK_HIDDEN)
		{
			EditorSession[existing][EP_DockPos] = PBE_DOCK_BOTTOM;
		}
		PBE_RenderEditorDock(playerid, existing);
		PBE_SetCursor(playerid, existing, true);
		PBE_SendMsg(playerid, PBE_CHAT_BRAND, "", "Editor Dock & Cursor restored. Press {38BDF8}ESC{FFFFFF} to walk freely or {38BDF8}Y{FFFFFF} to recall cursor.");
		return true;
	}

	new sid = PBE_AllocSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Session Pool Full: ", "All concurrent editor session slots are currently occupied.");
		return false;
	}

	EditorSession[sid][EP_CursorOn]        = false;
	EditorSession[sid][EP_SuppressCancel]  = false;
	EditorSession[sid][EP_Dirty]           = true;
	EditorSession[sid][EP_ShowGrid]        = false;
	EditorSession[sid][EP_AspectLock]      = false;
	EditorSession[sid][EP_GridSnapMode]    = 0;
	EditorSession[sid][EP_DockPos]         = PBE_DOCK_BOTTOM;
	EditorSession[sid][EP_EditMode]        = PBE_MODE_NONE;
	EditorSession[sid][EP_Timer]           = 0;
	EditorSession[sid][EP_Selected]        = -1;
	EditorSession[sid][EP_BarCount]        = 0;
	EditorSession[sid][EP_ExportFormat]    = PBE_EXP_GAMEMODE_PWN;
	EditorSession[sid][EP_RelTargetSlot]   = -1;
	EditorSession[sid][EP_RelPendingAct]   = 0;
	EditorSession[sid][EP_DeleteTargetIdx] = -1;
	EditorSession[sid][EP_LastRingRebuild] = 0;
	EditorSession[sid][EP_TDStatus]        = PBE_NO_TD;
	EditorSession[sid][EP_TDHelper]        = PBE_NO_TD;
	PBE_MakeUniqueBlankName(sid, EditorSession[sid][EP_ProjectName], PBE_MAX_PROJECT_NAME);

	EditorUndoMeta[sid][EUndo_Available] = false;
	for (new i = 0; i < PBE_MAX_BARS; i++)
	{
		EditorBars[sid][i][EBar_Used]   = false;
		EditorBars[sid][i][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	}

	PBE_RenderEditorDock(playerid, sid);
	PBE_SetCursor(playerid, sid, true);

	PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Editor Ready: ", "Welcome to {38BDF8}Progress Bar Plus - Editor v" PBE_VERSION "{FFFFFF}!");
	PBE_SendMsg(playerid, PBE_CHAT_INFO, "", "Use {38BDF8}+ CREATE{FFFFFF} to add, {38BDF8}PROJECT{FFFFFF} to open/save, or {F59E0B}ESC / Y{FFFFFF} for cursor.");
	return true;
}

static stock PBE_CloseEditorSession(playerid, sid, bool:disconnecting = false)
{
	if (!(0 <= sid < PBE_MAX_SESSIONS) || !EditorSession[sid][EP_Active]) return;

	PBE_KillTransformTimer(sid);

	if (!disconnecting && IsPlayerConnected(playerid))
	{
		if (EditorSession[sid][EP_EditMode] != PBE_MODE_NONE)
		{
			TogglePlayerControllable(playerid, PBE_TD_BOOL(true));
		}
		PBE_SetCursor(playerid, sid, false);
		PBE_DestroyAllSlotHandles(playerid, sid);

		EditorSession[sid][EP_ShowGrid] = false;
		PBE_UpdateGridVisibility(playerid, sid);
		PBE_HideAllDockTDs(playerid, sid);
	}

	PBE_KillGlobalTD(EditorSession[sid][EP_TDStatus]);
	PBE_KillGlobalTD(EditorSession[sid][EP_TDHelper]);

	EditorSession[sid][EP_Active]    = false;
	EditorSession[sid][EP_PlayerID]  = INVALID_PLAYER_ID;
	EditorSession[sid][EP_CursorOn]  = false;
	EditorSession[sid][EP_EditMode]  = PBE_MODE_NONE;
	EditorSession[sid][EP_BarCount]  = 0;
	EditorSession[sid][EP_Selected]  = -1;
	EditorSession[sid][EP_TDStatus] = PBE_NO_TD;
	EditorSession[sid][EP_TDHelper] = PBE_NO_TD;
	EditorUndoMeta[sid][EUndo_Available] = false;

	for (new i = 0; i < PBE_MAX_BARS; i++)
	{
		EditorBars[sid][i][EBar_Used]   = false;
		EditorBars[sid][i][EBar_Handle] = INVALID_PLAYER_BAR_ID;
	}

	if (0 <= playerid < MAX_PLAYERS)
	{
		g_PlayerSession[playerid] = PBE_INVALID_SESSION;
	}
}

/*
================================================================================
    10. SA-MP & open.mp Filterscript Callbacks
================================================================================
*/

public OnFilterScriptInit()
{
	for (new p = 0; p < MAX_PLAYERS; p++)
	{
		g_PlayerSession[p]  = PBE_INVALID_SESSION;
		g_PlayerWelcomed[p] = false;
	}
	for (new s = 0; s < PBE_MAX_SESSIONS; s++)
	{
		EditorSession[s][EP_Active]    = false;
		EditorSession[s][EP_PlayerID]  = INVALID_PLAYER_ID;
		EditorSession[s][EP_TDStatus] = PBE_NO_TD;
		EditorSession[s][EP_TDHelper] = PBE_NO_TD;
		for (new b = 0; b < PBE_MAX_BARS; b++)
		{
			EditorBars[s][b][EBar_Used]   = false;
			EditorBars[s][b][EBar_Handle] = INVALID_PLAYER_BAR_ID;
		}
	}

	PBE_InitGlobalEditorUI();

	print("======================================================================");
	print("  Progress Bar Plus - Editor v" PBE_VERSION " loaded!");
	print("  Author: Walter Correa | Commands: /pbeditor (/pbe), /pbhelp");
	print("  Workspace Directory: scriptfiles/Progress Bars/");
	print("  Repository: https://github.com/Walter-Correa/Progress-Bar-Plus");
	print("======================================================================");
	return 1;
}

public OnFilterScriptExit()
{
	for (new s = 0; s < PBE_MAX_SESSIONS; s++)
	{
		if (EditorSession[s][EP_Active])
		{
			new pid = EditorSession[s][EP_PlayerID];
			PBE_CloseEditorSession(pid, s, false);
		}
	}
	PBE_DestroyGlobalEditorUI();
	print("  Progress Bar Plus - Editor v" PBE_VERSION " unloaded.");
	return 1;
}

public OnPlayerConnect(playerid)
{
	if (0 <= playerid < MAX_PLAYERS)
	{
		g_PlayerSession[playerid]  = PBE_INVALID_SESSION;
		g_PlayerWelcomed[playerid] = false;
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if (0 <= playerid < MAX_PLAYERS && !g_PlayerWelcomed[playerid])
	{
		g_PlayerWelcomed[playerid] = true;
		if (!g_PBERconLocked || IsPlayerAdmin(playerid))
		{
			PBE_SendMsg(playerid, PBE_CHAT_BRAND, "", "Welcome to {38BDF8}Progress Bar Plus - Editor{FFFFFF}! Type {10B981}/pbeditor (/pbe){FFFFFF} to open.");
		}
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	if (0 <= playerid < MAX_PLAYERS)
	{
		g_PlayerWelcomed[playerid] = false;
	}
	new sid = PBE_GetSlot(playerid);
	if (sid != PBE_INVALID_SESSION)
	{
		PBE_CloseEditorSession(playerid, sid, true);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, PBE_KEY_TAG newkeys, PBE_KEY_TAG oldkeys)
{
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION) return 1;

	new mode = EditorSession[sid][EP_EditMode];
	if (mode != PBE_MODE_NONE)
	{
		if ((_:newkeys & _:KEY_SECONDARY_ATTACK) && !(_:oldkeys & _:KEY_SECONDARY_ATTACK))
		{
			PBE_StopTransformMode(playerid, sid, false, true);
			PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Saved: ", "Transform applied. Returned to Editor Cursor.");
			return 1;
		}
		if ((_:newkeys & _:KEY_NO) && !(_:oldkeys & _:KEY_NO))
		{
			PBE_StopTransformMode(playerid, sid, true, true);
			PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Cancelled: ", "Transform reverted to previous state.");
			return 1;
		}
		if ((_:newkeys & _:KEY_CROUCH) && !(_:oldkeys & _:KEY_CROUCH))
		{
			if (mode == PBE_MODE_MOVE)
			{
				EditorSession[sid][EP_GridSnapMode] = (EditorSession[sid][EP_GridSnapMode] + 1) % 3;
				if (PBE_HasActiveBar(sid))
				{
					new s = EditorSession[sid][EP_Selected];
					if (EditorSession[sid][EP_GridSnapMode] != 0)
					{
						EditorBars[sid][s][EBar_X] = PBE_SnapValue(EditorBars[sid][s][EBar_X], EditorSession[sid][EP_GridSnapMode]);
						EditorBars[sid][s][EBar_Y] = PBE_SnapValue(EditorBars[sid][s][EBar_Y], EditorSession[sid][EP_GridSnapMode]);
						if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
						{
							SetPlayerProgressBarPos(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
						}
					}
					EditorSession[sid][EP_RawX] = EditorBars[sid][s][EBar_X];
					EditorSession[sid][EP_RawY] = EditorBars[sid][s][EBar_Y];
				}
				PBE_RefreshStatusHUD(playerid, sid);
			}
			else if (mode == PBE_MODE_RESIZE && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (EditorBars[sid][s][EBar_Style] != PB_STYLE_BAR)
				{
					EditorSession[sid][EP_AspectLock] = !EditorSession[sid][EP_AspectLock];
					if (EditorSession[sid][EP_AspectLock])
					{
						new Float:maxW = 448.0 / PB_BORDER_Y_RATIO;
						if (EditorBars[sid][s][EBar_W] > maxW) EditorBars[sid][s][EBar_W] = maxW;
						EditorBars[sid][s][EBar_H] = EditorBars[sid][s][EBar_W] * PB_BORDER_Y_RATIO;
						if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
						{
							SetPlayerProgressBarSize(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
						}
					}
					PBE_RefreshStatusHUD(playerid, sid);
				}
			}
			return 1;
		}
		return 1;
	}

	if ((_:newkeys & _:KEY_YES) && !(_:oldkeys & _:KEY_YES))
	{
		if (!EditorSession[sid][EP_CursorOn])
		{
			PBE_SetCursor(playerid, sid, true);
		}
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION) return 0;

	if (clickedid == PBE_NO_TD)
	{
		if (EditorSession[sid][EP_SuppressCancel])
		{
			EditorSession[sid][EP_SuppressCancel] = false;
			return 1;
		}
		if (EditorSession[sid][EP_CursorOn])
		{
			EditorSession[sid][EP_CursorOn] = false;
			PBE_SendMsg(playerid, PBE_CHAT_INFO, "{94A3B8}Free-Walk: ", "Cursor paused. Press {38BDF8}Y{FFFFFF} or type {38BDF8}/pbselect{FFFFFF} to recall cursor.");
			return 1;
		}
		return 0;
	}

	if (clickedid == g_TD_MiniPillBg && g_TD_MiniPillBg != PBE_NO_TD)
	{
		EditorSession[sid][EP_DockPos] = PBE_DOCK_BOTTOM;
		PBE_RenderEditorDock(playerid, sid);
		PBE_SetCursor(playerid, sid, true);
		return 1;
	}

	for (new d = 0; d < 2; d++)
	{
		for (new b = 0; b < PBE_DOCK_BUTTONS; b++)
		{
			if (g_TD_DockBtn[d][b] != PBE_NO_TD && clickedid == g_TD_DockBtn[d][b])
			{
				switch (b)
				{
					case 0:  PBE_OpenProjectMenu(playerid, sid);
					case 1:  PBE_OpenCreateMenu(playerid, sid);
					case 2:  PBE_OpenLayersMenu(playerid, sid);
					case 3:  PBE_StartTransformMode(playerid, sid, PBE_MODE_MOVE);
					case 4:  PBE_StartTransformMode(playerid, sid, PBE_MODE_RESIZE);
					case 5:  PBE_OpenStyleMenu(playerid, sid);
					case 6:  PBE_OpenColorMenu(playerid, sid);
					case 7:  PBE_OpenAnimateMenu(playerid, sid);
					case 8:  PBE_OpenToolsMenu(playerid, sid);
					case 9:  PBE_OpenExportMenu(playerid, sid);
					case 10: PBE_OpenViewMenu(playerid, sid);
				}
				return 1;
			}
		}
	}
	return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid < PBE_DIALOG_BASE || dialogid >= PBE_DIALOG_END) return 0;

	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION) return 1;

	switch (dialogid)
	{
		// --------------------------------------------------------------------
		// Project Management & File I/O
		// --------------------------------------------------------------------
		case PBE_DLG_PROJECT_MENU:
		{
			if (!response)
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			switch (listitem)
			{
				case 0:
				{
					if (EditorSession[sid][EP_Dirty] && EditorSession[sid][EP_BarCount] > 0)
					{
						PBE_ShowDialog(playerid, PBE_DLG_NEW_CONFIRM, DIALOG_STYLE_MSGBOX,
							"{F59E0B}Unsaved Workspace Changes",
							"{FFFFFF}Your current project has unsaved modifications.\nAre you sure you want to discard them and start a new project?",
							"Discard", "Cancel");
					}
					else
					{
						PBE_ShowDialog(playerid, PBE_DLG_NEW_NAME, DIALOG_STYLE_INPUT,
							"{38BDF8}New Editor Project",
							"{FFFFFF}Enter a name for your new HUD project (letters, numbers, spaces, _ or -):",
							"Create", "Back");
					}
				}
				case 1: PBE_OpenLoadProjectBrowser(playerid, sid, false);
				case 2:
				{
					if (PBE_CheckProjectLocked(playerid, sid, EditorSession[sid][EP_ProjectName]))
					{
						PBE_SetCursor(playerid, sid, true);
						return 1;
					}
					if (PBE_SaveProjectFile(playerid, sid, EditorSession[sid][EP_ProjectName]))
					{
						new msg[256];
						format(msg, sizeof msg, "Saved {38BDF8}%s%s.pbp{FFFFFF} (%d bars).", PBE_DIR_PROJECTS, EditorSession[sid][EP_ProjectName], EditorSession[sid][EP_BarCount]);
						PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Project Saved: ", msg);
					}
					else
					{
						PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Save Failed: ", "Ensure folder 'scriptfiles/Progress Bars/Projects/' exists!");
					}
					PBE_SetCursor(playerid, sid, true);
				}
				case 3:
				{
					PBE_ShowDialog(playerid, PBE_DLG_SAVE_AS, DIALOG_STYLE_INPUT,
						"{10B981}Save Project As (.pbp)",
						"{FFFFFF}Enter the filename for this project (saved inside {38BDF8}scriptfiles/Progress Bars/Projects/{FFFFFF}):",
						"Save", "Back");
				}
				case 4: PBE_OpenImportMenu(playerid);
				case 5: PBE_OpenExportMenu(playerid, sid);
				case 6: PBE_OpenLoadProjectBrowser(playerid, sid, true);
			}
			return 1;
		}

		case PBE_DLG_NEW_CONFIRM:
		{
			if (!response)
			{
				PBE_OpenProjectMenu(playerid, sid);
				return 1;
			}
			PBE_ShowDialog(playerid, PBE_DLG_NEW_NAME, DIALOG_STYLE_INPUT,
				"{38BDF8}New Editor Project",
				"{FFFFFF}Enter a name for your new HUD project:",
				"Create", "Back");
			return 1;
		}

		case PBE_DLG_NEW_NAME:
		{
			if (!response)
			{
				PBE_OpenProjectMenu(playerid, sid);
				return 1;
			}
			new clean[PBE_MAX_PROJECT_NAME];
			PBE_NormalizeProjectName(inputtext, clean, sizeof clean);
			if (clean[0] == '\0')
			{
				PBE_MakeUniqueBlankName(sid, clean, sizeof clean);
			}
			else if (PBE_CheckProjectLocked(playerid, sid, clean))
			{
				PBE_ShowDialog(playerid, PBE_DLG_NEW_NAME, DIALOG_STYLE_INPUT,
					"{38BDF8}New Editor Project",
					"{EF4444}That project name is currently open by another player.{FFFFFF}\nEnter a different name for your new HUD project:",
					"Create", "Back");
				return 1;
			}

			PBE_ClearWorkspace(playerid, sid, clean);
			PBE_RenderEditorDock(playerid, sid);
			PBE_SetCursor(playerid, sid, true);

			new msg[256];
			format(msg, sizeof msg, "Created blank workspace project {38BDF8}%s{FFFFFF}.", clean);
			PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}New Project: ", msg);
			return 1;
		}

		case PBE_DLG_LOAD_LIST:
		{
			if (!response)
			{
				PBE_OpenProjectMenu(playerid, sid);
				return 1;
			}
			if (listitem == 0)
			{
				PBE_ShowDialog(playerid, PBE_DLG_LOAD_DIRECT, DIALOG_STYLE_INPUT,
					"{38BDF8}Open Project by Filename",
					"{FFFFFF}Enter the project name inside {38BDF8}scriptfiles/Progress Bars/Projects/{FFFFFF} (without .pbp):",
					"Open", "Back");
				return 1;
			}
			new idx = listitem - 1;
			if (0 <= idx < g_PBEBrowserCount[sid])
			{
				if (PBE_CheckProjectLocked(playerid, sid, g_PBEBrowserCache[sid][idx]))
				{
					PBE_OpenLoadProjectBrowser(playerid, sid, false);
					return 1;
				}
				if (PBE_LoadProjectFile(playerid, sid, PBE_DIR_PROJECTS, g_PBEBrowserCache[sid][idx], false))
				{
					new msg[256];
					format(msg, sizeof msg, "Loaded project {38BDF8}%s{FFFFFF} (%d bar layers).", EditorSession[sid][EP_ProjectName], EditorSession[sid][EP_BarCount]);
					PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Project Opened: ", msg);
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Load Failed: ", "Project file could not be read from disk.");
				}
			}
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		case PBE_DLG_LOAD_DIRECT:
		{
			if (!response)
			{
				PBE_OpenLoadProjectBrowser(playerid, sid, false);
				return 1;
			}
			if (PBE_CheckProjectLocked(playerid, sid, inputtext))
			{
				PBE_OpenLoadProjectBrowser(playerid, sid, false);
				return 1;
			}
			if (PBE_LoadProjectFile(playerid, sid, PBE_DIR_PROJECTS, inputtext, false))
			{
				new msg[256];
				format(msg, sizeof msg, "Loaded project {38BDF8}%s{FFFFFF} (%d bar layers).", EditorSession[sid][EP_ProjectName], EditorSession[sid][EP_BarCount]);
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Project Opened: ", msg);
				PBE_SetCursor(playerid, sid, true);
			}
			else
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}File Not Found: ", "No matching .pbp project exists in 'scriptfiles/Progress Bars/Projects/'.");
				PBE_OpenLoadProjectBrowser(playerid, sid, false);
			}
			return 1;
		}

		case PBE_DLG_SAVE_AS:
		{
			if (!response)
			{
				PBE_OpenProjectMenu(playerid, sid);
				return 1;
			}
			if (PBE_CheckProjectLocked(playerid, sid, inputtext))
			{
				PBE_ShowDialog(playerid, PBE_DLG_SAVE_AS, DIALOG_STYLE_INPUT,
					"{10B981}Save Project As (.pbp)",
					"{EF4444}That project is currently open by another player.{FFFFFF}\nEnter a different filename for this project:",
					"Save", "Back");
				return 1;
			}
			if (PBE_SaveProjectFile(playerid, sid, inputtext))
			{
				new msg[256];
				format(msg, sizeof msg, "Project saved to {38BDF8}%s%s.pbp{FFFFFF}.", PBE_DIR_PROJECTS, EditorSession[sid][EP_ProjectName]);
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Saved As: ", msg);
				PBE_SetCursor(playerid, sid, true);
			}
			else
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Save Failed: ", "Invalid project name or missing 'scriptfiles/Progress Bars/Projects/' folder.");
				PBE_OpenProjectMenu(playerid, sid);
			}
			return 1;
		}

		case PBE_DLG_DELETE_PROJ_LIST:
		{
			if (!response || !(0 <= listitem < g_PBEBrowserCount[sid]))
			{
				PBE_OpenProjectMenu(playerid, sid);
				return 1;
			}
			if (PBE_CheckProjectLocked(playerid, sid, g_PBEBrowserCache[sid][listitem]))
			{
				PBE_OpenLoadProjectBrowser(playerid, sid, true);
				return 1;
			}
			EditorSession[sid][EP_DeleteTargetIdx] = listitem;
			format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Are you sure you want to permanently delete project {EF4444}%s.pbp{FFFFFF}?", g_PBEBrowserCache[sid][listitem]);
			PBE_ShowDialog(playerid, PBE_DLG_DELETE_PROJ_CONF, DIALOG_STYLE_MSGBOX, "{EF4444}Confirm Project Deletion", s_DlgBody, "Delete", "Cancel");
			return 1;
		}

		case PBE_DLG_DELETE_PROJ_CONF:
		{
			new idx = EditorSession[sid][EP_DeleteTargetIdx];
			if (response && 0 <= idx < g_PBEBrowserCount[sid])
			{
				if (PBE_CheckProjectLocked(playerid, sid, g_PBEBrowserCache[sid][idx]))
				{
					PBE_OpenProjectMenu(playerid, sid);
					return 1;
				}
				new delPath[PBE_MAX_PATH];
				format(delPath, sizeof delPath, "%s%s.pbp", PBE_DIR_PROJECTS, g_PBEBrowserCache[sid][idx]);
				if (fexist(delPath)) fremove(delPath);
				PBE_RemoveIndexEntry(PBE_PROJECT_INDEX, PBE_DIR_PROJECTS, ".pbp", g_PBEBrowserCache[sid][idx]);

				new msg[256];
				format(msg, sizeof msg, "Removed {EF4444}%s.pbp{FFFFFF} from disk.", g_PBEBrowserCache[sid][idx]);
				PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Project Deleted: ", msg);
			}
			PBE_OpenProjectMenu(playerid, sid);
			return 1;
		}

		// --------------------------------------------------------------------
		// Universal Import & Code Export
		// --------------------------------------------------------------------
		case PBE_DLG_IMPORT_MENU:
		{
			if (!response)
			{
				PBE_OpenProjectMenu(playerid, sid);
				return 1;
			}
			switch (listitem)
			{
				case 0:
				{
					PBE_ShowDialog(playerid, PBE_DLG_IMPORT_PBP_OPEN, DIALOG_STYLE_INPUT,
						"{38BDF8}Open .pbp from Imports/",
						"{FFFFFF}Enter the .pbp filename placed in {38BDF8}scriptfiles/Progress Bars/Imports/{FFFFFF}:",
						"Open", "Back");
				}
				case 1:
				{
					PBE_ShowDialog(playerid, PBE_DLG_IMPORT_PBP_MERGE, DIALOG_STYLE_INPUT,
						"{10B981}Merge .pbp Layers into Current Project",
						"{FFFFFF}Enter the .pbp project name (from {38BDF8}Projects/{FFFFFF} or {38BDF8}Imports/{FFFFFF}) to append into your active workspace:",
						"Merge", "Back");
				}
				case 2:
				{
					PBE_ShowDialog(playerid, PBE_DLG_IMPORT_CODE_FILE, DIALOG_STYLE_INPUT,
						"{F59E0B}Import Pawn Source Code File",
						"{FFFFFF}Enter the filename inside {38BDF8}scriptfiles/Progress Bars/Imports/{FFFFFF} (e.g. {10B981}Sample_Import_Snippet.pwn{FFFFFF}):\n{94A3B8}All CreatePlayerProgressBar(...) statements in the file will be parsed automatically.",
						"Import", "Back");
				}
				case 3:
				{
					PBE_ShowDialog(playerid, PBE_DLG_IMPORT_PASTE, DIALOG_STYLE_INPUT,
						"{38BDF8}Paste CreatePlayerProgressBar Code",
						"{FFFFFF}Paste a single {38BDF8}CreatePlayerProgressBar(...){FFFFFF} statement below:",
						"Parse", "Back");
				}
			}
			return 1;
		}

		case PBE_DLG_IMPORT_PBP_OPEN:
		{
			if (!response)
			{
				PBE_OpenImportMenu(playerid);
				return 1;
			}
			if (PBE_CheckProjectLocked(playerid, sid, inputtext))
			{
				PBE_OpenImportMenu(playerid);
				return 1;
			}
			if (PBE_LoadProjectFile(playerid, sid, PBE_DIR_IMPORTS, inputtext, false) || PBE_LoadProjectFile(playerid, sid, PBE_DIR_PROJECTS, inputtext, false))
			{
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Imported Project: ", "Workspace replaced with imported .pbp project.");
				PBE_SetCursor(playerid, sid, true);
			}
			else
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Not Found: ", "Could not find that .pbp file in Imports/ or Projects/.");
				PBE_OpenImportMenu(playerid);
			}
			return 1;
		}

		case PBE_DLG_IMPORT_PBP_MERGE:
		{
			if (!response)
			{
				PBE_OpenImportMenu(playerid);
				return 1;
			}
			if (PBE_LoadProjectFile(playerid, sid, PBE_DIR_PROJECTS, inputtext, true) || PBE_LoadProjectFile(playerid, sid, PBE_DIR_IMPORTS, inputtext, true))
			{
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Merged Layers: ", "Appended .pbp bar layers into your active workspace.");
				PBE_SetCursor(playerid, sid, true);
			}
			else
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Not Found: ", "Could not find that .pbp file in Projects/ or Imports/.");
				PBE_OpenImportMenu(playerid);
			}
			return 1;
		}

		case PBE_DLG_IMPORT_CODE_FILE:
		{
			if (!response)
			{
				PBE_OpenImportMenu(playerid);
				return 1;
			}
			new count = PBE_ImportPawnCodeFile(playerid, sid, inputtext);
			if (count < 0)
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}File Not Found: ", "Place your .pwn/.inc/.txt file inside 'scriptfiles/Progress Bars/Imports/'.");
				PBE_OpenImportMenu(playerid);
			}
			else if (count == 0)
			{
				PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Bars Parsed: ", "File was read, but no valid CreatePlayerProgressBar(...) calls were found.");
				PBE_OpenImportMenu(playerid);
			}
			else
			{
				new msg[256];
				format(msg, sizeof msg, "Parsed and spawned {38BDF8}%d{FFFFFF} progress bar(s) from Pawn source!", count);
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Code Imported: ", msg);
				PBE_SetCursor(playerid, sid, true);
			}
			return 1;
		}

		case PBE_DLG_IMPORT_PASTE:
		{
			if (!response)
			{
				PBE_OpenImportMenu(playerid);
				return 1;
			}
			PBE_SaveUndo(sid, "Paste Pawn Code");
			if (PBE_ParsePawnCreateCall(playerid, sid, inputtext, true))
			{
				new s = EditorSession[sid][EP_Selected];
				new msg[256];
				format(msg, sizeof msg, "Parsed and spawned layer {38BDF8}#%d %s{FFFFFF}!", s + 1, EditorBars[sid][s][EBar_Name]);
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Snippet Imported: ", msg);
				PBE_SetCursor(playerid, sid, true);
			}
			else
			{
				EditorUndoMeta[sid][EUndo_Available] = false;
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Parse Error: ", "Make sure the line contains CreatePlayerProgressBar(playerid, x, y, ...).");
				PBE_OpenImportMenu(playerid);
			}
			return 1;
		}

		case PBE_DLG_EXPORT_MENU:
		{
			if (!response)
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			EditorSession[sid][EP_ExportFormat] = listitem;
			format(s_DlgBody, sizeof s_DlgBody,
				"{FFFFFF}Enter an output filename (leave blank to use {38BDF8}%s{FFFFFF}):\n{94A3B8}Output folder: scriptfiles/Progress Bars/Exports/",
				EditorSession[sid][EP_ProjectName]
			);
			PBE_ShowDialog(playerid, PBE_DLG_EXPORT_NAME, DIALOG_STYLE_INPUT, "{10B981}Export Production Pawn Code", s_DlgBody, "Export", "Back");
			return 1;
		}

		case PBE_DLG_EXPORT_NAME:
		{
			if (!response)
			{
				PBE_OpenExportMenu(playerid, sid);
				return 1;
			}
			new targetName[PBE_MAX_PROJECT_NAME];
			PBE_Trim(inputtext, targetName, sizeof targetName);
			if (targetName[0] == '\0')
			{
				format(targetName, sizeof targetName, "%s", EditorSession[sid][EP_ProjectName]);
			}
			if (PBE_CheckProjectLocked(playerid, sid, targetName))
			{
				PBE_OpenExportMenu(playerid, sid);
				return 1;
			}

			new outPath[PBE_MAX_PATH];
			if (PBE_ExportProjectCode(sid, targetName, EditorSession[sid][EP_ExportFormat], outPath, sizeof outPath))
			{
				new msg[256];
				format(msg, sizeof msg, "Generated {10B981}scriptfiles/%s{FFFFFF} (%d bars).", outPath, EditorSession[sid][EP_BarCount]);
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Export Complete: ", msg);
			}
			else
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Export Failed: ", "Verify folder 'scriptfiles/Progress Bars/Exports/' exists.");
			}
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		// --------------------------------------------------------------------
		// Create Layer & Template Library
		// --------------------------------------------------------------------
		case PBE_DLG_CREATE_MENU:
		{
			if (!response)
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			switch (listitem)
			{
				case 0:
				{
					PBE_AddNewBar(playerid, sid, PB_STYLE_BAR);
					PBE_SetCursor(playerid, sid, true);
				}
				case 1:
				{
					PBE_AddNewBar(playerid, sid, PB_STYLE_RING);
					PBE_SetCursor(playerid, sid, true);
				}
				case 2:
				{
					PBE_AddNewBar(playerid, sid, PB_STYLE_CIRCLE);
					PBE_SetCursor(playerid, sid, true);
				}
				case 3: PBE_OpenTemplateBrowser(playerid, sid);
				case 4:
				{
					if (PBE_HasActiveBar(sid))
					{
						PBE_DuplicateBarLayer(playerid, sid, EditorSession[sid][EP_Selected]);
					}
					else
					{
						PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Notice: ", "Select an existing layer first to duplicate it.");
					}
					PBE_SetCursor(playerid, sid, true);
				}
			}
			return 1;
		}

		case PBE_DLG_TEMPLATE_LIST:
		{
			if (!response)
			{
				PBE_OpenCreateMenu(playerid, sid);
				return 1;
			}
			if (0 <= listitem < g_PBEBrowserCount[sid])
			{
				if (PBE_LoadTemplateFile(playerid, sid, g_PBEBrowserCache[sid][listitem]))
				{
					new msg[256];
					format(msg, sizeof msg, "Spawned preset {38BDF8}%s{FFFFFF}!", g_PBEBrowserCache[sid][listitem]);
					PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Template Loaded: ", msg);
				}
			}
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		case PBE_DLG_SAVE_TEMPLATE:
		{
			if (!response)
			{
				PBE_OpenLayerActionsMenu(playerid, sid);
				return 1;
			}
			if (PBE_HasActiveBar(sid) && PBE_SaveTemplateFile(sid, EditorSession[sid][EP_Selected], inputtext))
			{
				PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Template Saved: ", "Stored reusable .pbt preset in 'scriptfiles/Progress Bars/Templates/'.");
			}
			else
			{
				PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Save Failed: ", "Enter a valid template name and verify 'Templates/' exists.");
			}
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		// --------------------------------------------------------------------
		// Layer Stack Manager
		// --------------------------------------------------------------------
		case PBE_DLG_LAYERS_LIST:
		{
			if (!response)
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			if (0 <= listitem < EditorSession[sid][EP_BarCount])
			{
				EditorSession[sid][EP_Selected] = listitem;
				PBE_RefreshStatusHUD(playerid, sid);
				PBE_OpenLayerActionsMenu(playerid, sid);
			}
			else
			{
				PBE_SetCursor(playerid, sid, true);
			}
			return 1;
		}

		case PBE_DLG_LAYER_ACTIONS:
		{
			if (!response)
			{
				PBE_OpenLayersMenu(playerid, sid);
				return 1;
			}
			if (!PBE_HasActiveBar(sid))
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			new s = EditorSession[sid][EP_Selected];
			switch (listitem)
			{
				case 0: PBE_SetCursor(playerid, sid, true);
				case 1:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter a clean Pawn variable identifier for layer #%d (current: {38BDF8}%s{FFFFFF}):", s + 1, EditorBars[sid][s][EBar_Name]);
					PBE_ShowDialog(playerid, PBE_DLG_RENAME_BAR, DIALOG_STYLE_INPUT, "{38BDF8}Rename Layer Identifier", s_DlgBody, "Rename", "Back");
				}
				case 2:
				{
					PBE_DuplicateBarLayer(playerid, sid, s);
					PBE_SetCursor(playerid, sid, true);
				}
				case 3:
				{
					EditorBars[sid][s][EBar_Visible] = !EditorBars[sid][s][EBar_Visible];
					EditorSession[sid][EP_Dirty] = true;
					new h = EditorBars[sid][s][EBar_Handle];
					if (IsValidPlayerProgressBar(playerid, h))
					{
						if (EditorBars[sid][s][EBar_Visible]) ShowPlayerProgressBar(playerid, h);
						else HidePlayerProgressBar(playerid, h);
					}
					PBE_OpenLayerActionsMenu(playerid, sid);
				}
				case 4:
				{
					PBE_MoveBarLayerZOrder(playerid, sid, s, s + 1);
					PBE_OpenLayersMenu(playerid, sid);
				}
				case 5:
				{
					PBE_MoveBarLayerZOrder(playerid, sid, s, s - 1);
					PBE_OpenLayersMenu(playerid, sid);
				}
				case 6:
				{
					PBE_MoveBarLayerZOrder(playerid, sid, s, EditorSession[sid][EP_BarCount] - 1);
					PBE_OpenLayersMenu(playerid, sid);
				}
				case 7:
				{
					PBE_MoveBarLayerZOrder(playerid, sid, s, 0);
					PBE_OpenLayersMenu(playerid, sid);
				}
				case 8:
				{
					PBE_ShowDialog(playerid, PBE_DLG_SAVE_TEMPLATE, DIALOG_STYLE_INPUT,
						"{10B981}Save Layer as Template (.pbt)",
						"{FFFFFF}Enter a descriptive preset name for your Template Library:",
						"Save", "Back");
				}
				case 9:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Delete layer {EF4444}#%d %s{FFFFFF} from your workspace?\n{94A3B8}(You can still restore it with Undo.)", s + 1, EditorBars[sid][s][EBar_Name]);
					PBE_ShowDialog(playerid, PBE_DLG_DELETE_BAR_CONF, DIALOG_STYLE_MSGBOX, "{EF4444}Delete Bar Layer", s_DlgBody, "Delete", "Cancel");
				}
			}
			return 1;
		}

		case PBE_DLG_RENAME_BAR:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_OpenLayerActionsMenu(playerid, sid);
				return 1;
			}
			new s = EditorSession[sid][EP_Selected];
			PBE_SaveUndo(sid, "Rename Layer");
			new uniq[PBE_MAX_NAME];
			EditorBars[sid][s][EBar_Used] = false;
			PBE_GenerateUniqueBarName(sid, inputtext, uniq, sizeof uniq);
			EditorBars[sid][s][EBar_Used] = true;
			format(EditorBars[sid][s][EBar_Name], PBE_MAX_NAME, "%s", uniq);
			EditorSession[sid][EP_Dirty] = true;
			PBE_RefreshStatusHUD(playerid, sid);
			PBE_OpenLayerActionsMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_DELETE_BAR_CONF:
		{
			if (!response)
			{
				PBE_OpenLayerActionsMenu(playerid, sid);
				return 1;
			}
			if (PBE_HasActiveBar(sid))
			{
				PBE_DeleteBarLayer(playerid, sid, EditorSession[sid][EP_Selected]);
				PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Layer Deleted: ", "Use {38BDF8}TOOLS -> Undo{FFFFFF} (or {38BDF8}/pbundo{FFFFFF}) if you want to restore it.");
			}
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		// --------------------------------------------------------------------
		// Style & Geometry Inspector
		// --------------------------------------------------------------------
		case PBE_DLG_STYLE_MENU:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			new s = EditorSession[sid][EP_Selected];
			switch (listitem)
			{
				case 0:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "{38BDF8}PB_STYLE_BAR {94A3B8}- Classic Linear Progress Bar\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{F59E0B}PB_STYLE_RING {94A3B8}- Segmented Radial Ring Gauge\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{10B981}PB_STYLE_CIRCLE {94A3B8}- Circular Disc Fill Gauge", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_STYLE_PICK, DIALOG_STYLE_LIST, "{38BDF8}Select Visual Style", s_DlgBody, "Apply", "Back");
				}
				case 1:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "{38BDF8}PB_DIR_RIGHT {94A3B8}- Left-to-Right (or Clockwise Ring)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}PB_DIR_LEFT {94A3B8}- Right-to-Left (or Counter-Clockwise Ring)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}PB_DIR_UP {94A3B8}- Bottom-to-Top (or Counter-Clockwise Ring)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}PB_DIR_DOWN {94A3B8}- Top-to-Bottom (or Clockwise Ring)", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_DIRECTION_PICK, DIALOG_STYLE_LIST, "{38BDF8}Select Fill Direction", s_DlgBody, "Apply", "Back");
				}
				case 2:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter the number of radial ring segments ({38BDF8}4 to 60{FFFFFF}, current: %d):", EditorBars[sid][s][EBar_Segments]);
					PBE_ShowDialog(playerid, PBE_DLG_SEGMENTS_INPUT, DIALOG_STYLE_INPUT, "{F59E0B}Ring Segment Count", s_DlgBody, "Apply", "Back");
				}
				case 3:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter the ring segment scale multiplier ({38BDF8}0.10 to 3.00{FFFFFF}, default 1.00, current: %.2f):", EditorBars[sid][s][EBar_SegScale]);
					PBE_ShowDialog(playerid, PBE_DLG_SEG_SCALE_INPUT, DIALOG_STYLE_INPUT, "{F59E0B}Ring Segment Scale", s_DlgBody, "Apply", "Back");
				}
				case 4: PBE_StartTransformMode(playerid, sid, PBE_MODE_BORDER);
				case 5:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter exact border thickness ({38BDF8}0.50 to 5.00{FFFFFF}, current: %.2f):", EditorBars[sid][s][EBar_Border]);
					PBE_ShowDialog(playerid, PBE_DLG_BORDER_SIZE_INP, DIALOG_STYLE_INPUT, "{38BDF8}Exact Border Thickness", s_DlgBody, "Apply", "Back");
				}
				case 6:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter exact screen {38BDF8}X, Y{FFFFFF} coordinates separated by a comma or space\n(Current: {10B981}%.2f, %.2f{FFFFFF}):", EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					PBE_ShowDialog(playerid, PBE_DLG_EXACT_POS_INPUT, DIALOG_STYLE_INPUT, "{38BDF8}Exact Screen Coordinates (X, Y)", s_DlgBody, "Apply", "Back");
				}
				case 7:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter exact {38BDF8}Width, Height{FFFFFF} separated by a comma or space\n(Current: {10B981}%.2f, %.2f{FFFFFF}):", EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
					PBE_ShowDialog(playerid, PBE_DLG_EXACT_SIZE_INPUT, DIALOG_STYLE_INPUT, "{38BDF8}Exact Dimensions (Width, Height)", s_DlgBody, "Apply", "Back");
				}
				case 8: PBE_OpenLabelMenu(playerid, sid);
			}
			return 1;
		}

		case PBE_DLG_STYLE_PICK:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				new newStyle = PB_STYLE_BAR;
				if (listitem == 1) newStyle = PB_STYLE_RING;
				else if (listitem == 2) newStyle = PB_STYLE_CIRCLE;

				new curNeeded = PB_GetBarRequiredTextDraws(EditorBars[sid][s][EBar_Style], EditorBars[sid][s][EBar_Segments], EditorBars[sid][s][EBar_LabelShow]);
				new tgtNeeded = PB_GetBarRequiredTextDraws(newStyle, EditorBars[sid][s][EBar_Segments], EditorBars[sid][s][EBar_LabelShow]);
				new delta = tgtNeeded - curNeeded;
				new freeTDs = PB_GetFreePlayerTextDraws(playerid);
				if (delta > 0 && freeTDs < delta + PB_TD_SAFETY_HEADROOM)
				{
					new err[128];
					format(err, sizeof err, "Cannot switch style: Exceeds PlayerTextDraw limit (256). Needed: +%d, Available: %d.", delta, freeTDs);
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Capacity Exceeded: ", err);
					PBE_OpenStyleMenu(playerid, sid);
					return 1;
				}

				PBE_SaveUndo(sid, "Change Visual Style");
				EditorBars[sid][s][EBar_Style] = newStyle;
				if (newStyle != PB_STYLE_BAR && EditorBars[sid][s][EBar_H] < 20.0)
				{
					if (EditorBars[sid][s][EBar_W] > 80.0) EditorBars[sid][s][EBar_W] = 56.0;
					EditorBars[sid][s][EBar_H] = EditorBars[sid][s][EBar_W] * PB_BORDER_Y_RATIO;
				}
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					SetPlayerProgressBarSize(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
					SetPlayerProgressBarStyle(playerid, EditorBars[sid][s][EBar_Handle], newStyle, EditorBars[sid][s][EBar_Segments], EditorBars[sid][s][EBar_SegScale]);
				}
				PBE_RefreshStatusHUD(playerid, sid);
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_DIRECTION_PICK:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				PBE_SaveUndo(sid, "Change Fill Direction");
				new newDir = PB_DIR_RIGHT;
				if (listitem == 1) newDir = PB_DIR_LEFT;
				else if (listitem == 2) newDir = PB_DIR_UP;
				else if (listitem == 3) newDir = PB_DIR_DOWN;

				EditorBars[sid][s][EBar_Dir] = newDir;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					SetPlayerProgressBarDirection(playerid, EditorBars[sid][s][EBar_Handle], newDir);
				}
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_SEGMENTS_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new segs = strval(inputtext);
				if (PB_RING_MIN <= segs <= PB_RING_MAX)
				{
					new s = EditorSession[sid][EP_Selected];
					new curNeeded = PB_GetBarRequiredTextDraws(EditorBars[sid][s][EBar_Style], EditorBars[sid][s][EBar_Segments], EditorBars[sid][s][EBar_LabelShow]);
					new tgtNeeded = PB_GetBarRequiredTextDraws(EditorBars[sid][s][EBar_Style], segs, EditorBars[sid][s][EBar_LabelShow]);
					new delta = tgtNeeded - curNeeded;
					new freeTDs = PB_GetFreePlayerTextDraws(playerid);
					if (delta > 0 && freeTDs < delta + PB_TD_SAFETY_HEADROOM)
					{
						new err[128];
						format(err, sizeof err, "Cannot set %d segments: Exceeds PlayerTextDraw limit (256). Needed: +%d, Available: %d.", segs, delta, freeTDs);
						PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Capacity Exceeded: ", err);
						PBE_OpenStyleMenu(playerid, sid);
						return 1;
					}

					PBE_SaveUndo(sid, "Change Ring Segments");
					EditorBars[sid][s][EBar_Segments] = segs;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarStyle(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_Style], segs, EditorBars[sid][s][EBar_SegScale]);
					}
					PBE_RefreshStatusHUD(playerid, sid);
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Out of Range: ", "Ring segments must be between 4 and 60.");
				}
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_SEG_SCALE_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new Float:sc = floatstr(inputtext);
				if (0.10 <= sc <= 3.00)
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Change Ring Scale");
					EditorBars[sid][s][EBar_SegScale] = sc;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarRingScale(playerid, EditorBars[sid][s][EBar_Handle], sc);
					}
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Out of Range: ", "Segment scale must be between 0.10 and 3.00.");
				}
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BORDER_SIZE_INP:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new Float:bs = floatstr(inputtext);
				if (bs == 0.0 || (PB_BORDER_MIN <= bs <= PB_BORDER_MAX))
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Change Border Size");
					EditorBars[sid][s][EBar_Border] = bs;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarBorder(playerid, EditorBars[sid][s][EBar_Handle], bs);
					}
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Out of Range: ", "Border thickness must be 0.00 (borderless) or between 0.50 and 5.00.");
				}
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_EXACT_POS_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new t1[32], t2[32];
				if (PBE_SplitTwoTokens(inputtext, t1, sizeof t1, t2, sizeof t2))
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Set Exact Position");
					EditorBars[sid][s][EBar_X] = floatstr(t1);
					EditorBars[sid][s][EBar_Y] = floatstr(t2);
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarPos(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					}
					PBE_RefreshStatusHUD(playerid, sid);
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Invalid Format: ", "Enter two numbers separated by a comma or space (e.g. 320.0, 224.0).");
				}
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_EXACT_SIZE_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new t1[32], t2[32];
				if (PBE_SplitTwoTokens(inputtext, t1, sizeof t1, t2, sizeof t2))
				{
					new Float:nw = floatstr(t1), Float:nh = floatstr(t2);
					if (nw >= 3.0 && nh >= 3.0)
					{
						new s = EditorSession[sid][EP_Selected];
						PBE_SaveUndo(sid, "Set Exact Dimensions");
						EditorBars[sid][s][EBar_W] = nw;
						EditorBars[sid][s][EBar_H] = nh;
						EditorSession[sid][EP_Dirty] = true;
						if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
						{
							SetPlayerProgressBarSize(playerid, EditorBars[sid][s][EBar_Handle], nw, nh);
						}
						PBE_RefreshStatusHUD(playerid, sid);
					}
					else
					{
						PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Too Small: ", "Width and Height must each be at least 3.0.");
					}
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Invalid Format: ", "Enter Width and Height separated by a comma or space (e.g. 80.0, 9.0).");
				}
			}
			PBE_OpenStyleMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_MENU:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_OpenStyleMenu(playerid, sid);
				return 1;
			}
			new s = EditorSession[sid][EP_Selected];
			switch (listitem)
			{
				case 0:
				{
					EditorBars[sid][s][EBar_LabelShow] = !EditorBars[sid][s][EBar_LabelShow];
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
					PBE_OpenLabelMenu(playerid, sid);
				}
				case 1:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter custom template or text for this label:\n(Tokens: {38BDF8}{PERCENT}{FFFFFF}, {38BDF8}{VAL}{FFFFFF}, {38BDF8}{MAX}{FFFFFF}, {38BDF8}{MIN}{FFFFFF})\nCurrent: {10B981}%s", EditorBars[sid][s][EBar_LabelText]);
					PBE_ShowDialog(playerid, PBE_DLG_LABEL_TEXT_INP, DIALOG_STYLE_INPUT, "{38BDF8}Label Text / Template", s_DlgBody, "Apply", "Back");
				}
				case 2:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "Preset Name\tTemplate String\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}Percentage Only\t{FFFFFF}{PERCENT}%\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}Fraction (Current / Max)\t{FFFFFF}{VAL} / {MAX}\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}Value Only\t{FFFFFF}{VAL}\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{10B981}Health Gauge\t{FFFFFF}HP: {PERCENT}%\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{F59E0B}Armour Gauge\t{FFFFFF}ARM: {PERCENT}%\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{EC4899}Range (Min to Max)\t{FFFFFF}{MIN} - {MAX}", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_LABEL_PRESETS, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}Quick Template Presets", s_DlgBody, "Apply", "Back");
				}
				case 3: PBE_OpenSwatchPalette(playerid, PBE_DLG_LABEL_COLOR_PAL, "{38BDF8}Select Label Text Color", false);
				case 4:
				{
					EditorBars[sid][s][EBar_LabelFollowCol] = !EditorBars[sid][s][EBar_LabelFollowCol];
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
					PBE_OpenLabelMenu(playerid, sid);
				}
				case 5:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "Font Style\tPreview\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Font 0\tClassic fixed monospace\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Font 1\tStandard slim GTA font (Recommended)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Font 2\tHeadline all-caps bold font\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Font 3\tStoryline / retro serif font", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_LABEL_FONT_PICK, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}Select Font Style", s_DlgBody, "Apply", "Back");
				}
				case 6:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "Alignment\tDescription\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Center (2)\tCentered inside progress bar\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Left (1)\tAligned to left border edge\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "Right (3)\tAligned to right border edge", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_LABEL_ALIGN_PICK, DIALOG_STYLE_TABLIST_HEADERS, "{38BDF8}Select Text Alignment", s_DlgBody, "Apply", "Back");
				}
				case 7:
				{
					EditorBars[sid][s][EBar_LabelAutoScale] = !EditorBars[sid][s][EBar_LabelAutoScale];
					if (EditorBars[sid][s][EBar_LabelAutoScale])
					{
						EditorBars[sid][s][EBar_LabelScaleX] = 0.0;
						EditorBars[sid][s][EBar_LabelScaleY] = 0.0;
					}
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
					PBE_OpenLabelMenu(playerid, sid);
				}
				case 8:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter manual font size {38BDF8}ScaleX, ScaleY{FFFFFF} (disables Auto-Fit):\n(Current: {38BDF8}%.2f %.2f{FFFFFF})", EditorBars[sid][s][EBar_LabelScaleX], EditorBars[sid][s][EBar_LabelScaleY]);
					PBE_ShowDialog(playerid, PBE_DLG_LABEL_SCALE_INP, DIALOG_STYLE_INPUT, "{38BDF8}Manual Letter Size", s_DlgBody, "Apply", "Back");
				}
				case 9:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter relative position offset {38BDF8}OffsetX, OffsetY{FFFFFF} in pixels:\n(Default: {10B981}0.0 0.0{FFFFFF}, Current: {38BDF8}%.2f %.2f{FFFFFF})", EditorBars[sid][s][EBar_LabelOffsetX], EditorBars[sid][s][EBar_LabelOffsetY]);
					PBE_ShowDialog(playerid, PBE_DLG_LABEL_OFFSET_INP, DIALOG_STYLE_INPUT, "{38BDF8}Label Position Offset", s_DlgBody, "Apply", "Back");
				}
			}
			return 1;
		}

		case PBE_DLG_LABEL_PRESETS:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				switch (listitem)
				{
					case 0: format(EditorBars[sid][s][EBar_LabelText], 32, "{PERCENT}%%");
					case 1: format(EditorBars[sid][s][EBar_LabelText], 32, "{VAL} / {MAX}");
					case 2: format(EditorBars[sid][s][EBar_LabelText], 32, "{VAL}");
					case 3: format(EditorBars[sid][s][EBar_LabelText], 32, "HP: {PERCENT}%%");
					case 4: format(EditorBars[sid][s][EBar_LabelText], 32, "ARM: {PERCENT}%%");
					case 5: format(EditorBars[sid][s][EBar_LabelText], 32, "{MIN} - {MAX}");
				}
				EditorBars[sid][s][EBar_LabelShow] = true;
				EditorSession[sid][EP_Dirty] = true;
				PBE_SyncLabel(playerid, sid, s);
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_TEXT_INP:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (inputtext[0] != '\0')
				{
					format(EditorBars[sid][s][EBar_LabelText], 32, "%s", inputtext);
					EditorBars[sid][s][EBar_LabelShow] = true;
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
				}
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_COLOR_PAL:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (0 <= listitem < sizeof(g_PBESwatches))
				{
					EditorBars[sid][s][EBar_LabelColor] = g_PBESwatches[listitem][Swatch_RGBA];
					EditorBars[sid][s][EBar_LabelFollowCol] = false;
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
				}
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_FONT_PICK:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (0 <= listitem <= 3)
				{
					EditorBars[sid][s][EBar_LabelFont] = listitem;
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
				}
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_ALIGN_PICK:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (listitem == 0) EditorBars[sid][s][EBar_LabelAlign] = 2; // Center
				else if (listitem == 1) EditorBars[sid][s][EBar_LabelAlign] = 1; // Left
				else if (listitem == 2) EditorBars[sid][s][EBar_LabelAlign] = 3; // Right
				EditorSession[sid][EP_Dirty] = true;
				PBE_SyncLabel(playerid, sid, s);
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_SCALE_INP:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				new t1[32], t2[32];
				if (PBE_SplitTwoTokens(inputtext, t1, sizeof t1, t2, sizeof t2))
				{
					new Float:sx = floatstr(t1), Float:sy = floatstr(t2);
					if (sx > 0.05 && sy > 0.1)
					{
						EditorBars[sid][s][EBar_LabelAutoScale] = false;
						EditorBars[sid][s][EBar_LabelScaleX] = sx;
						EditorBars[sid][s][EBar_LabelScaleY] = sy;
						EditorSession[sid][EP_Dirty] = true;
						PBE_SyncLabel(playerid, sid, s);
					}
				}
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_LABEL_OFFSET_INP:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				new t1[32], t2[32];
				if (PBE_SplitTwoTokens(inputtext, t1, sizeof t1, t2, sizeof t2))
				{
					new Float:ox = floatstr(t1), Float:oy = floatstr(t2);
					EditorBars[sid][s][EBar_LabelOffsetX] = ox;
					EditorBars[sid][s][EBar_LabelOffsetY] = oy;
					EditorSession[sid][EP_Dirty] = true;
					PBE_SyncLabel(playerid, sid, s);
				}
			}
			PBE_OpenLabelMenu(playerid, sid);
			return 1;
		}

		// --------------------------------------------------------------------
		// Color & Theme Designer
		// --------------------------------------------------------------------
		case PBE_DLG_COLOR_MENU:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			switch (listitem)
			{
				case 0: PBE_OpenSwatchPalette(playerid, PBE_DLG_MAIN_PALETTE, "{38BDF8}Select Main Fill Color", false);
				case 1:
				{
					PBE_ShowDialog(playerid, PBE_DLG_MAIN_HEX_INPUT, DIALOG_STYLE_INPUT,
						"{38BDF8}Custom Main Fill Hex Color",
						"{FFFFFF}Enter a 6-digit RGB or 8-digit RGBA hex color (e.g. {38BDF8}0xE74C3CFF{FFFFFF} or {38BDF8}#38BDF8{FFFFFF}):",
						"Apply", "Back");
				}
				case 2:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "{FFFFFF}100% Solid Opaque (0xFF / 255)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{FFFFFF}90% Crisp HUD Glass (0xE6 / 230)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{FFFFFF}75% Translucent (0xBF / 191)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{FFFFFF}50% Semi-Transparent (0x80 / 128)\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{FFFFFF}25% Subtle Ghost (0x40 / 64)", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_MAIN_ALPHA_PICK, DIALOG_STYLE_LIST, "{38BDF8}Main Fill Opacity / Alpha", s_DlgBody, "Apply", "Back");
				}
				case 3: PBE_OpenSwatchPalette(playerid, PBE_DLG_BORDER_PALETTE, "{F59E0B}Select Border Frame Color", true);
				case 4:
				{
					PBE_ShowDialog(playerid, PBE_DLG_BORDER_HEX_INPUT, DIALOG_STYLE_INPUT,
						"{F59E0B}Custom Border Hex Color",
						"{FFFFFF}Enter {38BDF8}0{FFFFFF} for automatic border shading, or enter a hex color ({38BDF8}0x0F172AE6{FFFFFF} / {38BDF8}#000000{FFFFFF}):",
						"Apply", "Back");
				}
				case 5:
				{
					if (EditorSession[sid][EP_BarCount] < 2)
					{
						PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Need 2+ Layers: ", "Create another bar layer to copy themes between layers.");
						PBE_OpenColorMenu(playerid, sid);
					}
					else
					{
						s_DlgBody[0] = '\0';
						strcat(s_DlgBody, "Source Layer\tMain Color\n", sizeof s_DlgBody);
						new s = EditorSession[sid][EP_Selected], hx[16], tg[12];
						for (new i = 0; i < EditorSession[sid][EP_BarCount]; i++)
						{
							if (i == s) continue;
							PBE_FormatHex(EditorBars[sid][i][EBar_Color], hx);
							PBE_FormatRGBTag(EditorBars[sid][i][EBar_Color], tg);
							format(s_DlgRow, sizeof s_DlgRow, "{38BDF8}#%d %s\t%s|||| {FFFFFF}%s\n", i + 1, EditorBars[sid][i][EBar_Name], tg, hx);
							strcat(s_DlgBody, s_DlgRow, sizeof s_DlgBody);
						}
						PBE_ShowDialog(playerid, PBE_DLG_COPY_STYLE_PICK, DIALOG_STYLE_TABLIST_HEADERS, "{10B981}Copy Visual Theme from Layer", s_DlgBody, "Copy", "Back");
					}
				}
				case 6:
				{
					new s = EditorSession[sid][EP_Selected];
					EditorBars[sid][s][EBar_Gradient] = !EditorBars[sid][s][EBar_Gradient];
					EditorSession[sid][EP_Dirty] = true;
					new h = EditorBars[sid][s][EBar_Handle];
					if (IsValidPlayerProgressBar(playerid, h))
					{
						SetPlayerProgressBarGradient(playerid, h, EditorBars[sid][s][EBar_Gradient], EditorBars[sid][s][EBar_GradEmpty], EditorBars[sid][s][EBar_GradFull], EditorBars[sid][s][EBar_GradMid], EditorBars[sid][s][EBar_GradInvert]);
					}
					PBE_OpenColorMenu(playerid, sid);
				}
				case 7:
				{
					new s = EditorSession[sid][EP_Selected];
					EditorBars[sid][s][EBar_GradInvert] = !EditorBars[sid][s][EBar_GradInvert];
					if (!EditorBars[sid][s][EBar_Gradient]) EditorBars[sid][s][EBar_Gradient] = true;
					EditorSession[sid][EP_Dirty] = true;
					new h = EditorBars[sid][s][EBar_Handle];
					if (IsValidPlayerProgressBar(playerid, h))
					{
						SetPlayerProgressBarGradient(playerid, h, true, EditorBars[sid][s][EBar_GradEmpty], EditorBars[sid][s][EBar_GradFull], EditorBars[sid][s][EBar_GradMid], EditorBars[sid][s][EBar_GradInvert]);
					}
					PBE_OpenColorMenu(playerid, sid);
				}
			}
			return 1;
		}

		case PBE_DLG_MAIN_PALETTE:
		{
			if (response && PBE_HasActiveBar(sid) && 0 <= listitem < sizeof(g_PBESwatches))
			{
				new s = EditorSession[sid][EP_Selected];
				PBE_SaveUndo(sid, "Change Main Color");
				EditorBars[sid][s][EBar_Color] = g_PBESwatches[listitem][Swatch_RGBA];
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					SetPlayerProgressBarColour(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_Color]);
				}
			}
			PBE_OpenColorMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_MAIN_HEX_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new col;
				if (PBE_ParseHexColor(inputtext, col))
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Custom Main Hex Color");
					EditorBars[sid][s][EBar_Color] = col;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarColour(playerid, EditorBars[sid][s][EBar_Handle], col);
					}
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Invalid Hex: ", "Use 6 or 8 hex digits, e.g. 0x38BDF8FF or #38BDF8.");
				}
			}
			PBE_OpenColorMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_MAIN_ALPHA_PICK:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				static const kAlphaVals[5] = {0xFF, 0xE6, 0xBF, 0x80, 0x40};
				if (0 <= listitem < 5)
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Change Main Opacity");
					EditorBars[sid][s][EBar_Color] = (EditorBars[sid][s][EBar_Color] & 0xFFFFFF00) | kAlphaVals[listitem];
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarColour(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_Color]);
					}
				}
			}
			PBE_OpenColorMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BORDER_PALETTE:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				PBE_SaveUndo(sid, "Change Border Color");
				if (listitem == 0) EditorBars[sid][s][EBar_BorderColor] = 0;
				else if (0 <= listitem - 1 < sizeof(g_PBESwatches)) EditorBars[sid][s][EBar_BorderColor] = g_PBESwatches[listitem - 1][Swatch_RGBA];
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					SetPlayerProgressBarBorderColor(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_BorderColor]);
				}
			}
			PBE_OpenColorMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BORDER_HEX_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new trimmed[32], col;
				PBE_Trim(inputtext, trimmed, sizeof trimmed);
				if (!strcmp(trimmed, "0"))
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Reset Auto Border Color");
					EditorBars[sid][s][EBar_BorderColor] = 0;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarBorderColor(playerid, EditorBars[sid][s][EBar_Handle], 0);
					}
				}
				else if (PBE_ParseHexColor(trimmed, col))
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Custom Border Hex Color");
					EditorBars[sid][s][EBar_BorderColor] = col;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarBorderColor(playerid, EditorBars[sid][s][EBar_Handle], col);
					}
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Invalid Hex: ", "Enter 0 for Auto, or 6/8 hex digits (e.g. 0x0F172AE6).");
				}
			}
			PBE_OpenColorMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_COPY_STYLE_PICK:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new src = PBE_MapOtherLayerListitem(sid, listitem);
				if (0 <= src < EditorSession[sid][EP_BarCount])
				{
					new s = EditorSession[sid][EP_Selected];
					PBE_SaveUndo(sid, "Copy Visual Theme");
					EditorBars[sid][s][EBar_Color]       = EditorBars[sid][src][EBar_Color];
					EditorBars[sid][s][EBar_BorderColor] = EditorBars[sid][src][EBar_BorderColor];
					EditorBars[sid][s][EBar_Border]      = EditorBars[sid][src][EBar_Border];
					EditorSession[sid][EP_Dirty] = true;
					PBE_SpawnSlotHandle(playerid, sid, s);
				}
			}
			PBE_OpenColorMenu(playerid, sid);
			return 1;
		}

		// --------------------------------------------------------------------
		// Value, Auto-Fill & Blink Designer
		// --------------------------------------------------------------------
		case PBE_DLG_ANIMATE_MENU:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			new s = EditorSession[sid][EP_Selected];
			switch (listitem)
			{
				case 0:
				{
					s_DlgBody[0] = '\0';
					strcat(s_DlgBody, "{EF4444}0% Empty\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{F59E0B}15% Critical Low\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{F59E0B}25% Quarter Fill\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{38BDF8}50% Half Fill\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{10B981}75% Three-Quarters\n", sizeof s_DlgBody);
					strcat(s_DlgBody, "{10B981}100% Full Capacity", sizeof s_DlgBody);
					PBE_ShowDialog(playerid, PBE_DLG_VALUE_PRESETS, DIALOG_STYLE_LIST, "{38BDF8}Quick Value Presets", s_DlgBody, "Apply", "Back");
				}
				case 1: PBE_StartTransformMode(playerid, sid, PBE_MODE_SCRUB);
				case 2:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter exact current value ({38BDF8}0.00 to %.2f{FFFFFF}):", EditorBars[sid][s][EBar_Max]);
					PBE_ShowDialog(playerid, PBE_DLG_VALUE_EXACT, DIALOG_STYLE_INPUT, "{38BDF8}Set Exact Value", s_DlgBody, "Apply", "Back");
				}
				case 3:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter new maximum capacity value (> 0.0, current: {38BDF8}%.2f{FFFFFF}):", EditorBars[sid][s][EBar_Max]);
					PBE_ShowDialog(playerid, PBE_DLG_MAX_VALUE_INPUT, DIALOG_STYLE_INPUT, "{38BDF8}Set Maximum Capacity", s_DlgBody, "Apply", "Back");
				}
				case 4:
				{
					format(s_DlgBody, sizeof s_DlgBody, "{FFFFFF}Enter minimum value floor (current: {38BDF8}%.2f{FFFFFF}, Max: %.2f):", EditorBars[sid][s][EBar_Min], EditorBars[sid][s][EBar_Max]);
					PBE_ShowDialog(playerid, PBE_DLG_MIN_VALUE_INPUT, DIALOG_STYLE_INPUT, "{38BDF8}Set Minimum Floor", s_DlgBody, "Apply", "Back");
				}
				case 5:
				{
					EditorBars[sid][s][EBar_AutoFill] = !EditorBars[sid][s][EBar_AutoFill];
					EditorSession[sid][EP_Dirty] = true;
					new h = EditorBars[sid][s][EBar_Handle];
					if (IsValidPlayerProgressBar(playerid, h))
					{
						if (EditorBars[sid][s][EBar_AutoFill])
						{
							StopPlayerProgressBarInterpolation(playerid, h);
							AutoFillPlayerProgressBar(playerid, h, EditorBars[sid][s][EBar_AutoFillMax]);
						}
						else
						{
							StopAutoFillPlayerProgressBar(playerid, h);
							SetPlayerProgressBarValue(playerid, h, EditorBars[sid][s][EBar_Val]);
						}
					}
					PBE_OpenAnimateMenu(playerid, sid);
				}
				case 6:
				{
					PBE_ShowDialog(playerid, PBE_DLG_AUTOFILL_INPUT, DIALOG_STYLE_INPUT,
						"{F59E0B}Auto-Fill Custom Ceiling",
						"{FFFFFF}Enter the peak value for Auto-Fill ping-pong animation (enter {38BDF8}-1{FFFFFF} to use full MaxValue):",
						"Apply", "Back");
				}
				case 7: PBE_OpenBlinkMenu(playerid, sid);
				case 8:
				{
					new h = EditorBars[sid][s][EBar_Handle];
					if (IsValidPlayerProgressBar(playerid, h))
					{
						if (EditorBars[sid][s][EBar_AutoFill])
						{
							EditorBars[sid][s][EBar_AutoFill] = false;
							StopAutoFillPlayerProgressBar(playerid, h);
						}
						new Float:target = (EditorBars[sid][s][EBar_Val] > (EditorBars[sid][s][EBar_Max] * 0.5)) ? EditorBars[sid][s][EBar_Min] : EditorBars[sid][s][EBar_Max];
						EditorBars[sid][s][EBar_Val] = target;
						EditorSession[sid][EP_Dirty] = true;
						InterpolatePlayerProgressBarValue(playerid, h, target, 600);
						PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Lerp Triggered: ", "Interpolating progress bar value smoothly (600ms).");
					}
					PBE_OpenAnimateMenu(playerid, sid);
				}
			}
			return 1;
		}

		case PBE_DLG_VALUE_PRESETS:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				static const Float:kPct[6] = {0.0, 0.15, 0.25, 0.50, 0.75, 1.00};
				if (0 <= listitem < 6)
				{
					new s = EditorSession[sid][EP_Selected];
					EditorBars[sid][s][EBar_Val] = EditorBars[sid][s][EBar_Max] * kPct[listitem];
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarValue(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_Val]);
					}
					PBE_RefreshStatusHUD(playerid, sid);
				}
			}
			PBE_OpenAnimateMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_MIN_VALUE_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new Float:mv = floatstr(inputtext);
				new s = EditorSession[sid][EP_Selected];
				if (mv <= EditorBars[sid][s][EBar_Max])
				{
					EditorBars[sid][s][EBar_Min] = mv;
					if (EditorBars[sid][s][EBar_Val] < mv) EditorBars[sid][s][EBar_Val] = mv;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarMinValue(playerid, EditorBars[sid][s][EBar_Handle], mv);
						SetPlayerProgressBarValue(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_Val]);
					}
					PBE_RefreshStatusHUD(playerid, sid);
				}
				else
				{
					PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Invalid Range: ", "Minimum value floor cannot exceed maximum capacity.");
				}
			}
			PBE_OpenAnimateMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_VALUE_EXACT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				new Float:v = floatstr(inputtext);
				if (v < 0.0) v = 0.0;
				if (v > EditorBars[sid][s][EBar_Max]) v = EditorBars[sid][s][EBar_Max];
				EditorBars[sid][s][EBar_Val] = v;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					SetPlayerProgressBarValue(playerid, EditorBars[sid][s][EBar_Handle], v);
				}
				PBE_RefreshStatusHUD(playerid, sid);
			}
			PBE_OpenAnimateMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_MAX_VALUE_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new Float:mv = floatstr(inputtext);
				if (mv > 0.0)
				{
					new s = EditorSession[sid][EP_Selected];
					EditorBars[sid][s][EBar_Max] = mv;
					if (EditorBars[sid][s][EBar_Val] > mv) EditorBars[sid][s][EBar_Val] = mv;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
					{
						SetPlayerProgressBarMaxValue(playerid, EditorBars[sid][s][EBar_Handle], mv);
						SetPlayerProgressBarValue(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_Val]);
					}
					PBE_RefreshStatusHUD(playerid, sid);
				}
			}
			PBE_OpenAnimateMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_AUTOFILL_INPUT:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				EditorBars[sid][s][EBar_AutoFillMax] = floatstr(inputtext);
				EditorBars[sid][s][EBar_AutoFill] = true;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					StopPlayerProgressBarInterpolation(playerid, EditorBars[sid][s][EBar_Handle]);
					AutoFillPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_AutoFillMax]);
				}
			}
			PBE_OpenAnimateMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BLINK_MENU:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_OpenAnimateMenu(playerid, sid);
				return 1;
			}
			new s = EditorSession[sid][EP_Selected];
			switch (listitem)
			{
				case 0:
				{
					EditorBars[sid][s][EBar_Blinking] = !EditorBars[sid][s][EBar_Blinking];
					EditorSession[sid][EP_Dirty] = true;
					new h = EditorBars[sid][s][EBar_Handle];
					if (IsValidPlayerProgressBar(playerid, h))
					{
						if (EditorBars[sid][s][EBar_Blinking])
						{
							BlinkPlayerProgressBar(playerid, h, EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration], EditorBars[sid][s][EBar_BlinkColor], EditorBars[sid][s][EBar_BlinkBorderColor]);
						}
						else
						{
							StopPlayerProgressBarBlink(playerid, h);
						}
					}
					PBE_OpenBlinkMenu(playerid, sid);
				}
				case 1:
				{
					format(s_DlgBody, sizeof s_DlgBody,
						"{FFFFFF}Enter {38BDF8}Interval (ms), Duration (ms){FFFFFF} separated by a comma or space:\n{94A3B8}- Interval: 50 to 60000 ms (default 250)\n- Duration: 0 for infinite, or auto-stop time in ms\n(Current: %d, %d)",
						EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration]);
					PBE_ShowDialog(playerid, PBE_DLG_BLINK_TIMING, DIALOG_STYLE_INPUT, "{38BDF8}Blink Interval & Duration", s_DlgBody, "Apply", "Back");
				}
				case 2: PBE_OpenSwatchPalette(playerid, PBE_DLG_BLINK_COL_PAL, "{F59E0B}Blink Phase-B Fill Color", true);
				case 3:
				{
					PBE_ShowDialog(playerid, PBE_DLG_BLINK_COL_HEX, DIALOG_STYLE_INPUT,
						"{F59E0B}Blink Phase-B Fill Hex",
						"{FFFFFF}Enter {38BDF8}0{FFFFFF} for classic hide/dim blink, or a hex color (e.g. {38BDF8}0xFACC15FF{FFFFFF}):",
						"Apply", "Back");
				}
				case 4: PBE_OpenSwatchPalette(playerid, PBE_DLG_BLINK_BCOL_PAL, "{EF4444}Blink Phase-B Border Color", true);
				case 5:
				{
					PBE_ShowDialog(playerid, PBE_DLG_BLINK_BCOL_HEX, DIALOG_STYLE_INPUT,
						"{EF4444}Blink Phase-B Border Hex",
						"{FFFFFF}Enter {38BDF8}0{FFFFFF} to keep normal border during blink, or enter an alternate border hex color:",
						"Apply", "Back");
				}
			}
			return 1;
		}

		case PBE_DLG_BLINK_TIMING:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				new t1[24], t2[24];
				if (PBE_SplitTwoTokens(inputtext, t1, sizeof t1, t2, sizeof t2))
				{
					EditorBars[sid][s][EBar_BlinkInterval] = strval(t1);
					EditorBars[sid][s][EBar_BlinkDuration] = strval(t2);
				}
				else
				{
					EditorBars[sid][s][EBar_BlinkInterval] = strval(inputtext);
				}
				if (EditorBars[sid][s][EBar_BlinkInterval] < PB_BLINK_MIN) EditorBars[sid][s][EBar_BlinkInterval] = PB_BLINK_MIN;
				if (EditorBars[sid][s][EBar_BlinkInterval] > PB_BLINK_MAX) EditorBars[sid][s][EBar_BlinkInterval] = PB_BLINK_MAX;
				if (EditorBars[sid][s][EBar_BlinkDuration] < 0) EditorBars[sid][s][EBar_BlinkDuration] = 0;

				EditorBars[sid][s][EBar_Blinking] = true;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					BlinkPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration], EditorBars[sid][s][EBar_BlinkColor], EditorBars[sid][s][EBar_BlinkBorderColor]);
				}
			}
			PBE_OpenBlinkMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BLINK_COL_PAL:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (listitem == 0) EditorBars[sid][s][EBar_BlinkColor] = 0;
				else if (0 <= listitem - 1 < sizeof(g_PBESwatches)) EditorBars[sid][s][EBar_BlinkColor] = g_PBESwatches[listitem - 1][Swatch_RGBA];
				EditorBars[sid][s][EBar_Blinking] = true;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					BlinkPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration], EditorBars[sid][s][EBar_BlinkColor], EditorBars[sid][s][EBar_BlinkBorderColor]);
				}
			}
			PBE_OpenBlinkMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BLINK_COL_HEX:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new trimmed[32], col, s = EditorSession[sid][EP_Selected];
				PBE_Trim(inputtext, trimmed, sizeof trimmed);
				if (!strcmp(trimmed, "0")) EditorBars[sid][s][EBar_BlinkColor] = 0;
				else if (PBE_ParseHexColor(trimmed, col)) EditorBars[sid][s][EBar_BlinkColor] = col;

				EditorBars[sid][s][EBar_Blinking] = true;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					BlinkPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration], EditorBars[sid][s][EBar_BlinkColor], EditorBars[sid][s][EBar_BlinkBorderColor]);
				}
			}
			PBE_OpenBlinkMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BLINK_BCOL_PAL:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new s = EditorSession[sid][EP_Selected];
				if (listitem == 0) EditorBars[sid][s][EBar_BlinkBorderColor] = 0;
				else if (0 <= listitem - 1 < sizeof(g_PBESwatches)) EditorBars[sid][s][EBar_BlinkBorderColor] = g_PBESwatches[listitem - 1][Swatch_RGBA];
				EditorBars[sid][s][EBar_Blinking] = true;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					BlinkPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration], EditorBars[sid][s][EBar_BlinkColor], EditorBars[sid][s][EBar_BlinkBorderColor]);
				}
			}
			PBE_OpenBlinkMenu(playerid, sid);
			return 1;
		}

		case PBE_DLG_BLINK_BCOL_HEX:
		{
			if (response && PBE_HasActiveBar(sid))
			{
				new trimmed[32], col, s = EditorSession[sid][EP_Selected];
				PBE_Trim(inputtext, trimmed, sizeof trimmed);
				if (!strcmp(trimmed, "0")) EditorBars[sid][s][EBar_BlinkBorderColor] = 0;
				else if (PBE_ParseHexColor(trimmed, col)) EditorBars[sid][s][EBar_BlinkBorderColor] = col;

				EditorBars[sid][s][EBar_Blinking] = true;
				EditorSession[sid][EP_Dirty] = true;
				if (IsValidPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle]))
				{
					BlinkPlayerProgressBar(playerid, EditorBars[sid][s][EBar_Handle], EditorBars[sid][s][EBar_BlinkInterval], EditorBars[sid][s][EBar_BlinkDuration], EditorBars[sid][s][EBar_BlinkColor], EditorBars[sid][s][EBar_BlinkBorderColor]);
				}
			}
			PBE_OpenBlinkMenu(playerid, sid);
			return 1;
		}

		// --------------------------------------------------------------------
		// Precision Alignment, Anchors & Undo Tools
		// --------------------------------------------------------------------
		case PBE_DLG_TOOLS_MENU:
		{
			if (!response)
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			if (listitem == 0)
			{
				PBE_PerformUndo(playerid, sid);
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			if (!PBE_HasActiveBar(sid))
			{
				PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}No Active Layer: ", "Create or select a bar layer first.");
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}

			new s = EditorSession[sid][EP_Selected];
			new h = EditorBars[sid][s][EBar_Handle];
			switch (listitem)
			{
				case 1:
				{
					PBE_SaveUndo(sid, "Center Horizontally");
					EditorBars[sid][s][EBar_X] = 320.0 - (EditorBars[sid][s][EBar_W] * 0.5);
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, h)) SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					PBE_RefreshStatusHUD(playerid, sid);
					PBE_SetCursor(playerid, sid, true);
				}
				case 2:
				{
					PBE_SaveUndo(sid, "Center Vertically");
					EditorBars[sid][s][EBar_Y] = 224.0 - (EditorBars[sid][s][EBar_H] * 0.5);
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, h)) SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					PBE_RefreshStatusHUD(playerid, sid);
					PBE_SetCursor(playerid, sid, true);
				}
				case 3:
				{
					PBE_SaveUndo(sid, "True Screen Center");
					EditorBars[sid][s][EBar_X] = 320.0 - (EditorBars[sid][s][EBar_W] * 0.5);
					EditorBars[sid][s][EBar_Y] = 224.0 - (EditorBars[sid][s][EBar_H] * 0.5);
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, h)) SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
					PBE_RefreshStatusHUD(playerid, sid);
					PBE_SetCursor(playerid, sid, true);
				}
				case 4: PBE_OpenGTAAnchorsMenu(playerid);
				case 5: PBE_OpenRelTargetPicker(playerid, sid);
				case 6:
				{
					PBE_SaveUndo(sid, "16:9 Circle Ratio");
					EditorBars[sid][s][EBar_H] = EditorBars[sid][s][EBar_W] * PB_BORDER_Y_RATIO;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, h)) SetPlayerProgressBarSize(playerid, h, EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
					PBE_RefreshStatusHUD(playerid, sid);
					PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}16:9 Ratio Applied: ", "Height set to Width * 1.25 for a true round circle on widescreen displays.");
					PBE_SetCursor(playerid, sid, true);
				}
				case 7:
				{
					PBE_SaveUndo(sid, "Round to Integers");
					EditorBars[sid][s][EBar_X] = float(floatround(EditorBars[sid][s][EBar_X]));
					EditorBars[sid][s][EBar_Y] = float(floatround(EditorBars[sid][s][EBar_Y]));
					EditorBars[sid][s][EBar_W] = float(floatround(EditorBars[sid][s][EBar_W]));
					EditorBars[sid][s][EBar_H] = float(floatround(EditorBars[sid][s][EBar_H]));
					if (EditorBars[sid][s][EBar_W] < 3.0) EditorBars[sid][s][EBar_W] = 3.0;
					if (EditorBars[sid][s][EBar_H] < 3.0) EditorBars[sid][s][EBar_H] = 3.0;
					EditorSession[sid][EP_Dirty] = true;
					if (IsValidPlayerProgressBar(playerid, h))
					{
						SetPlayerProgressBarPos(playerid, h, EditorBars[sid][s][EBar_X], EditorBars[sid][s][EBar_Y]);
						SetPlayerProgressBarSize(playerid, h, EditorBars[sid][s][EBar_W], EditorBars[sid][s][EBar_H]);
					}
					PBE_RefreshStatusHUD(playerid, sid);
					PBE_SetCursor(playerid, sid, true);
				}
			}
			return 1;
		}

		case PBE_DLG_GTA_ANCHORS:
		{
			if (!response || !PBE_HasActiveBar(sid))
			{
				PBE_OpenToolsMenu(playerid, sid);
				return 1;
			}
			if (0 <= listitem < sizeof(g_PBEAnchors))
			{
				new s = EditorSession[sid][EP_Selected];
				PBE_SaveUndo(sid, "GTA HUD Anchor");
				EditorBars[sid][s][EBar_Style] = g_PBEAnchors[listitem][Anchor_Style];
				EditorBars[sid][s][EBar_X]     = g_PBEAnchors[listitem][Anchor_X];
				EditorBars[sid][s][EBar_Y]     = g_PBEAnchors[listitem][Anchor_Y];
				EditorBars[sid][s][EBar_W]     = g_PBEAnchors[listitem][Anchor_W];
				EditorBars[sid][s][EBar_H]     = g_PBEAnchors[listitem][Anchor_H];
				EditorSession[sid][EP_Dirty]   = true;
				PBE_SpawnSlotHandle(playerid, sid, s);
				PBE_RefreshStatusHUD(playerid, sid);
			}
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		case PBE_DLG_REL_TARGET_PICK:
		{
			if (!response)
			{
				PBE_OpenToolsMenu(playerid, sid);
				return 1;
			}
			new ref = PBE_MapOtherLayerListitem(sid, listitem);
			if (ref >= 0)
			{
				EditorSession[sid][EP_RelTargetSlot] = ref;
				PBE_OpenRelActionPicker(playerid, sid);
			}
			else
			{
				PBE_OpenToolsMenu(playerid, sid);
			}
			return 1;
		}

		case PBE_DLG_REL_ACTION_PICK:
		{
			if (!response)
			{
				PBE_OpenRelTargetPicker(playerid, sid);
				return 1;
			}
			if (listitem >= 9 && listitem <= 12)
			{
				EditorSession[sid][EP_RelPendingAct] = listitem;
				PBE_ShowDialog(playerid, PBE_DLG_STACK_GAP_INPUT, DIALOG_STYLE_INPUT,
					"{F59E0B}Stack Pixel Spacing",
					"{FFFFFF}Enter the pixel gap between the two bars (e.g. {38BDF8}4.0{FFFFFF}, or {38BDF8}0.0{FFFFFF} for flush contact):",
					"Stack", "Back");
				return 1;
			}
			PBE_ApplyRelativeAlignment(playerid, sid, listitem);
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		case PBE_DLG_STACK_GAP_INPUT:
		{
			if (!response)
			{
				PBE_OpenRelActionPicker(playerid, sid);
				return 1;
			}
			new trimmed[24];
			PBE_Trim(inputtext, trimmed, sizeof trimmed);
			new Float:gap = (trimmed[0] == '\0') ? 4.0 : floatstr(trimmed);
			PBE_ApplyRelativeAlignment(playerid, sid, EditorSession[sid][EP_RelPendingAct], gap);
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}

		// --------------------------------------------------------------------
		// View, Workspace Settings, Help & Exit
		// --------------------------------------------------------------------
		case PBE_DLG_VIEW_MENU:
		{
			if (!response)
			{
				PBE_SetCursor(playerid, sid, true);
				return 1;
			}
			switch (listitem)
			{
				case 0:
				{
					EditorSession[sid][EP_DockPos] = (EditorSession[sid][EP_DockPos] == PBE_DOCK_TOP) ? PBE_DOCK_BOTTOM : PBE_DOCK_TOP;
					PBE_RenderEditorDock(playerid, sid);
					PBE_SetCursor(playerid, sid, true);
				}
				case 1:
				{
					EditorSession[sid][EP_DockPos] = PBE_DOCK_HIDDEN;
					PBE_RenderEditorDock(playerid, sid);
					PBE_SendMsg(playerid, PBE_CHAT_INFO, "{38BDF8}Preview: ", "Dock hidden. Click {38BDF8}EDITOR UI{FFFFFF} at top or type {38BDF8}/pbpreview{FFFFFF} to restore.");
					PBE_SetCursor(playerid, sid, true);
				}
				case 2:
				{
					EditorSession[sid][EP_ShowGrid] = !EditorSession[sid][EP_ShowGrid];
					PBE_UpdateGridVisibility(playerid, sid);
					PBE_OpenViewMenu(playerid, sid);
				}
				case 3:
				{
					EditorSession[sid][EP_GridSnapMode] = (EditorSession[sid][EP_GridSnapMode] + 1) % 3;
					PBE_OpenViewMenu(playerid, sid);
				}
				case 4:
				{
					EditorSession[sid][EP_AspectLock] = !EditorSession[sid][EP_AspectLock];
					PBE_OpenViewMenu(playerid, sid);
				}
				case 5: PBE_OpenHelpGuide(playerid);
				case 6:
				{
					if (EditorSession[sid][EP_Dirty] && EditorSession[sid][EP_BarCount] > 0)
					{
						PBE_ShowDialog(playerid, PBE_DLG_EXIT_CONFIRM, DIALOG_STYLE_MSGBOX,
							"{EF4444}Exit Editor with Unsaved Changes?",
							"{FFFFFF}Your workspace has unsaved progress bar changes!\nAre you sure you want to close the Editor without saving?",
							"Exit Now", "Go Back");
					}
					else
					{
						PBE_CloseEditorSession(playerid, sid, false);
						PBE_SendMsg(playerid, PBE_CHAT_INFO, "", "Editor session closed. Type {38BDF8}/pbeditor{FFFFFF} anytime to reopen.");
					}
				}
			}
			return 1;
		}

		case PBE_DLG_EXIT_CONFIRM:
		{
			if (!response)
			{
				PBE_OpenViewMenu(playerid, sid);
				return 1;
			}
			PBE_CloseEditorSession(playerid, sid, false);
			PBE_SendMsg(playerid, PBE_CHAT_INFO, "", "Editor session closed. Type {38BDF8}/pbeditor{FFFFFF} anytime to reopen.");
			return 1;
		}

		case PBE_DLG_HELP_GUIDE:
		{
			PBE_SetCursor(playerid, sid, true);
			return 1;
		}
	}
	return 1;
}

/*
================================================================================
    11. Pawn.CMD Editor Command Suite
================================================================================
*/

cmd:pbeditor(playerid, params[])
{
	#pragma unused params
	PBE_OpenEditorSession(playerid);
	return 1;
}
alias:pbeditor("pbe", "progressbar")

cmd:pbselect(playerid, params[])
{
	#pragma unused params
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		PBE_OpenEditorSession(playerid);
		return 1;
	}
	if (EditorSession[sid][EP_EditMode] != PBE_MODE_NONE)
	{
		PBE_StopTransformMode(playerid, sid, false, true);
	}
	else
	{
		PBE_SetCursor(playerid, sid, true);
	}
	return 1;
}
alias:pbselect("pbcursor")

cmd:pbnew(playerid, params[])
{
	if (!PBE_CheckAccess(playerid)) return 1;
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		if (!PBE_OpenEditorSession(playerid)) return 1;
		sid = PBE_GetSlot(playerid);
	}

	new name[PBE_MAX_PROJECT_NAME];
	PBE_NormalizeProjectName(params, name, sizeof name);
	if (name[0] == '\0')
	{
		PBE_ShowDialog(playerid, PBE_DLG_NEW_NAME, DIALOG_STYLE_INPUT,
			"{38BDF8}New Editor Project",
			"{FFFFFF}Enter a name for your new HUD project:",
			"Create", "Cancel");
		return 1;
	}
	if (PBE_CheckProjectLocked(playerid, sid, name)) return 1;

	PBE_ClearWorkspace(playerid, sid, name);
	PBE_RenderEditorDock(playerid, sid);
	PBE_SetCursor(playerid, sid, true);

	new msg[256];
	format(msg, sizeof msg, "Started fresh workspace project {38BDF8}%s{FFFFFF}.", name);
	PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}New Project: ", msg);
	return 1;
}

cmd:pbload(playerid, params[])
{
	if (!PBE_CheckAccess(playerid)) return 1;
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		if (!PBE_OpenEditorSession(playerid)) return 1;
		sid = PBE_GetSlot(playerid);
	}

	new trimmed[PBE_MAX_PROJECT_NAME + 8];
	PBE_Trim(params, trimmed, sizeof trimmed);
	if (trimmed[0] == '\0')
	{
		PBE_OpenLoadProjectBrowser(playerid, sid, false);
		return 1;
	}
	if (PBE_CheckProjectLocked(playerid, sid, trimmed)) return 1;

	if (PBE_LoadProjectFile(playerid, sid, PBE_DIR_PROJECTS, trimmed, false))
	{
		new msg[256];
		format(msg, sizeof msg, "Loaded project {38BDF8}%s{FFFFFF} (%d bar layers).", EditorSession[sid][EP_ProjectName], EditorSession[sid][EP_BarCount]);
		PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Project Opened: ", msg);
		PBE_SetCursor(playerid, sid, true);
	}
	else
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Not Found: ", "Project .pbp file was not found in 'scriptfiles/Progress Bars/Projects/'.");
	}
	return 1;
}
alias:pbload("pbopen")

cmd:pbsave(playerid, params[])
{
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Editor Inactive: ", "Open the editor first using {38BDF8}/pbeditor{FFFFFF}.");
		return 1;
	}

	new target[PBE_MAX_PROJECT_NAME];
	PBE_NormalizeProjectName(params, target, sizeof target);
	if (target[0] == '\0')
	{
		format(target, sizeof target, "%s", EditorSession[sid][EP_ProjectName]);
	}
	if (PBE_CheckProjectLocked(playerid, sid, target)) return 1;

	if (PBE_SaveProjectFile(playerid, sid, target))
	{
		new msg[256];
		format(msg, sizeof msg, "Saved {38BDF8}%s%s.pbp{FFFFFF} (%d bars).", PBE_DIR_PROJECTS, EditorSession[sid][EP_ProjectName], EditorSession[sid][EP_BarCount]);
		PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Project Saved: ", msg);
	}
	else
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Save Failed: ", "Verify folder 'scriptfiles/Progress Bars/Projects/' exists!");
	}
	return 1;
}

cmd:pbimport(playerid, params[])
{
	if (!PBE_CheckAccess(playerid)) return 1;
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		if (!PBE_OpenEditorSession(playerid)) return 1;
		sid = PBE_GetSlot(playerid);
	}

	new trimmed[64];
	PBE_Trim(params, trimmed, sizeof trimmed);
	if (trimmed[0] == '\0')
	{
		PBE_OpenImportMenu(playerid);
		return 1;
	}

	new count = PBE_ImportPawnCodeFile(playerid, sid, trimmed);
	if (count > 0)
	{
		new msg[256];
		format(msg, sizeof msg, "Imported {38BDF8}%d{FFFFFF} progress bar(s) from {38BDF8}%s{FFFFFF}!", count, trimmed);
		PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Import Complete: ", msg);
		PBE_SetCursor(playerid, sid, true);
	}
	else
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Import Failed: ", "Could not parse CreatePlayerProgressBar calls from that file in Imports/.");
	}
	return 1;
}

cmd:pbexport(playerid, params[])
{
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Editor Inactive: ", "Open the editor first using {38BDF8}/pbeditor{FFFFFF}.");
		return 1;
	}
	if (EditorSession[sid][EP_BarCount] <= 0)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Empty Workspace: ", "Add at least one progress bar before exporting.");
		return 1;
	}

	new trimmed[PBE_MAX_PROJECT_NAME];
	PBE_Trim(params, trimmed, sizeof trimmed);
	if (trimmed[0] == '\0')
	{
		PBE_OpenExportMenu(playerid, sid);
		return 1;
	}
	if (PBE_CheckProjectLocked(playerid, sid, trimmed)) return 1;

	new outPath[PBE_MAX_PATH];
	if (PBE_ExportProjectCode(sid, trimmed, PBE_EXP_GAMEMODE_PWN, outPath, sizeof outPath))
	{
		new msg[256];
		format(msg, sizeof msg, "Exported {10B981}scriptfiles/%s{FFFFFF}!", outPath);
		PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Export Complete: ", msg);
	}
	else
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}Export Failed: ", "Verify folder 'scriptfiles/Progress Bars/Exports/' exists.");
	}
	return 1;
}

cmd:pbadd(playerid, params[])
{
	if (!PBE_CheckAccess(playerid)) return 1;
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		if (!PBE_OpenEditorSession(playerid)) return 1;
		sid = PBE_GetSlot(playerid);
	}

	new arg[16];
	PBE_Trim(params, arg, sizeof arg);
	new style = PB_STYLE_BAR;
	if (!strcmp(arg, "ring", true)) style = PB_STYLE_RING;
	else if (!strcmp(arg, "circle", true)) style = PB_STYLE_CIRCLE;

	PBE_AddNewBar(playerid, sid, style);
	PBE_SetCursor(playerid, sid, true);
	return 1;
}

cmd:pbpreview(playerid, params[])
{
	#pragma unused params
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Editor Inactive: ", "Open the editor first using {38BDF8}/pbeditor{FFFFFF}.");
		return 1;
	}
	EditorSession[sid][EP_DockPos] = (EditorSession[sid][EP_DockPos] == PBE_DOCK_HIDDEN) ? PBE_DOCK_BOTTOM : PBE_DOCK_HIDDEN;
	PBE_RenderEditorDock(playerid, sid);
	return 1;
}

cmd:pbundo(playerid, params[])
{
	#pragma unused params
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION) return 1;
	PBE_PerformUndo(playerid, sid);
	return 1;
}

cmd:pblock(playerid, params[])
{
	#pragma unused params
	if (!IsPlayerAdmin(playerid))
	{
		PBE_SendMsg(playerid, PBE_CHAT_ERR, "{EF4444}RCON Required: ", "Only RCON administrators can toggle the Editor RCON lock.");
		return 1;
	}
	g_PBERconLocked = !g_PBERconLocked;
	if (g_PBERconLocked) PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Security Lock ON: ", "Editor access is now restricted to RCON admins.");
	else PBE_SendMsg(playerid, PBE_CHAT_OK, "{10B981}Security Lock OFF: ", "Editor access is now open to all players.");
	return 1;
}

cmd:pbhelp(playerid, params[])
{
	#pragma unused params
	if (!PBE_CheckAccess(playerid)) return 1;
	new sid = PBE_GetSlot(playerid);
	if (sid != PBE_INVALID_SESSION)
	{
		PBE_OpenHelpGuide(playerid);
	}
	else
	{
		PBE_SendMsg(playerid, PBE_CHAT_BRAND, "", "Cmds: {38BDF8}/pbe /pbselect /pbnew /pbload /pbsave /pbimport /pbexport /pbadd /pbpreview /pbundo /pblock /pbexit");
	}
	return 1;
}

cmd:pbexit(playerid, params[])
{
	#pragma unused params
	new sid = PBE_GetSlot(playerid);
	if (sid == PBE_INVALID_SESSION)
	{
		PBE_SendMsg(playerid, PBE_CHAT_WARN, "{F59E0B}Editor Inactive: ", "You do not have an open Editor session.");
		return 1;
	}
	if (EditorSession[sid][EP_Dirty] && EditorSession[sid][EP_BarCount] > 0)
	{
		PBE_ShowDialog(playerid, PBE_DLG_EXIT_CONFIRM, DIALOG_STYLE_MSGBOX,
			"{EF4444}Exit Editor with Unsaved Changes?",
			"{FFFFFF}Your workspace has unsaved progress bar changes!\nAre you sure you want to close the Editor without saving?",
			"Exit Now", "Cancel");
		return 1;
	}
	PBE_CloseEditorSession(playerid, sid, false);
	PBE_SendMsg(playerid, PBE_CHAT_INFO, "", "Editor session closed. Type {38BDF8}/pbeditor{FFFFFF} anytime to reopen.");
	return 1;
}
alias:pbexit("pbclose")
