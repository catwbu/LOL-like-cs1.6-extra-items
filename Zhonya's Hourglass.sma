#include <amxmodx>
#include <fakemeta>

public plugin_init()
{
	register_plugin("Zhonya's Hourglass", "1.0", "zhiJIaN&Zero")
	register_clcmd("gold_use", "gold_use")
}

new gGodmod[33]
new gHourglass[33]

stock ScreenFadeColor(id,r, g, b,time)
{
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
	write_short( 1<<10 )
	write_short( (1<<10) * time)
	write_short( 1<<12 )
	write_byte( r )
	write_byte( g )
	write_byte( b )
	write_byte( 125 )
	message_end()
}

stock fm_set_frozen(id, flag){
	if(!flag){
		set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_FROZEN)
	}else {
		set_pev(id, pev_flags, pev(id, pev_flags) | FL_FROZEN)
		set_pev(id, pev_velocity, Float:{0.0,0.0,0.0})
	}
}
stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	if (!pev_valid(entity))
		return

	new Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}
public bind(id)
{
	gGodmod[id] = 0
	gHourglass[id] = 0

}

new Float:Presstime[33]
public gold_use(id)
{
	if(!is_user_alive(id)) return FMRES_IGNORED
	if(get_gametime() - Presstime[id] < 0.5) return FMRES_IGNORED
	
		Presstime[id] = get_gametime()
		if(!gHourglass[id])
		{ //中婭沙漏
			gHourglass[id] = 1
			hourglass(id)
		}
	
	return FMRES_IGNORED
}
hourglass(id){
	gGodmod[id] = 1
	set_task(2.5, "task_godmod_over", id)
	fm_set_frozen(id, 1)
	fm_set_rendering(id, kRenderFxGlowShell, 250, 250, 0, kRenderNormal, 25)
	set_pev(id, pev_takedamage, 0.0)
	ScreenFadeColor(id,250, 250, 0, 10)
	client_cmd(id, "spk sound/lol/Hourglass.wav")
}

public task_godmod_over(id){
	if(!is_user_connected(id)) return
	gGodmod[id] = 0
	fm_set_frozen(id, 0)
	ScreenFadeColor(id,255, 255, 255, 0)
	set_pev(id, pev_takedamage, 1.0)
	fm_set_rendering(id)

	gHourglass[id] = 0
}
