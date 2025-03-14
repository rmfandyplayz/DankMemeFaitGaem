extends Node2D
class_name Game

static var fadeRect : ColorRect

func _ready() -> void:
	fadeRect = $CanvasLayer/Control/Fading
	create_tween().tween_property(fadeRect, "self_modulate", Color.TRANSPARENT, 2)


func Win():
	ResetLevel()

func ResetLevel():
	await create_tween().tween_property(fadeRect, "self_modulate", Color.WHITE, 2).finished
	get_tree().reload_current_scene()
