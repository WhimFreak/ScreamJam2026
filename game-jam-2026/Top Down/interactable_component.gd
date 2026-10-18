class_name InteractableComponent
extends Node2D

signal player_interacted # Connect the parent to this signal to add interaction effect

@export var area_2d: Area2D ## Defines range of interactivity

@onready var actor = get_parent()

func _ready() -> void:
	if not get_children().has(area_2d):
		area_2d.reparent(self)
		
