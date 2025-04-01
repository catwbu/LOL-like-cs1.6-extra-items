#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <fun>

new g_GravitySpr
new chop[33], cvar_shadow_chop_range, cooltime[33]

public plugin_init() 
{
	register_plugin("狂怒九頭蛇", "1.0", "Cz&zero")

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")

	cvar_shadow_chop_range = register_cvar("shadow_chop_spr_range", "300")
	register_cvar("shadow_chop_range", "300")
	register_cvar("shadow_chop_cooltime", "10")
	register_cvar("shadow_chop_damage", "100")

	register_clcmd("zchop" , "ssa")
}

public plugin_precache()
{
	g_GravitySpr = engfunc(EngFunc_PrecacheModel, "sprites/shockwave.spr")
}

public ssa(id)
{
	if(is_user_alive(id))
	{
		if (!chop[id] && !cooltime[id])
		{
			client_print(id, print_center, "影斬!")
			fm_set_rendering(id, kRenderFxNone,12,3,61,kRenderNormal, 25)
			cooltime[id] = true
			chop[id] = true
			set_task(0.1, "damahuman", id)
			set_task(get_cvar_float("shadow_chop_cooltime"), "offcool", id)
			set_task(1.0, "offchop", id)
		}
	}
}

public damahuman(id)
{
	if (is_user_alive(id) && chop[id])
	{
		set_task(1.0, "damahuman", id)
		fm_set_rendering(id, kRenderFxNone,255,0,0,kRenderNormal, 25)

		new Float:origin[3]
		pev(id, pev_origin, origin)
		create_blast(origin)

		new Float:origin1[3], Float:origin2[3], Float:range
		pev(id, pev_origin, origin1)
		
		for (new i = 1; i <= 32; i++)
		{
			if ((i != id) && is_user_alive(i))
			{
				pev(i, pev_origin, origin2);
				range = get_distance_f(origin1, origin2)
				new manhp = get_user_health(i)

				if (range <= get_cvar_float("shadow_chop_range") && floatabs(origin2[2] - origin1[2]) <= 60.0 && get_user_team(i) == get_user_team(id))
				{
					if(get_user_health(i) > get_cvar_float("shadow_chop_damage"))
					{
						new nhp = floatround(float(manhp) - get_cvar_float("shadow_chop_damage"))
						fm_set_user_health(i,nhp)

					}
					else
						log_kill(id, i, "Shadow Chop!", 1)
				}
			}
		}
		fm_set_rendering(id, kRenderFxNone,12,3,61,kRenderNormal, 25)
	}
}

public offchop(id)
{
	if (chop[id])
	{
		chop[id] = false
	}
}


public offcool(id)
{
	if (cooltime[id])
	{
		cooltime[id] = false
	}
}

public event_NewRound(id)
{
	cooltime[id] = false
	chop[id] = false
	fm_set_rendering(id, kRenderFxNone,0,0,0,kRenderNormal, 25)
}

public event_death()
{
	new id = read_data(2)
	if (!(1 <= id <= 32))
		return;

	cooltime[id] = false
	chop[id] = false
	fm_set_rendering(id, kRenderFxNone,0,0,0,kRenderNormal, 25)
}

stock create_blast(const Float:originF[3])
{
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_BEAMCYLINDER) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	engfunc(EngFunc_WriteCoord, originF[0]) // x axis
	engfunc(EngFunc_WriteCoord, originF[1]) // y axis
	//engfunc(EngFunc_WriteCoord, originF[2]+300.0) // z axis
	engfunc(EngFunc_WriteCoord, originF[2]+(get_pcvar_float(cvar_shadow_chop_range)*2.0/3.0))
	write_short(g_GravitySpr) // sprite
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(5) // life (時間長度)
	write_byte(50) // width
	write_byte(0) // noise
	write_byte(255) // red (顏色 R)
	write_byte(0) // green (顏色 G)
	write_byte(0) // blue (顏色 B)
	write_byte(100) // brightness
	write_byte(9) // speed
	message_end()
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) 
{
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);
	
	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));
	
	return 1;
}

stock fm_set_user_maxspeed(index, Float:speed = -1.0) 
{
	engfunc(EngFunc_SetClientMaxspeed, index, speed);
	set_pev(index, pev_maxspeed, speed);

	return 1;
}

stock fm_set_user_health(index, health) 
{
	health > 0 ? set_pev(index, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, index);

	return 1;
}
stock client_printc(const id, const string[], {Float, Sql, Resul,_}:...)
{
	new msg[191], players[32], count = 1;
	vformat(msg, sizeof msg - 1, string, 3);
	
	replace_all(msg,190,"\g","^4");
	replace_all(msg,255,"\y","^1");
	replace_all(msg,190,"\t","^3");
	
	if(id)
		players[0] = id;
	else
		get_players(players,count,"ch");
	
	new index;
	for (new i = 0 ; i < count ; i++)
	{
		index = players[i];
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"),_, index);
		write_byte(index);
		write_string(msg);
		message_end();  
	}  
}

stock log_kill(killer, victim, weapon[], headshot)
{
	new attacker_frags = get_user_frags(killer)
	
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_SET)
	ExecuteHamB(Ham_Killed, victim, killer, 1) // set last param to 2 if you want victim to gib
	set_msg_block(get_user_msgid("DeathMsg"), BLOCK_NOT)

	message_begin(MSG_BROADCAST, get_user_msgid("DeathMsg"))
	write_byte(killer)
	write_byte(victim)
	write_byte(headshot)
	write_string(weapon)
	message_end()


	attacker_frags += 1

	new kname[32], vname[32], kauthid[32], vauthid[32], kteam[10], vteam[10]

	get_user_name(killer, kname, 31)
	get_user_team(killer, kteam, 9)
	get_user_authid(killer, kauthid, 31)
 
	get_user_name(victim, vname, 31)
	get_user_team(victim, vteam, 9)
	get_user_authid(victim, vauthid, 31)

	log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^"", 
	kname, get_user_userid(killer), kauthid, kteam, 
 	vname, get_user_userid(victim), vauthid, vteam, weapon)

 	return PLUGIN_CONTINUE
}