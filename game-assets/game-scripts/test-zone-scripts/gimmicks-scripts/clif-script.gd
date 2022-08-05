extends Node2D

var timer:Timer;
export var block:PackedScene;

func _on_Area_body_entered(body):
	if (body.name == "Player"):
		$Area.queue_free();
		timer = Timer.new();
		add_child(timer);
		timer.start(0.5);
		timer.connect("timeout", self, "breakDown");

func breakDown():
	timer.stop();
	$StaticBody2D.queue_free();
	timer = null;
	var level_sfx : SoundMachine = get_tree().get_current_scene().act_container.get_child(0).get_node_or_null('LevelSFX')
	if level_sfx:
		level_sfx.play('CliffBreaking')
	spawn(Vector2(8, 0), 0.10);
	spawn(Vector2(-8, 0), 0.15);
	spawn(Vector2(24, 0), 0.20);
	spawn(Vector2(-24, 0), 0.25);

func spawn(pos: Vector2, delay:float = 0):
	var blockInst:Node2D = block.instance();
	add_child(blockInst);
	blockInst.position = pos
	blockInst.delay(delay);


func _on_BreakSound_finished():
	queue_free()
