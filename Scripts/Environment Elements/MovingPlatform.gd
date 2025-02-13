extends AnimatableBody2D

@export var moveDuration : float # how long does it take for the platform to get to the other destination postion?
@export var easing : Tween.EaseType
@export var transition : Tween.TransitionType
@export var pauseDuration : float # for how long does the platform pause on each side?
@export var relativePos1 : Vector2 # the first relative position the platform will move to. the platform will also begin here
@export var relativePos2 : Vector2 # the second relative position the platform will move to

@export var platformSprite : AnimatedSprite2D

var disablePlatform = false


func _ready() -> void:
	platformSprite.play()
	
	position = Vector2(position.x - relativePos1.x, relativePos1.y)
	StartPlatformMovement()
	
func StartPlatformMovement() -> void:
	while disablePlatform == false:
		await create_tween().set_ease(easing).set_trans(transition).tween_property(self, "position", relativePos2, moveDuration).finished
		platformSprite.scale = Vector2(1, 1)
		await get_tree().create_timer(pauseDuration).timeout
		await create_tween().set_ease(easing).set_trans(transition).tween_property(self, "position", relativePos1, moveDuration).finished
		platformSprite.scale = Vector2(-1, 1)
		await get_tree().create_timer(pauseDuration).timeout
		
		
