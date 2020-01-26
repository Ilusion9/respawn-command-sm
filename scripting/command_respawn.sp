#include <sourcemod>
#include <cstrike>
#include <colorlib>

#pragma newdecls required

public Plugin myinfo =
{
	name = "Respawn Command",
	author = "Ilusion9",
	description = "Respawn command with delay",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

ConVar g_Cvar_DelayTime;
float g_TimeSpawn[MAXPLAYERS + 1];
float g_TimeDisplayMsg[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("command_respawn.phrases");
	g_Cvar_DelayTime = CreateConVar("sm_cmd_respawn_delay", "10", "After how many seconds players can use the respawn command again?", 0, true, 0.0);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	RegConsoleCmd("sm_respawn", Command_Respawn);
	
	AutoExecConfig(true, "command_respawn");
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client)
	{
		return;
	}
	
	float gameTime = GetGameTime();
	g_TimeSpawn[client] = gameTime;
	g_TimeDisplayMsg[client] = gameTime;
}

public Action Command_Respawn(int client, int args)
{
	if (!client || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	if (g_Cvar_DelayTime.BoolValue)
	{
		float gameTime = GetGameTime();
		float commandDelay = g_TimeSpawn[client] + g_Cvar_DelayTime.FloatValue - gameTime;
		
		if (commandDelay > 0.0)
		{
			if (gameTime - g_TimeDisplayMsg[client] >= 1.0)
			{				
				CPrintToChat(client, "%t", "Respawn Delay", commandDelay);
				g_TimeDisplayMsg[client] = gameTime;
			}
			
			return Plugin_Handled;
		}
	}
	
	CS_RespawnPlayer(client);
	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (IsChatTrigger())
	{
		if (StrEqual(sArgs[1], "respawn", true) || StrEqual(sArgs[1], "sm_respawn", true))
		{
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}
