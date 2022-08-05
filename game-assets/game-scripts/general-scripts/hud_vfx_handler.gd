extends Object

var host

func _init(p_host) -> void:
	host = p_host

func flash_screen(delay_to_fade_out : float = 0.25, alpha : float = 1.0, fade_out_time : float = 2.0) -> void:
	host.vfx_rect.color = Color('#ffffffff')
	host.vfx_rect.color.a = alpha
	host.get_tree().create_timer(delay_to_fade_out).connect('timeout', self, '_flash_timeout', [fade_out_time])

func _flash_timeout(fade_out_time : float):
	var fadeout:HUDVFX = load('res://game-assets/game-scripts/general-scripts/hud_vfx/hud_vfx_fade_out.gd').new()
	fadeout.fade_out_time = fade_out_time
	host.vfx_rect.add_child(fadeout)
