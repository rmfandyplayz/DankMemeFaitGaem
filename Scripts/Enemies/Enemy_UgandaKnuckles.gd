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

# internal stuff
var timer : float = 0 # in this scenario, keeps track of time between each rush
var rushDirection : Vector2
var isRushing : bool = false



func _ready() -> void:
	player = %Player

func _physics_process(delta: float) -> void:
	if ActivationRangeNode() == true:
		BehaviorTree(delta)
	
# determines if the AI is activated via range
func ActivationRangeNode() -> bool: 
	var distToPlayer : float = position.distance_to(player.position)
	
	if(isAiActivated == false and distToPlayer <= aiActivationRange):
		print("ai activated")
		isAiActivated = true
	elif(isAiActivated == true and aiActivationRange != -1 and distToPlayer > aiDeactivationRange):
		print("ai NOT activated")
		isAiActivated = false
	
	return isAiActivated
	

func BehaviorTree(delta : float) -> void:
	if WaitNode(delta) == BehaviorTreeNode.SUCCESS: #rush if success
		print("true")
		if RushNode(delta) == BehaviorTreeNode.SUCCESS:
			print("rush node success, isrushing disabled")
			isRushing = false
			print(isRushing)


# counts time between each attack
func WaitNode(delta : float):
	if(isRushing == false):
		timer += delta
	if timer >= rushInterval:
		timer = 0
		print("wait node success")
		return BehaviorTreeNode.SUCCESS
	print("wait node running")
	return BehaviorTreeNode.RUNNING


# move straight until u collide with something
func RushNode(delta : float) -> BehaviorTreeNode:
	isRushing = true
	var rushVelocity : Vector2 = position.direction_to(player.position) * rushSpeed
	print("rush velocity: ", rushVelocity)
	var collision = move_and_collide(rushVelocity * delta)
	print("rushing")
	if collision:
		print("collision: ", collision)
		print("finished rushing")
		return BehaviorTreeNode.SUCCESS
	
	return BehaviorTreeNode.RUNNING
