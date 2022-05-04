extends Node2D
class_name StaticNode2D

enum PermissibleRotations{
	UP=0, RIGHT=1, DOWN=2, LEFT=3
}

func set_rotation_degrees (val : float) -> void:
	#print(PermissibleRotations.values())
	var final_value : float = abs(fmod(round(val / 90.0), 4))
	#print(final_value)
	.set_rotation_degrees(final_value * 90)

func set_rotation( val : float) -> void:
	var val_deg = rad2deg(val)
	var _final_value : float = abs(fmod(round(val_deg / 90.0), 4)) * 90
	.set_rotation(deg2rad(val))
