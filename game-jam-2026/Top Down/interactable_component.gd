class_name InteractableComponent
extends Node2D

signal player_interacted(player: Player) # Connect the parent to this signal to add interaction effect

@export var area_2d: Area2D ## Defines range of interactivity

@onready var actor = get_parent()

func _ready() -> void:
	area_2d.set_collision_layer_value(3, true)
	if not get_children().has(area_2d):
		area_2d.reparent(self)
		
