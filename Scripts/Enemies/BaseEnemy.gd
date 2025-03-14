extends RigidBody2D
class_name BaseEnemy

# shared variables that is common through all enemies
# (kinda like an abstract class lol)

@export_category("Basic Properties")
@export var currentHealth : float
@export var maxHealth : float
@export var damageResistance : float # in percentage (decimal). it will take some% damage away from the intended damage
@export var knockbackResistance : float
@export var stunDuration : float # how many seconds will the enemy be stunned on collision
@export var stunTimer : Timer # internal tracker of current amount of stun seconds

@export_category("AI Related")
@export var aiActivationRange : float
@export var aiDeactivationRange : float # after the AI is activated, at what distance should it go back to being deactivated? -1 to disable completely
var isAiActivated : bool # is the AI activated? doesn't have to do with anything else that disables if the AI works or not
var disableAi : bool # a separate thing that disables the AI for different reasons

var player : CharacterBody2D # used to access player properties
			
		
		

func Die():
	queue_free()
