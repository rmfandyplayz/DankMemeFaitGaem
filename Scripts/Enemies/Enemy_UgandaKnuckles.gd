extends BaseEnemy

# knuckles AI will rush at the player every few seconds, determined by rushInterval

enum BehaviorTreeNode {
	FAILURE = 0,
	SUCCESS = 1,
	RUNNING = 2
}

# configuration stuff
@export var rushSpeed : float
@export var rushInterval : float
@export var rushDuration : float # how many seconds will the enemy rush before stopping?
#                     ^^^   that or the enemy collides with something first.
@export var damage : float
@export var hurtbox : Area2D
@export var pushForce : float # how much will the player be pushed on damage?



# internal stuff
var waitTimer : float = 0 # keeps track of time between each rush
var rushTimer : float = 0 # keeps track of time DURING each rush
var rushVelocity : Vector2
var rushVelocityAlreadySet : bool = false
var isRushing : bool = false



func _ready() -> void:
	player = %Player
	currentHealth = maxHealth
	stunTimer.wait_time = stunDuration
	stunTimer.start()
	DeactivateHurtbox()
	

func _physics_process(delta: float) -> void:
	if ActivationRangeNode() == true:
		BehaviorTree(delta)


# determines if the AI is activated via range
func ActivationRangeNode() -> bool: 
	var distToPlayer : float = position.distance_to(player.position)
	
	if(isAiActivated == false and distToPlayer <= aiActivationRange):
		isAiActivated = true
	elif(isAiActivated == true and aiActivationRange != -1 and distToPlayer > aiDeactivationRange):
		isAiActivated = false
	
	return isAiActivated
	

var forcesAlreadyReset : bool = false
# main behavior tree that manages all AI for this enemy
func BehaviorTree(delta : float) -> void:
	if (stunTimer.time_left <= 0):
		if WaitNode(delta) == BehaviorTreeNode.SUCCESS: #rush if success
			ActivateHurtbox()
			if(forcesAlreadyReset == false):
				linear_velocity = Vector2.ZERO
				forcesAlreadyReset = true
			
			if RushNode(delta) == BehaviorTreeNode.SUCCESS:
				isRushing = false
				waitTimer = 0
				rushTimer = 0
				rushVelocityAlreadySet = false
				forcesAlreadyReset = false
				await get_tree().create_timer(.15).timeout
				DeactivateHurtbox()
			


# counts time between each attack
func WaitNode(delta : float):
	if(isRushing == false and waitTimer <= rushInterval):
		waitTimer += delta
		return BehaviorTreeNode.RUNNING
	if waitTimer >= rushInterval: # return the success and start rushing
		isRushing = true
		if(rushVelocityAlreadySet == false):
			rushVelocity = position.direction_to(player.position) * rushSpeed
			rushVelocityAlreadySet = true
		return BehaviorTreeNode.SUCCESS


# move straight until u collide with something
func RushNode(delta : float) -> BehaviorTreeNode:
	var collision = move_and_collide(rushVelocity * delta)
	
	if collision or rushTimer >= rushDuration: 
		return BehaviorTreeNode.SUCCESS
	
	rushTimer += delta
	return BehaviorTreeNode.RUNNING

# applies logic when enemy hits player
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if(body.is_in_group("Player")):
		if(player.burstResistanceActive == false):
			DealDamage(damage)
		else:
			DealDamage(damage * player.burstDamageResistance)
		

func TakeDamage(damage : float, collisionVelocity : Vector2): # collisionVelocity is for knocking the enemy back
	print(damage, " damage")
	if(stunTimer.time_left <= 0 and isRushing == false): # enemy is only able to be damaged if not stunned and is not rushing
		currentHealth -= damage * damageResistance
		if(currentHealth <= 0):
			Die()
		else:
			print("applied force: ", collisionVelocity * Vector2(knockbackResistance, knockbackResistance))
			apply_force(collisionVelocity * Vector2(knockbackResistance, knockbackResistance))
			disableAi = true
			stunTimer.start()


func DealDamage(damageToDeal : float):
	player.SubtractHP(damageToDeal)

func ActivateHurtbox():
	hurtbox.monitoring = true
	
func DeactivateHurtbox():
	hurtbox.monitoring = false
