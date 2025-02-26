extends CharacterBody2D
class_name BaseEnemy

# shared variables that is common through all enemies

@export var health : float
@export var aiActivationRange : float
@export var aiDeactivationRange : float # after the AI is activated, at what distance should it go back to being deactivated? -1 to disable completely
var isAiActivated : bool # is the AI activated? doesn't have to do with anything else that disables if the AI works or not

@export var player : CharacterBody2D # used to access player properties
