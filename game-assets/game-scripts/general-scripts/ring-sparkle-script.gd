extends Node2D
export(int) var animation = 0;

func _ready():
	var anims = ["Catch1", "Catch2", "HyperCatch"];
	if anims[animation]:
		if has_node("Anim"):
			$Anim.play(anims[animation]);

func _on_Anim_animation_finished():
	get_parent().remove_child(self);
