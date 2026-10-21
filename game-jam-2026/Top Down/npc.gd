class_name NPC
extends Node2D

signal dialogue_start_request(tree: DialogueTree)

@export var dialogue_trees: Array[DialogueTree]
@export var interactable: bool = false:
	set(value):
		interactable = value
		if area_2d:
			area_2d.monitorable = interactable
@export var next_tree_idx: int = 0

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var area_2d: Area2D = $InteractableComponent/Area2D

func _ready() -> void:
	interactable_component.player_interacted.connect(on_interact)
	Events.tree_finished.connect(on_tree_finished)
	
	await area_2d.ready
	interactable = interactable
	
func on_interact(_player: Player):
	if not interactable:
		return
	dialogue_start_request.emit(dialogue_trees[next_tree_idx])
	
func on_tree_finished(_tree: DialogueTree):
	pass
