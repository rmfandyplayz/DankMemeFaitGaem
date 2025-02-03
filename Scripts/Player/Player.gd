extends CharacterBody2D

@export var moveSpeed : float
@export var acceleration: float
@export var friction: float  # also how fast we decelerate

@export var burstSpeed : float
@export var burstMaxDuration : float # in seconds

@export var playerSprite : AnimatedSprite2D
@export var minSpriteAnimationSpeed : float = 0.75
@export var maxSpriteAnimationSpeed : float = 3.0

var burstActive : bool = false
var burstDirection : Vector2 = Vector2.ZERO
var burstTimer : float = 0 # current amount 

func _ready() -> void:
	playerSprite.animation = "idle"
	playerSprite.play()



func _process(delta: float) -> void:
	# player sprite changes
	if(velocity == Vector2.ZERO):
		playerSprite.animation = "idle"
		playerSprite.speed_scale = 1 # reset animation FPS
	elif(velocity != Vector2.ZERO and burstActive == false):
		playerSprite.animation = "walk"
		var speedFactor = clamp(velocity.length() / moveSpeed, 0, 1) # this is a value between 0 and 1
		playerSprite.speed_scale = lerp(minSpriteAnimationSpeed, maxSpriteAnimationSpeed, speedFactor) # adjust animation FPS
		
		
		#DEBUG TEST TEST TEST TEST
		print("Velocity Length: ", velocity.length())
		print("Velocity Length / MoveSpeed: ", (velocity.length() / moveSpeed))
		print("Speed Factor: ", speedFactor)
		print("Speed Scale: ", playerSprite.speed_scale) 
	
	# movement and burst
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
	playerSprite.animation = "boost"
	playerSprite.speed_scale = 1
	burstActive = true
	burstDirection = direction
	burstTimer = burstMaxDuration
	velocity = burstDirection * burstSpeed

func EndBurst():
	playerSprite.animation = "walk"
	burstActive = false


func GetInput() -> Vector2:
	var direction: Vector2 = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		playerSprite.flip_h = true
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		playerSprite.flip_h = false
		direction.x += 1
	
	return direction.normalized()
