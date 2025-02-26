extends BaseEnemy

# knuckles AI will rush at the player every few seconds, determined by rushInterval

enum BehaviorTreeNode {
	FAILURE = 0,
	SUCCESS = 1,
	RUNNING = 2
}

# configuration stuff
@export var speed : float
@export var rushInterval : float

# internal stuff
var timer : float = 0 # in this scenario, keeps track of time between each rush
var rushDirection : Vector2
var isRushing : bool = false


func _physics_process(delta: float) -> void:
	BehaviorTree(delta)
	

func BehaviorTree(delta : float) -> void:
	pass
