class_name Teleporter
extends Node2D

@export var teleporter_to: Teleporter
@export var player_pos: Marker2D ## Where player spawns when teleported here
@export var static_camera: bool = false
@export var camera_pos: Vector2 ## If camera is static, it's set to this position when teleported here
@export var music: AudioStream ## Optional room music that starts when the player is teleported here

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var main_camera: Camera2D = %MainCamera

func _ready() -> void:
	interactable_component.player_interacted.connect(on_interact)
	
func on_interact(player: Player):
	teleporter_to.teleport_here(player)
		
func teleport_here(player: Player):
	player.global_position = player_pos.global_position
	if music:
		MusicPlayer.play(music)
	if static_camera:
		main_camera.reparent(self)
		main_camera.global_position = camera_pos
	else:
		main_camera.reparent(player)
		main_camera.position = Vector2.ZERO
