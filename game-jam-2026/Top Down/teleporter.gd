class_name Teleporter
extends Node2D

@export var teleporter_to: Teleporter
@export var player_pos: Marker2D ## Where player spawns when teleported here
@export var static_camera: bool = false
@export var camera_pos: Vector2 ## If camera is static, it's set to this position when teleported here

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var main_camera: Camera2D = %MainCamera

func _ready() -> void:
	interactable_component.player_interacted.connect(on_interact)
	
func on_interact(player: Player):
	player.global_position = teleporter_to.player_pos.global_position
	if teleporter_to.static_camera:
		main_camera.reparent(teleporter_to)
		main_camera.global_position = teleporter_to.camera_pos
	else:
		main_camera.reparent(player)
		main_camera.position = Vector2.ZERO
