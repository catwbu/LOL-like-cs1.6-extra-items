#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta>

new speed[33]
new g_speed
new g_weapon

public plugin_init()
{
	server_cmd("sv_maxspeed 9999")
	register_plugin("妖夢鬼刀", "1.0", "Zero")
	register_clcmd("Youmuus_on", "speed_on")
}

public speed_on(id)
{
	if (!is_user_alive(id)) return
	if(speed[id]) return
	
	speed[id] = 1	

	g_speed = get_user_maxspeed(id) 
	g_weapon = get_user_weapon(id) 
	
	set_pev(id, pev_maxspeed, get_user_maxspeed(id) * 1.2)
	
	client_cmd(id, "cl_forwardspeed 9999.0")
	client_cmd(id, "cl_sidespeed 9999.0")
	client_cmd(id, "cl_backspeed 9999.0")
		
	set_task(6.0, "timeover", id)
	client_cmd(id, "spk sound/lol/Youmuus.wav")
}

public timeover(id)
{
	speed[id] = 0
	if(get_user_weapon(id) == g_weapon)
	set_pev(id, pev_maxspeed, g_speed)
}
