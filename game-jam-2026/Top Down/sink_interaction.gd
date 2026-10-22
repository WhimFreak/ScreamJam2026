extends Node2D

const WASHROOM_1 = preload("uid://bmthpfl2tbbkd")
const WASHROOM_2 = preload("uid://dyy3rvmj7sqxb")

@onready var area_2d: Area2D = $InteractableComponent/Area2D
@onready var interactable_component: InteractableComponent = $InteractableComponent

@export var interactable: bool = false:
	set(value):
		interactable = value
		if area_2d:
			area_2d.monitorable = interactable
			
func _ready() -> void:
	interactable_component.player_interacted.connect(on_interact)
	Events.tree_finished.connect(on_tree_finished)
	
func on_tree_finished(tree: DialogueTree):
	if tree == WASHROOM_1:
		interactable = true
	
func on_interact(_player: Player):
	if not interactable:
		return
	interactable = false
	Events.dialogue_start_request.emit(WASHROOM_2)
