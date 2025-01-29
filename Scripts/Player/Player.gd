extends CharacterBody2D

@export var moveSpeed : float
@export var acceleration: float
@export var friction: float  # also how fast we decelerate

@export var burstSpeed : float
@export var burstMaxDuration : float # in seconds

var burstActive : bool = false
var burstDirection : Vector2 = Vector2.ZERO
var burstTimer : float = 0 # current amount 



func _process(delta: float) -> void:
	print(velocity)
	if(burstActive == true and velocity != Vector2.ZERO):
		# burst movement
		burstTimer -= delta
		if(burstTimer <= 0 or Input.is_action_pressed("Player_Burst") == false):
			EndBurst()
	else:
		# normal movement
		var inputDirection: Vector2 = GetInput()
		if(Input.is_action_just_pressed("Player_Burst") and inputDirection != Vector2.ZERO):
			StartBurst(inputDirection)
		else:
			MovePlayer(inputDirection, delta)

	move_and_slide()


func MovePlayer(inputDirection : Vector2, delta : float):
	if(inputDirection != Vector2.ZERO): 
		# accelerate to target speed
		velocity = velocity.move_toward(inputDirection * moveSpeed, acceleration * delta)
	else: 
		# apply friction (deceleration) when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		

func StartBurst(direction : Vector2):
	burstActive = true
	burstDirection = direction
	burstTimer = burstMaxDuration
	velocity = burstDirection * burstSpeed

func EndBurst():
	burstActive = false


func GetInput() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	return direction.normalized()
