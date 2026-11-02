/*
================================================================================
    Progress Bar Plus - Editor (Test Server Gamemode)
    Lightweight, plug-and-play sandbox gamemode designed for testing and
    designing HUDs with FS_ProgressBarEditor on SA-MP and open.mp.

    File:        GM_ProgressBarEditor.pwn
    Author:      Walter Corrêa
    Version:     2.1.0
    Repository:  https://github.com/Walter-Correa/Progress-Bar-Plus
    License:     Mozilla Public License 2.0 (MPL-2.0)

    Dependencies:
    - Pawn.CMD by urShadow (https://github.com/urShadow/Pawn.CMD)
================================================================================
*/

#if !defined _samp_included && !defined _INC_open_mp
	#if __Pawn >= 0x030A
		#tryinclude <open.mp>
	#endif
	#if !defined _INC_open_mp
		#include <a_samp>
	#endif
#endif

#include <Pawn.CMD>

/*
================================================================================
    1. Configuration & Cross-Platform Compatibility Macros
================================================================================
*/

#define GM_VERSION              "2.1.0"
#define GM_DLG_SANDBOX_HELP     (28390)

#define GM_DEFAULT_SKIN         (299)
#define GM_DEFAULT_SPAWN_X      (836.0500)
#define GM_DEFAULT_SPAWN_Y      (-1832.1500)
#define GM_DEFAULT_SPAWN_Z      (12.6000)
#define GM_DEFAULT_SPAWN_A      (0.0000)
#define GM_DEFAULT_TIME_HOUR    (12)
#define GM_DEFAULT_WEATHER      (1)
#define GM_DEFAULT_CASH         (50000)

#define GM_COL_BRAND            (0x38BDF8FF)
#define GM_COL_OK               (0x10B981FF)
#define GM_COL_WARN             (0xF59E0BFF)
#define GM_COL_ERR              (0xEF4444FF)
#define GM_COL_INFO             (0x94A3B8FF)

#if defined _INC_open_mp
	#define GM_BOOL(%0)         (bool:(%0))
	#define GM_DLG_STYLE        DIALOG_STYLE:
	#define GM_NO_WEAPON        WEAPON_FIST
	#define GM_WEAPON_TAG       WEAPON:
#else
	#define GM_BOOL(%0)         (_:(%0))
	#define GM_DLG_STYLE
	#define GM_NO_WEAPON        (0)
	#define GM_WEAPON_TAG
#endif

#if !defined PLAYER_MARKERS_MODE_GLOBAL
	#define PLAYER_MARKERS_MODE_GLOBAL (1)
#endif

#if !defined DIALOG_STYLE_TABLIST_HEADERS
	#define DIALOG_STYLE_TABLIST_HEADERS (5)
#endif

/*
================================================================================
    2. Sandbox Data & Preset Presets
================================================================================
*/

enum E_GM_BACKDROP
{
	Backdrop_Name[40],
	Float:Backdrop_X,
	Float:Backdrop_Y,
	Float:Backdrop_Z,
	Float:Backdrop_A,
	Backdrop_Interior,
	Backdrop_Hour,
	Backdrop_Weather
};

static const g_Backdrops[][E_GM_BACKDROP] =
{
	{"Verona Beach Promenade (LS)",    836.0500, -1832.1500,   12.6000,   0.0000, 0, 12, 1},
	{"Las Venturas Airport Runway",   1588.8000,  1447.8000,   10.8300, 180.0000, 0, 12, 1},
	{"Mount Chiliad Sky Summit",     -2317.8000, -1636.9000,  483.7000, 270.0000, 0, 14, 0},
	{"Dark Night Contrast Backdrop",   836.0500, -1832.1500,   12.6000,   0.0000, 0,  0, 0}
};

enum E_GM_VEH_PRESET
{
	Veh_Alias[20],
	Veh_ModelID
};

static const g_QuickVehicles[][E_GM_VEH_PRESET] =
{
	{"infernus", 411},
	{"sultan",   560},
	{"elegy",    562},
	{"turismo",  451},
	{"bullet",   541},
	{"cheetah",  415},
	{"banshee",  429},
	{"nrg",      522},
	{"fcr",      521},
	{"sanchez",  468},
	{"maverick", 487},
	{"hydra",    520}
};

static g_PlayerTestVeh[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};
static g_PlayerSkin[MAX_PLAYERS]    = {GM_DEFAULT_SKIN, ...};
static bool:g_PlayerInitHUD[MAX_PLAYERS];
static s_HelpBody[2048];

/*
================================================================================
    3. Internal Sandbox Helpers
================================================================================
*/

static stock GM_Trim(const src[], dest[], maxLen = sizeof dest)
{
	new len = strlen(src);
	new start = 0;
	while (start < len && src[start] <= ' ') start++;

	new end = len - 1;
	while (end >= start && src[end] <= ' ') end--;

	new outIdx = 0;
	for (new i = start; i <= end && outIdx < maxLen - 1; i++)
	{
		dest[outIdx++] = src[i];
	}
	dest[outIdx] = '\0';
}

static stock bool:GM_IsNumeric(const str[])
{
	if (str[0] == '\0') return false;
	new i = 0;
	if (str[0] == '-' || str[0] == '+')
	{
		i = 1;
		if (str[1] == '\0') return false;
	}
	for (; str[i] != '\0'; i++)
	{
		if (str[i] < '0' || str[i] > '9') return false;
	}
	return true;
}

static stock GM_DestroyPlayerTestVehicle(playerid)
{
	if (!(0 <= playerid < MAX_PLAYERS)) return;
	if (g_PlayerTestVeh[playerid] != INVALID_VEHICLE_ID)
	{
		DestroyVehicle(g_PlayerTestVeh[playerid]);
		g_PlayerTestVeh[playerid] = INVALID_VEHICLE_ID;
	}
}

static stock GM_ResolveVehicleModel(const input[])
{
	if (input[0] == '\0') return 411;
	if (GM_IsNumeric(input))
	{
		new model = strval(input);
		return (400 <= model <= 611) ? model : 0;
	}
	for (new i = 0; i < sizeof g_QuickVehicles; i++)
	{
		if (!strcmp(input, g_QuickVehicles[i][Veh_Alias], true))
		{
			return g_QuickVehicles[i][Veh_ModelID];
		}
	}
	return 0;
}

static stock GM_ShowSandboxHelp(playerid)
{
	s_HelpBody[0] = '\0';
	strcat(s_HelpBody, "Command\tDescription\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{38BDF8}/pbeditor (/pbe)\t{FFFFFF}Open Progress Bar Plus - Editor Dock\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{38BDF8}/pbhelp\t{FFFFFF}Open Editor Reference Manual & Hotkeys\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{10B981}/veh [id/name] (/v)\t{FFFFFF}Spawn a test vehicle (e.g. /v, /v sultan, /v nrg)\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{10B981}/fix (/repair)\t{FFFFFF}Repair and flip your current vehicle\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{10B981}/delveh (/dv)\t{FFFFFF}Remove your spawned test vehicle\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{F59E0B}/loc <1-4> (/backdrop)\t{FFFFFF}Switch HUD testing location & lighting backdrop\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{F59E0B}/time <0-23>\t{FFFFFF}Change clock hour (12 = bright day, 0 = dark night)\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{F59E0B}/weather <0-45>\t{FFFFFF}Change weather ID (1 = sunny, 8 = storm, 9 = fog)\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{38BDF8}/hp <1-100>\t{FFFFFF}Set health value (test against GTA Health bar)\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{38BDF8}/armour <0-100>\t{FFFFFF}Set armour value (0 hides native GTA Armour bar)\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{38BDF8}/money <amount>\t{FFFFFF}Set cash value (test below GTA Money readout)\n", sizeof s_HelpBody);
	strcat(s_HelpBody, "{38BDF8}/skin <0-311>\t{FFFFFF}Change character skin model", sizeof s_HelpBody);

	ShowPlayerDialog(
		playerid,
		GM_DLG_SANDBOX_HELP,
		GM_DLG_STYLE DIALOG_STYLE_TABLIST_HEADERS,
		"{38BDF8}PB Editor Sandbox {FFFFFF}- Test Server Commands",
		s_HelpBody,
		"Close",
		""
	);
}

/*
================================================================================
    4. Core Gamemode Callbacks
================================================================================
*/

main()
{
	print("======================================================================");
	print("  Progress Bar Plus - Editor Test Server (" GM_VERSION ") loaded!");
	print("  Gamemode: GM_ProgressBarEditor | Author: Walter Correa");
	print("  Repository: https://github.com/Walter-Correa/Progress-Bar-Plus");
	print("======================================================================");
}

public OnGameModeInit()
{
	SetGameModeText("Progress Bar Plus v" GM_VERSION);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(GM_BOOL(true));
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(GM_BOOL(false));
	SetWorldTime(GM_DEFAULT_TIME_HOUR);
	SetWeather(GM_DEFAULT_WEATHER);

	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		g_PlayerTestVeh[i] = INVALID_VEHICLE_ID;
		g_PlayerSkin[i]    = GM_DEFAULT_SKIN;
		g_PlayerInitHUD[i] = false;
	}

	AddPlayerClass(
		GM_DEFAULT_SKIN,
		GM_DEFAULT_SPAWN_X,
		GM_DEFAULT_SPAWN_Y,
		GM_DEFAULT_SPAWN_Z,
		GM_DEFAULT_SPAWN_A,
		GM_NO_WEAPON, 0,
		GM_NO_WEAPON, 0,
		GM_NO_WEAPON, 0
	);
	return 1;
}

public OnGameModeExit()
{
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		GM_DestroyPlayerTestVehicle(i);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	if (0 <= playerid < MAX_PLAYERS)
	{
		g_PlayerTestVeh[playerid] = INVALID_VEHICLE_ID;
		g_PlayerSkin[playerid]    = GM_DEFAULT_SKIN;
		g_PlayerInitHUD[playerid] = false;
	}
	SetPlayerTime(playerid, GM_DEFAULT_TIME_HOUR, 0);
	SetPlayerWeather(playerid, GM_DEFAULT_WEATHER);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	#pragma unused reason
	GM_DestroyPlayerTestVehicle(playerid);
	if (0 <= playerid < MAX_PLAYERS)
	{
		g_PlayerInitHUD[playerid] = false;
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	#pragma unused classid
	new skin = (0 <= playerid < MAX_PLAYERS) ? g_PlayerSkin[playerid] : GM_DEFAULT_SKIN;
	SetSpawnInfo(
		playerid,
		0,
		skin,
		GM_DEFAULT_SPAWN_X,
		GM_DEFAULT_SPAWN_Y,
		GM_DEFAULT_SPAWN_Z,
		GM_DEFAULT_SPAWN_A,
		GM_NO_WEAPON, 0,
		GM_NO_WEAPON, 0,
		GM_NO_WEAPON, 0
	);
	SpawnPlayer(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerPos(playerid, GM_DEFAULT_SPAWN_X, GM_DEFAULT_SPAWN_Y, GM_DEFAULT_SPAWN_Z);
	SetPlayerFacingAngle(playerid, GM_DEFAULT_SPAWN_A);
	SetCameraBehindPlayer(playerid);

	SetPlayerHealth(playerid, 100.0);
	SetPlayerArmour(playerid, 100.0);

	if (0 <= playerid < MAX_PLAYERS && !g_PlayerInitHUD[playerid])
	{
		g_PlayerInitHUD[playerid] = true;
		ResetPlayerMoney(playerid);
		GivePlayerMoney(playerid, GM_DEFAULT_CASH);
		SendClientMessage(playerid, GM_COL_INFO, "{94A3B8}[Sandbox]{FFFFFF} Test environment ready. Type {38BDF8}/gmhelp{FFFFFF} for vehicle, lighting, and HUD test commands.");
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, GM_WEAPON_TAG reason)
{
	#pragma unused killerid, reason
	SetSpawnInfo(
		playerid,
		0,
		(0 <= playerid < MAX_PLAYERS) ? g_PlayerSkin[playerid] : GM_DEFAULT_SKIN,
		GM_DEFAULT_SPAWN_X,
		GM_DEFAULT_SPAWN_Y,
		GM_DEFAULT_SPAWN_Z,
		GM_DEFAULT_SPAWN_A,
		GM_NO_WEAPON, 0,
		GM_NO_WEAPON, 0,
		GM_NO_WEAPON, 0
	);
	return 1;
}

/*
================================================================================
    5. Sandbox Test Commands (Pawn.CMD)
================================================================================
*/

cmd:gmhelp(playerid, params[])
{
	#pragma unused params
	GM_ShowSandboxHelp(playerid);
	return 1;
}
alias:gmhelp("sandbox")

cmd:veh(playerid, params[])
{
	new arg[32];
	GM_Trim(params, arg, sizeof arg);

	new model = GM_ResolveVehicleModel(arg);
	if (model == 0)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Invalid vehicle! Use model ID {38BDF8}400-611{FFFFFF} or names like {38BDF8}infernus, sultan, elegy, nrg{FFFFFF}.");
		return 1;
	}

	new Float:x, Float:y, Float:z, Float:a;
	GetPlayerPos(playerid, x, y, z);
	if (IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	else
	{
		GetPlayerFacingAngle(playerid, a);
	}

	GM_DestroyPlayerTestVehicle(playerid);

	new vehid = CreateVehicle(model, x, y, z + 0.6, a, 1, 1, -1, GM_BOOL(false));
	if (vehid == INVALID_VEHICLE_ID || vehid == 0)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Failed to create test vehicle.");
		return 1;
	}

	g_PlayerTestVeh[playerid] = vehid;
	LinkVehicleToInterior(vehid, GetPlayerInterior(playerid));
	SetVehicleVirtualWorld(vehid, GetPlayerVirtualWorld(playerid));
	PutPlayerInVehicle(playerid, vehid, 0);

	new msg[144];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Spawned test vehicle model {38BDF8}%d{FFFFFF}. Use {38BDF8}/fix{FFFFFF} to repair or {38BDF8}/dv{FFFFFF} to remove.", model);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}
alias:veh("v")

cmd:delveh(playerid, params[])
{
	#pragma unused params
	if (g_PlayerTestVeh[playerid] == INVALID_VEHICLE_ID)
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} You do not have an active test vehicle.");
		return 1;
	}
	GM_DestroyPlayerTestVehicle(playerid);
	SendClientMessage(playerid, GM_COL_OK, "{10B981}[Sandbox]{FFFFFF} Test vehicle removed.");
	return 1;
}
alias:delveh("dv")

cmd:fix(playerid, params[])
{
	#pragma unused params
	new vehid = GetPlayerVehicleID(playerid);
	if (vehid == 0)
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} You must be inside a vehicle to repair it.");
		return 1;
	}
	RepairVehicle(vehid);
	new Float:a;
	GetVehicleZAngle(vehid, a);
	SetVehicleZAngle(vehid, a);
	SendClientMessage(playerid, GM_COL_OK, "{10B981}[Sandbox]{FFFFFF} Vehicle repaired and uprighted.");
	return 1;
}
alias:fix("repair")

cmd:time(playerid, params[])
{
	new arg[16];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/time <0-23>{FFFFFF} (e.g. 12 = bright noon, 0 = dark midnight).");
		return 1;
	}
	new hour = strval(arg);
	if (hour < 0 || hour > 23)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Hour must be between 0 and 23.");
		return 1;
	}
	SetPlayerTime(playerid, hour, 0);

	new msg[128];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Clock set to {38BDF8}%02d:00{FFFFFF}.", hour);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}

cmd:weather(playerid, params[])
{
	new arg[16];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/weather <0-45>{FFFFFF} (e.g. 1 = sunny, 8 = storm, 9 = foggy).");
		return 1;
	}
	new wid = strval(arg);
	if (wid < 0 || wid > 45)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Weather ID must be between 0 and 45.");
		return 1;
	}
	SetPlayerWeather(playerid, wid);

	new msg[128];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Weather changed to ID {38BDF8}%d{FFFFFF}.", wid);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}

cmd:hp(playerid, params[])
{
	new arg[16];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/hp <1-100>{FFFFFF}.");
		return 1;
	}
	new val = strval(arg);
	if (val < 1 || val > 100)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Health value must be between 1 and 100.");
		return 1;
	}
	SetPlayerHealth(playerid, float(val));

	new msg[128];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Health set to {38BDF8}%d{FFFFFF}.", val);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}

cmd:armour(playerid, params[])
{
	new arg[16];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/armour <0-100>{FFFFFF} (0 hides native GTA Armour bar).");
		return 1;
	}
	new val = strval(arg);
	if (val < 0 || val > 100)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Armour value must be between 0 and 100.");
		return 1;
	}
	SetPlayerArmour(playerid, float(val));

	new msg[128];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Armour set to {38BDF8}%d{FFFFFF}.", val);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}
alias:armour("armor")

cmd:money(playerid, params[])
{
	new arg[24];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/money <amount>{FFFFFF}.");
		return 1;
	}
	new amount = strval(arg);
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, amount);

	new msg[128];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Cash readout set to {38BDF8}$%d{FFFFFF}.", amount);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}
alias:money("cash")

cmd:skin(playerid, params[])
{
	new arg[16];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/skin <0-311>{FFFFFF}.");
		return 1;
	}
	new skin = strval(arg);
	if (skin < 0 || skin > 311 || skin == 74)
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Skin ID must be between 0 and 311 (excluding 74).");
		return 1;
	}
	if (0 <= playerid < MAX_PLAYERS) g_PlayerSkin[playerid] = skin;
	SetPlayerSkin(playerid, skin);

	new msg[128];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Skin changed to ID {38BDF8}%d{FFFFFF}.", skin);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}

cmd:loc(playerid, params[])
{
	new arg[16];
	GM_Trim(params, arg, sizeof arg);
	if (!GM_IsNumeric(arg))
	{
		SendClientMessage(playerid, GM_COL_WARN, "{F59E0B}[Sandbox]{FFFFFF} Usage: {38BDF8}/loc <1-4>{FFFFFF} (1: Beach LS | 2: LV Runway | 3: Mt. Chiliad | 4: Dark Night).");
		return 1;
	}
	new idx = strval(arg) - 1;
	if (!(0 <= idx < sizeof g_Backdrops))
	{
		SendClientMessage(playerid, GM_COL_ERR, "{EF4444}[Sandbox]{FFFFFF} Choose a backdrop ID from {38BDF8}1 to 4{FFFFFF}.");
		return 1;
	}

	SetPlayerInterior(playerid, g_Backdrops[idx][Backdrop_Interior]);
	SetPlayerTime(playerid, g_Backdrops[idx][Backdrop_Hour], 0);
	SetPlayerWeather(playerid, g_Backdrops[idx][Backdrop_Weather]);

	new vehid = GetPlayerVehicleID(playerid);
	if (vehid != 0 && GetPlayerState(playerid) == PLAYER_STATE_DRIVER && g_Backdrops[idx][Backdrop_Interior] == 0)
	{
		LinkVehicleToInterior(vehid, g_Backdrops[idx][Backdrop_Interior]);
		SetVehiclePos(vehid, g_Backdrops[idx][Backdrop_X], g_Backdrops[idx][Backdrop_Y], g_Backdrops[idx][Backdrop_Z] + 0.6);
		SetVehicleZAngle(vehid, g_Backdrops[idx][Backdrop_A]);
	}
	else
	{
		SetPlayerPos(playerid, g_Backdrops[idx][Backdrop_X], g_Backdrops[idx][Backdrop_Y], g_Backdrops[idx][Backdrop_Z]);
		SetPlayerFacingAngle(playerid, g_Backdrops[idx][Backdrop_A]);
		SetCameraBehindPlayer(playerid);
	}

	new msg[144];
	format(msg, sizeof msg, "{10B981}[Sandbox]{FFFFFF} Teleported to backdrop #{38BDF8}%d{FFFFFF}: {38BDF8}%s{FFFFFF}.", idx + 1, g_Backdrops[idx][Backdrop_Name]);
	SendClientMessage(playerid, GM_COL_OK, msg);
	return 1;
}
alias:loc("backdrop")
