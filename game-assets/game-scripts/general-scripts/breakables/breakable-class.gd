extends Node2D
class_name Breakable
export var block_scene:PackedScene;
onready var global_sounds:SoundMachine = get_tree().get_root().get_node('AutoloadSoundMachine')

func spawnBlock(pos:Vector2, speed:Vector2, body):
	var block:Node2D = block_scene.instance();
	block.speed = speed;
	block.set_as_toplevel(true)
	block.global_position = global_position + pos;
	#print(global_position)
	get_tree().get_current_scene().add_child(block)
