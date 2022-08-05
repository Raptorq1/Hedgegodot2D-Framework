extends Area2D
tool

var players : Array = [] setget set_players
export(float, 0, 1, .1) var editor_opacity : float = 0.5 setget _set_editor_opacity
export var visible_in_editor : bool = true setget _set_in_editor_visibility
export var fade_time:float = 0.5
export var tranparency_inside : float = 0.5

func _ready() -> void:
	set_process(false)
	if Engine.editor_hint:
		set_visible(visible_in_editor)
		modulate.a = editor_opacity
		return
	set_visible(true)
	modulate.a = 1.0

func _on_LevelTransparence_body_entered(body: Node) -> void:
	if body is PlayerPhysics:
		var player : PlayerPhysics = body
		players.append(player)
		set_players(players)


func _on_LevelTransparence_body_exited(body: Node) -> void:
	if body is PlayerPhysics:
		var player : PlayerPhysics = body
		if players.has(player):
			players.remove(players.find(player, 0))
			set_players(players)

func _set_editor_opacity(val : float) -> void:
	editor_opacity = max(0, min(1, val))
	modulate.a = editor_opacity

func _set_in_editor_visibility(val : bool) -> void:
	visible_in_editor = val
	set_visible(visible_in_editor)

func set_players(val : Array):
	players = val
	if players.empty():
		var tween = Utils.Nodes.new_tween(self)
		print("joj")
		tween.interpolate_property(self, "modulate:a", modulate.a, 1.0, fade_time, Tween.TRANS_LINEAR, 0)
		tween.start()
		tween.connect("tween_all_completed", tween, "queue_free")
	else:
		var tween = Utils.Nodes.new_tween(self)
		tween.interpolate_property(self, "modulate:a", modulate.a, tranparency_inside, fade_time, Tween.TRANS_LINEAR, 0)
		tween.start()
		tween.connect("tween_all_completed", tween, "queue_free")
