extends StaticBody2D
class_name BaseEnemy

# shared variables that is common through all enemies
# (kinda like an abstract class lol)

@export var health : float
@export var damageResistance : float # in percentage (decimal). it will take some% damage away from the intended damage
@export var stunSeconds : float # how many seconds will the enemy be stunned on collision


@export var aiActivationRange : float
@export var aiDeactivationRange : float # after the AI is activated, at what distance should it go back to being deactivated? -1 to disable completely
var isAiActivated : bool # is the AI activated? doesn't have to do with anything else that disables if the AI works or not

var player : CharacterBody2D # used to access player properties


func TakeDamage(damage : float):
	health -= damage
	if(health <= 0):
		Die()
	

func Die():
	queue_free()
