extends CharacterBody2D

@export var moveSpeed : float
@export var acceleration : float
@export var friction : float  # also how fast we decelerate

@export var playerSprite : AnimatedSprite2D
@export var minSpriteAnimationSpeed : float = 0.75
@export var maxSpriteAnimationSpeed : float = 3.0

@export var walkingSFX : AudioStreamPlayer2D
var disableWalkSFX : bool = false
@export var speedLines : ColorRect


@export var burstSpeed : float
@export var burstMaxDuration : float # in seconds
@export var burstRechargeSpeed : float # how many seconds per second
@export var burstRechargeCooldown : float # how long after using burst does it start recharging? (in seconds)
var burstRechargeCooldownTimer : float
@export var burstBar : TextureProgressBar
var burstActive : bool = false
var burstDirection : Vector2 = Vector2.ZERO
var burstTimer : float = 0 # current amount of available burst

func _ready() -> void:
	#burst bar initial configs
	burstBar.max_value = burstMaxDuration
	burstTimer = burstMaxDuration # start full
	burstBar	.value = burstTimer

	#player sprite animation config
	playerSprite.animation = "idle"
	playerSprite.play()


func _process(delta: float) -> void:
	print(burstTimer)
	# player sprite changes
	speedLines.visible = velocity != Vector2.ZERO
	if(velocity == Vector2.ZERO):
		playerSprite.animation = "idle"
		playerSprite.speed_scale = 1 # reset animation FPS
		walkingSFX.stop()
		disableWalkSFX = false
	elif(velocity != Vector2.ZERO and burstActive == false):
		playerSprite.animation = "walk"
		var speedFactor = clamp(velocity.length() / moveSpeed, 0, 1) # this is a value between 0 and 1
		playerSprite.speed_scale = lerp(minSpriteAnimationSpeed, maxSpriteAnimationSpeed, speedFactor) # adjust animation FPS
		
		if disableWalkSFX == false: 
			walkingSFX.play()
			disableWalkSFX = true

	speedLines.material.set_shader_parameter("line_density", lerp(0.1, 0.7, clamp(velocity.length() / burstSpeed, 0, 1)))

	# movement and burst
	if(burstActive == true and velocity != Vector2.ZERO):
		# burst movement
		burstTimer -= delta

		# update burst bar
		burstBar.value = burstTimer 
		
		if(burstTimer <= 0 or Input.is_action_pressed("Player_Burst") == false):
			EndBurst()
	else:
		# normal movement
		var inputDirection: Vector2 = GetInput()
		if(Input.is_action_just_pressed("Player_Burst") and velocity != Vector2.ZERO):
			StartBurst(velocity.normalized())
		else:
			MovePlayer(inputDirection, delta)

	move_and_slide()
	
	if (burstActive == false):
		if burstRechargeCooldownTimer > 0:
			burstRechargeCooldownTimer -= delta
		elif burstTimer < burstMaxDuration:
			burstTimer = min(burstTimer + burstRechargeSpeed * delta, burstMaxDuration)
			burstBar.value = burstTimer


func MovePlayer(inputDirection : Vector2, delta : float):
	if(inputDirection != Vector2.ZERO): 
		# accelerate to target speed
		velocity = velocity.move_toward(inputDirection * moveSpeed, acceleration * delta)
	else: 
		# apply friction (deceleration) when no input
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		


var burstMusic # the actual audio file/audio stream of the burst music
var burstMusicTimestamp : float = 0 # so that the music can pick off where it left off
func StartBurst(direction : Vector2):
	# abort the burst if there is no available time
	if(burstTimer <= 0):
		return
	
	disableWalkSFX = true
	walkingSFX.stop()
	playerSprite.animation = "boost"
	playerSprite.speed_scale = 1
	burstActive = true
	burstDirection = direction
	
	velocity = burstDirection * burstSpeed
	burstMusic = load("res://Media/Audio/Music/gasGasGas.mp3")
	AudioSystem.PlaySound(load("res://Media/Audio/SFX/sonicBoost.mp3"), "SFX_Master", .1, 1, false)
	burstMusic = AudioSystem.PlayMusic(burstMusic, .6, 1, true, burstMusicTimestamp)
	

func EndBurst():
	playerSprite.animation = "walk"
	burstActive = false
	disableWalkSFX = false
	
	#start the cooldown before the bar starts recharging
	burstRechargeCooldownTimer = burstRechargeCooldown
	
	burstMusicTimestamp = AudioSystem.StopAudio(burstMusic, true, 1)


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
