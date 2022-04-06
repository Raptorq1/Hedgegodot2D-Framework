extends CanvasLayer
onready var level : LevelInfos = get_parent()
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

onready var score_label : Label = $Victory/HBoxContainer/Right/Score
onready var ring_label : Label = $Victory/HBoxContainer/Right/Ring
onready var time_label : Label = $Victory/HBoxContainer/Right/Time
onready var cool_label : Label = $Victory/HBoxContainer/Right/Cool
onready var total_label : Label = $Victory/HBoxContainer2/Right

var ring_bonus : int setget set_ring_bonus, get_ring_bonus
var score_bonus : int setget set_score_bonus, get_score_bonus
var time_bonus : int setget set_time_bonus, get_time_bonus
var cool_bonus : int setget set_cool_bonus, get_cool_bonus
var total : int = 0 setget set_total, get_total

func set_ring_bonus(val : int):
	ring_bonus = val
	ring_label.text = String(ring_bonus)

func set_score_bonus(val : int):
	score_bonus = val
	score_label.text = String(ring_bonus)

func set_cool_bonus(val : int):
	cool_bonus = val
	cool_label.text = String(ring_bonus)

func set_time_bonus(val : int):
	time_bonus = val
	time_label.text = String(ring_bonus)

func set_total(val : int):
	total = val
	total_label.text = String(total)

func get_ring_bonus() -> int:
	return int(ring_label.text)

func get_score_bonus() -> int:
	return int(score_label.text)

func get_cool_bonus() -> int:
	return int(cool_label.text)

func get_time_bonus() -> int:
	return int(time_label.text)

func get_total() -> int:
	return int(total_label.text)

func _ready() -> void:
	set_process(false)
	#flash_screen()

func show_title_card():
	transition.color.a = 1.0 if level.act_container.get_current_act_node().continue_last_transition else 0.0
	$AnimationPlayer.play("show")
	get_tree().get_root().set_disable_input(true)
	zone_name.text = level.zone_name
	act_num.text = String(level.get_current_act())

func start_victory():
	for i in get_tree().get_nodes_in_group("Players"):
		
		var p : PlayerPhysics = i
		if !p.is_grounded:
			(p.fsm as FSM).connect("state_changed", self, "player_victory_mode")
			continue
		p.fsm.change_state("VictoryPose")
		get_tree().get_root().set_disable_input(true)
	if level:
		set_ring_bonus(level.act_container.ring_bonus)
		set_score_bonus(level.act_container.score_bonus)
		set_time_bonus(level.act_container.time_bonus)
		set_cool_bonus(level.act_container.cool_bonus)
		start_count_points()

func player_victory_mode(prev_state, current_state, host):
	if host.is_grounded:
		host.fsm.change_state("VictoryPose")
		host.fsm.disconnect("state_changed", self, "player_victory_mode")
		get_tree().get_root().set_disable_input(true)

func subtract_digits(val):
	var to_subtract = pow(10, String(val).length() - 1)
	if val - to_subtract < 0:
		total += val
		set_total(total)
		return val
	total += to_subtract
	set_total(total)
	return to_subtract

func start_count_points():
	$Victory/VictoryAnimator.play("Appearing")
	level.act_clear_music.play()
	yield(level.act_clear_music, "finished")
	while ring_bonus > 0 or score_bonus > 0 or time_bonus > 0 or cool_bonus > 0:
		ring_bonus -= subtract_digits(ring_bonus)
		score_bonus -= subtract_digits(ring_bonus)
		time_bonus -= subtract_digits(ring_bonus)
		cool_bonus -= subtract_digits(ring_bonus)
		set_ring_bonus(ring_bonus)
		set_score_bonus(score_bonus)
		set_time_bonus(time_bonus)
		set_cool_bonus(cool_bonus)
		level.act_score_add.play()
		yield(get_tree(), "idle_frame")
	level.act_score_total.play()
	yield(get_tree().create_timer(0.5),"timeout")
	$Victory/VictoryAnimator.play_backwards("Appearing", -1)
	yield($Victory/VictoryAnimator,"animation_finished")
	yield(get_tree().create_timer(0.5),"timeout")
	get_tree().create_timer(0.5).connect("timeout", level.act_container, "go_to_next_act")
	for i in get_tree().get_nodes_in_group("Players"):
		i.fsm.change_state("OnAir")

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
			if transition.color.a < 0:
				transition.color.a = 0
				set_process(false)

func _flash_timeout(timer : Timer):
	set_process(true)
	action = Actions.FLASH
	timer.queue_free()


func _on_Sign_sign_positioned() -> void:
	start_victory()
