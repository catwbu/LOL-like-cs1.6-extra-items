#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <fun>
#include <hamsandwich>

// Plugin Version
// Ham weapon const
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX_WEAPONS = 4

new g_bAllowATK[33] // allow to attack
new Float:g_flLastBlink[33] // last blink time
// Game vars
new g_iBlinkIndex // index from the class

// Message IDs vars
new g_msgSayText

// Sprites
new g_iShockwave//, g_iFlare
// Cvar pointers
new cvar_Cooldown, cvar_Range, cvar_NoAttack

new stuck[33]

new cvar[3]

new const Float:size[][3] = {
	{0.0, 0.0, 1.0}, {0.0, 0.0, -1.0}, {0.0, 1.0, 0.0}, {0.0, -1.0, 0.0}, {1.0, 0.0, 0.0}, {-1.0, 0.0, 0.0}, {-1.0, 1.0, 1.0}, {1.0, 1.0, 1.0}, {1.0, -1.0, 1.0}, {1.0, 1.0, -1.0}, {-1.0, -1.0, 1.0}, {1.0, -1.0, -1.0}, {-1.0, 1.0, -1.0}, {-1.0, -1.0, -1.0},
	{0.0, 0.0, 2.0}, {0.0, 0.0, -2.0}, {0.0, 2.0, 0.0}, {0.0, -2.0, 0.0}, {2.0, 0.0, 0.0}, {-2.0, 0.0, 0.0}, {-2.0, 2.0, 2.0}, {2.0, 2.0, 2.0}, {2.0, -2.0, 2.0}, {2.0, 2.0, -2.0}, {-2.0, -2.0, 2.0}, {2.0, -2.0, -2.0}, {-2.0, 2.0, -2.0}, {-2.0, -2.0, -2.0},
	{0.0, 0.0, 3.0}, {0.0, 0.0, -3.0}, {0.0, 3.0, 0.0}, {0.0, -3.0, 0.0}, {3.0, 0.0, 0.0}, {-3.0, 0.0, 0.0}, {-3.0, 3.0, 3.0}, {3.0, 3.0, 3.0}, {3.0, -3.0, 3.0}, {3.0, 3.0, -3.0}, {-3.0, -3.0, 3.0}, {3.0, -3.0, -3.0}, {-3.0, 3.0, -3.0}, {-3.0, -3.0, -3.0},
	{0.0, 0.0, 4.0}, {0.0, 0.0, -4.0}, {0.0, 4.0, 0.0}, {0.0, -4.0, 0.0}, {4.0, 0.0, 0.0}, {-4.0, 0.0, 0.0}, {-4.0, 4.0, 4.0}, {4.0, 4.0, 4.0}, {4.0, -4.0, 4.0}, {4.0, 4.0, -4.0}, {-4.0, -4.0, 4.0}, {4.0, -4.0, -4.0}, {-4.0, 4.0, -4.0}, {-4.0, -4.0, -4.0},
	{0.0, 0.0, 5.0}, {0.0, 0.0, -5.0}, {0.0, 5.0, 0.0}, {0.0, -5.0, 0.0}, {5.0, 0.0, 0.0}, {-5.0, 0.0, 0.0}, {-5.0, 5.0, 5.0}, {5.0, 5.0, 5.0}, {5.0, -5.0, 5.0}, {5.0, 5.0, -5.0}, {-5.0, -5.0, 5.0}, {5.0, -5.0, -5.0}, {-5.0, 5.0, -5.0}, {-5.0, -5.0, -5.0}
}

new const flashSound[][] =
{
	"lol/flash_start1.wav", 
	"lol/flash_start2.wav",
	"lol/flash_start3.wav"
}
new const plusSound[][] =
{
	"lol/flash_over1.wav", 
	"lol/flash_over2.wav",
	"lol/flash_over3.wav"
}

public plugin_precache()
{
	register_plugin("FLASH","1.0", "schmurgel1983&zero")
	g_iShockwave = precache_model( "sprites/shockwave.spr")
	//g_iFlare = precache_model( "sprites/blueflare2.spr")
		
	for(new i=0 ; i < sizeof(flashSound) ; i++)
	{
		precache_sound( flashSound[i] )
	}
	
	for(new i=0 ; i < sizeof(plusSound) ; i++)
	{
		precache_sound( plusSound[i] )
	}
}

public plugin_init()
{
//	register_forward(FM_CmdStart, "fwd_CmdStart")
	g_msgSayText = get_user_msgid("SayText")
//	g_msgScreenFade = get_user_msgid("ScreenFade")
	cvar_Cooldown = register_cvar("zp_blink_cooldown", "0.0")
	cvar_NoAttack = register_cvar("zp_blink_no_atk_time", "0.0")
	cvar_Range = register_cvar("zp_blink_range", "500")
	
	register_clcmd("flash_use", "fwd_CmdStart")
	
	
	
	cvar[0] = register_cvar("amx_autounstuck","1")
	cvar[1] = register_cvar("amx_autounstuckeffects","1")
	cvar[2] = register_cvar("amx_autounstuckwait","7")
	
}

public client_putinserver(id) reset_vars(id)
public client_disconnected(id) reset_vars(id)

public fwd_CmdStart(id, handle)
{
	if (!is_user_alive(id) || get_gametime() < g_flLastBlink[id]) return


	
		if (teleport(id))
		{
			//emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
			
			
			g_bAllowATK[id] = false
			g_flLastBlink[id] = get_gametime() + get_pcvar_float(cvar_Cooldown)
			
			remove_task(id)
			set_task(get_pcvar_float(cvar_NoAttack), "allow_attack", id)
			//set_task(get_pcvar_float(cvar_Cooldown), "show_blink", id)
		}
		else
		{
			g_flLastBlink[id] = get_gametime() + 1.0
			
			colored_print(id, "^x04[閃現]^x01 無法使用.")
		}
	
}

public allow_attack(id)
{
	if (!is_user_connected(id)) return
	
	g_bAllowATK[id] = true
}

reset_vars(id)
{
	remove_task(id)

	g_bAllowATK[id] = true
}
/*
public show_blink(id)
{
	if (!is_user_connected(id) || !is_user_alive(id)) return
	/*
	if (!get_pcvar_num(cvar_Button))
		colored_print(id, "^x04[閃現]^x01 按E可進行傳送.")
	else
		colored_print(id, "^x04[閃現]^x01 按R可進行傳送.")
}*/

bool:teleport(id)
{
	new	Float:vOrigin[3], Float:vNewOrigin[3],
	Float:vNormal[3], Float:vTraceDirection[3],
	Float:vTraceEnd[3]
	
	pev(id, pev_origin, vOrigin)
	
	velocity_by_aim(id, get_pcvar_num(cvar_Range), vTraceDirection)
	xs_vec_add(vTraceDirection, vOrigin, vTraceEnd)
	
	engfunc(EngFunc_TraceLine, vOrigin, vTraceEnd, DONT_IGNORE_MONSTERS, id, 0)
	
	new Float:flFraction
	get_tr2(0, TR_flFraction, flFraction)
	if (flFraction < 1.0)
	{
		get_tr2(0, TR_vecEndPos, vTraceEnd)
		get_tr2(0, TR_vecPlaneNormal, vNormal)
	}
	
	xs_vec_mul_scalar(vNormal, 40.0, vNormal) // do not decrease the 40.0
	xs_vec_add(vTraceEnd, vNormal, vNewOrigin)
	
	//if (is_player_stuck(id, vNewOrigin))
		set_task(0.1,"checkstuck",0,"",0,"b")
	emit_sound(id, CHAN_STATIC, flashSound[random_num(0, 3)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	//	return false;	
	//emit_sound(id, CHAN_STATIC, SOUND_BLINK, 1.0, ATTN_NORM, 0, PITCH_NORM)
	tele_effect(vOrigin)
	
	engfunc(EngFunc_SetOrigin, id, vNewOrigin)
	
	tele_effect2(vNewOrigin)
	/*
	emessage_begin(MSG_ONE_UNRELIABLE, g_msgScreenFade, _, id)
	ewrite_short(floatround(UNIT_SEC*get_pcvar_float(cvar_NoAttack)))
	ewrite_short(floatround(UNIT_SEC*get_pcvar_float(cvar_NoAttack)))
	ewrite_short(FFADE)
	ewrite_byte(0)
	ewrite_byte(0)
	ewrite_byte(0)
	ewrite_byte(255)
	emessage_end() */
	
	return true;
}

colored_print(target, const message[], any:...)
{
	static buffer[512]
	
	vformat(buffer, charsmax(buffer), message, 3)
	
	message_begin(MSG_ONE, g_msgSayText, _, target)
	write_byte(target)
	write_string(buffer)
	message_end()
}

/*================================================================================
 [Stocks]
=================================================================================*/

stock is_player_stuck(id, Float:originF[3])
{
	engfunc(EngFunc_TraceHull, originF, originF, 0, (pev(id, pev_flags) & FL_DUCKING) ? HULL_HEAD : HULL_HUMAN, id, 0)
	
	if (get_tr2(0, TR_StartSolid) || get_tr2(0, TR_AllSolid) || !get_tr2(0, TR_InOpen))
		return true;
	
	return false;
}

stock ham_cs_get_weapon_ent_owner(entity)
{
	return get_pdata_cbase(entity, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS);
}

stock tele_effect(const Float:torigin[3])
{
	new origin[3]
	origin[0] = floatround(torigin[0])
	origin[1] = floatround(torigin[1])
	origin[2] = floatround(torigin[2])
	//emit_sound(origin[0], CHAN_STATIC, plusSound[random_num(0, 3)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+60)
	write_short(g_iShockwave)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(60)
	write_byte(0)
	write_byte(255)//
	write_byte(255)
	write_byte(0)//
	write_byte(255)
	write_byte(0)
	message_end()
}

stock tele_effect2(const Float:torigin[3])
{
	
	new origin[3]
	origin[0] = floatround(torigin[0])
	origin[1] = floatround(torigin[1])
	origin[2] = floatround(torigin[2])
	
	message_begin(MSG_PAS, SVC_TEMPENTITY, origin)
	write_byte(TE_BEAMCYLINDER)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+10)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+60)
	write_short(g_iShockwave)
	write_byte(0)
	write_byte(0)
	write_byte(3)
	write_byte(60)
	write_byte(0)
	write_byte(255)//
	write_byte(255)
	write_byte(0)//
	write_byte(255)
	write_byte(0)
	message_end()
	/*
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_SPRITETRAIL)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+40)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_iFlare)
	write_byte(30)
	write_byte(10)
	write_byte(1)
	write_byte(50)
	write_byte(10)
	message_end() */
}

//UNSTUCK

public checkstuck() {
	if(get_pcvar_num(cvar[0]) >= 1) {
		static players[32], pnum, player
		get_players(players, pnum)
		static Float:origin[3]
		static Float:mins[3], hull
		static Float:vec[3]
		static o,i
		for(i=0; i<pnum; i++){
			player = players[i]
			if (is_user_connected(player) && is_user_alive(player)) {
				pev(player, pev_origin, origin)
				hull = pev(player, pev_flags) & FL_DUCKING ? HULL_HEAD : HULL_HUMAN
				if (!is_hull_vacant(origin, hull,player) && !get_user_noclip(player) && !(pev(player,pev_solid) & SOLID_NOT)) {
					++stuck[player]
					if(stuck[player] >= get_pcvar_num(cvar[2])) {
						pev(player, pev_mins, mins)
						vec[2] = origin[2]
						for (o=0; o < sizeof size; ++o) {
							vec[0] = origin[0] - mins[0] * size[o][0]
							vec[1] = origin[1] - mins[1] * size[o][1]
							vec[2] = origin[2] - mins[2] * size[o][2]
							if (is_hull_vacant(vec, hull,player)) {
								engfunc(EngFunc_SetOrigin, player, vec)
								//effects(player)
								set_pev(player,pev_velocity,{0.0,0.0,0.0})
								o = sizeof size
							}
						}
					}
				}
				else
				{
					stuck[player] = 0
				}
			}
		}
	}
}

stock bool:is_hull_vacant(const Float:origin[3], hull,id) {
	static tr
	engfunc(EngFunc_TraceHull, origin, origin, 0, hull, id, tr)
	if (!get_tr2(tr, TR_StartSolid) || !get_tr2(tr, TR_AllSolid)) //get_tr2(tr, TR_InOpen))
		return true
	
	return false
}
/*
public effects(id) {
	if(get_pcvar_num(cvar[1])) {
		set_hudmessage(255,150,50, -1.0, 0.65, 0, 6.0, 1.5,0.1,0.7) // HUDMESSAGE
		show_hudmessage(id,"Fuiste destrabado.") // HUDMESSAGE
		message_begin(MSG_ONE_UNRELIABLE,105,{0,0,0},id )      
		write_short(1<<10)   // fade lasts this long duration
		write_short(1<<10)   // fade lasts this long hold time
		write_short(1<<1)   // fade type (in / out)
		write_byte(20)            // fade red
		write_byte(255)    // fade green
		write_byte(255)        // fade blue
		write_byte(255)    // fade alpha
		message_end()
		client_cmd(id,"spk fvox/blip.wav")
	}
}
*/
