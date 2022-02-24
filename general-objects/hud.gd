extends CanvasLayer
enum Actions {
	FLASH = 0,
	FADE = 1
}
signal can_play
onready var color_rect : ColorRect = $ColorRect
onready var transition : ColorRect = $Transition
var action : int
onready var zone_name : Label = $TitleCard/Sort/NormalBg/Bg/Text/ZoneName
onready var act_num : Label = $TitleCard/Sort/NormalBg/Bg/Text/ActContainer/ActNum

func _ready() -> void:
	var parent = get_parent()
	if parent is LevelInfos:
		if parent.show_title_card:
			$AnimationPlayer.play("show")
			get_tree().get_root().set_disable_input(true)
			zone_name.text = parent.zone_name
			act_num.text = String(parent.act)
			transition.color.a = float(get_parent().continue_last_transition)
		else:
			transition.color.a = 0.0
	set_process(false)
	#flash_screen()

func flash_screen(time_to_fade_out : float = 0.25, alpha : float = 1.0) -> void:
	color_rect.color = Color('#ffffffff')
	color_rect.color.a = alpha
	var timer : Timer = Timer.new()
	timer.connect('timeout', self, '_flash_timeout', [timer])
	add_child(timer)
	timer.start(time_to_fade_out)

func fade_transition():
	action = Actions.FADE
	set_process(true)

func _process(delta: float) -> void:
	match action:
		Actions.FLASH:
			color_rect.color.a -= delta * 2
			if color_rect.color.a < 0:
				color_rect.color.a = 0
				set_process(false)
		Actions.FADE:
			transition.color.a -= delta * 2
			if color_rect.color.a < 0:
				color_rect.color.a = 0
				set_process(false)

func _flash_timeout(timer : Timer):
	set_process(true)
	action = Actions.FLASH
	timer.queue_free()
