extends CharacterBody2D

@export var moveSpeed : float
@export var jumpHeight : float
@export var wallJumpStickDuration : float
@export var wallJumpJumppower : float
@export var wallJumpSlideGravity : float # modifies player's gravity while sliding

var _velocity : Vector2 = Vector2.ZERO
var _isOnWall : bool = false
var _wallJumpTimer : float = 0.0

func _process(delta: float) -> void:
	var input_direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if _isOnWall:
		_velocity.y += wallJumpSlideGravity * delta
	else:
		_velocity.y += 1000.0 * delta # gravity

	_velocity.x = input_direction * moveSpeed

	if is_on_floor():
		_wallJumpTimer = 0.0
		_isOnWall = false

		if Input.is_action_just_pressed("ui_accept"):
			_velocity.y = jumpHeight
	elif is_on_wall():
		_isOnWall = true
	elif not is_on_floor():
		_velocity += get_gravity() * delta

		if Input.is_action_just_pressed("ui_accept"):
			_velocity.y = wallJumpJumppower
			_wallJumpTimer = wallJumpStickDuration

	if _wallJumpTimer > 0.0:
		_velocity.x = 0.0
		_wallJumpTimer -= delta

	move_and_slide()
