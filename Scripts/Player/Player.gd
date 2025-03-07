extends CharacterBody2D

# basic properties
@export var currentHealth : float
@export var maxHealth : float
@export var healthBar : TextureProgressBar
@export var healthText : RichTextLabel
@export var moveSpeed : float
@export var acceleration : float
@export var friction : float  # also how fast we decelerate

# sprites, animations, etc
@export var playerSprite : AnimatedSprite2D
@export var minSpriteAnimationSpeed : float = 0.75
@export var maxSpriteAnimationSpeed : float = 3.0

# music / SFX
@export var walkingSFX : AudioStreamPlayer2D
var disableWalkSFX : bool = false


# controls
@export var speedLines : ColorRect

# all things related to the burst mechanic
@export var burstSpeed : float
@export var burstMaxDuration : float # in seconds
@export var burstRechargeSpd : float # how many seconds per second
# WARNING BRO SERIOUS WTF WHY DOES SPECIFICALLY "burstRechargeSpeed" CAUSE ISSUES.
# I HAVE TO CHANGE THE FRICKEN STUPID VARAIBLE NAME AND IT FRICKEN WORKS
# WHY THE ACTUAL #### THIS IS SO ####### STUPID
@export var burstRechargeCd : float # how long after using burst does it start recharging? (in seconds)
var burstRechargeCdTimer : float
@export var burstBar : TextureProgressBar
var burstActive : bool = false
var burstDirection : Vector2 = Vector2.ZERO
var burstTimer : float = 0 # current amount of available burst
@export var burstFlame : AnimatedSprite2D

@export var collisionDetector : Area2D

func _ready() -> void:
	#burst bar initial configs
	burstBar.max_value = burstMaxDuration
	burstTimer = burstMaxDuration # start full
	burstBar.value = burstTimer
	
	#health-related configs
	healthBar.max_value = maxHealth
	SetHP(maxHealth)
	

	#player sprite animation config
	playerSprite.animation = "idle"
	playerSprite.play()


func _process(delta: float) -> void:
	# player sprite changes based on movement
	speedLines.visible = (velocity != Vector2.ZERO)
	if(velocity == Vector2.ZERO): # for when the player isn't moving at all
		playerSprite.animation = "idle"
		playerSprite.speed_scale = 1 # reset animation FPS
		walkingSFX.stop()
		disableWalkSFX = false
	elif(velocity != Vector2.ZERO and burstActive == false): # for when the player is moving AND isn't bursting
		playerSprite.animation = "walk"
		var speedFactor = clamp(velocity.length() / moveSpeed, 0, 1) # this is a value between 0 and 1
		playerSprite.speed_scale = lerp(minSpriteAnimationSpeed, maxSpriteAnimationSpeed, speedFactor) # adjust animation speed
		
		if disableWalkSFX == false: 
			walkingSFX.play()
			disableWalkSFX = true

	# change how intense the speed lines effect is
	speedLines.material.set_shader_parameter("line_density", lerp(0.1, 0.7, clamp(velocity.length() / burstSpeed, 0, 1)))

	# movement and burst
	if(burstActive == true and velocity != Vector2.ZERO):
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
		if burstRechargeCdTimer > 0:
			burstRechargeCdTimer -= delta
		elif burstTimer < burstMaxDuration:
			burstTimer = min(burstTimer + (burstRechargeSpd * delta), burstMaxDuration)
			burstBar.value = burstTimer
			

# signal - from Player/CollisionDetector.
# equivalent of OnCollisionEnter2D and such from Unity. does something when collision happens
func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("StopsBurst")):
		EndBurst()
	

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
	
	#animations and stuff
	playerSprite.animation = "boost"
	playerSprite.speed_scale = 1
	
	#burst flame
	burstFlame.visible = true
	burstFlame.rotation_degrees = rad_to_deg(velocity.angle())
	if((burstFlame.rotation_degrees >= -180 and burstFlame.rotation_degrees < -90) or (burstFlame.rotation_degrees <= 180 and burstFlame.rotation_degrees > 90)):
		burstFlame.flip_v = true
	else:
		burstFlame.flip_v = false
	burstFlame.self_modulate = Color.WHITE
	burstFlame.animation = "init"
	burstFlame.play()
	
	#speed config
	burstActive = true
	burstDirection = direction
	velocity = burstDirection * burstSpeed
	
	#music config
	burstMusic = load("res://Media/Audio/Music/gasGasGas.mp3")
	AudioSystem.PlaySound(load("res://Media/Audio/SFX/sonicBoost.mp3"), "SFX_Master", .1, 1, false)
	burstMusic = AudioSystem.PlayMusic(burstMusic, .6, 1, true, burstMusicTimestamp)
	
	#play the looping burst flame
	await burstFlame.animation_finished
	burstFlame.animation = "loop"
	burstFlame.play()
	
	
func EndBurst():
	playerSprite.animation = "walk"
	burstActive = false
	disableWalkSFX = false
	
	# play the animaton for burst flame dissipation
	burstFlame.animation = "end"
	burstFlame.play()
	
	#start the cooldown before the bar starts recharging
	burstRechargeCdTimer = burstRechargeCd
	
	await burstFlame.animation_finished
	burstFlame.visible = false
	
	#keep the burst music where it was so it can be picked off where it left off later
	if(is_instance_valid(burstMusic)):
		burstMusicTimestamp = await AudioSystem.StopAudio(burstMusic, true, 1)


# all of the below HP functions share similar features
# they change the hp value in the code, and updates the bars
# also plays effects, sounds, and runs other logic.

func AddHP(hpAddValue : float):
	currentHealth += hpAddValue
	UpdateHealthUI()
	
	if(currentHealth <= 0):
		Die()
	
func SubtractHP(hpSubtractValue : float):
	currentHealth -= hpSubtractValue
	UpdateHealthUI()
	
	if(currentHealth <= 0):
		Die()
	
func SetHP(newHpValue : float):
	currentHealth = newHpValue
	UpdateHealthUI()
	
	if(currentHealth <= 0):
		Die()
		
# updates all helath things that are ui-related
func UpdateHealthUI():
	healthBar.value = currentHealth
	healthText.text = "[outline_size=12][font_size=50] [b]{currentHP}[/b] [font_size=30][color=#ffffff99]/ {maxHP}".format({
		"currentHP" : int(currentHealth),
		"maxHP" : int(maxHealth)
	})



# utility function for input handling
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
	

# runs logic for player death
func Die():
	get_tree().reload_current_scene()

# utility functions used by other scripts (i.e. enemies so they know your pos)
func GetPos():
	return position
