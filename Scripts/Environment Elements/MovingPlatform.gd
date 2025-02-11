extends CharacterBody2D

@export var moveDuration : float # how long does it take for the platform to get to the other destination postion?
@export var easing : Tween.EaseType
@export var transition : Tween.TransitionType
@export var pauseDuration : float # for how long does the platform pause on each side?
@export var relativePos1 : Vector2 # the first relative position the platform will move to. the platform will also begin here
@export var relativePos2 : Vector2 # the second relative position the platform will move to

func _ready() -> void:
	position = relativePos1
	StartPlatformMovement()
	
func StartPlatformMovement() -> void:
	create_tween().set_ease(easing).set_trans(transition).tween_property(self, "position", relativePos2, moveDuration)
	await get_tree().create_timer(pauseDuration).timeout
	create_tween().set_ease(easing).set_trans(transition).tween_property(self, "position", relativePos1, moveDuration)
	await get_tree().create_timer(pauseDuration).timeout
