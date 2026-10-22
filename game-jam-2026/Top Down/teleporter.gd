class_name Teleporter
extends Node2D

@export var teleporter_to: Teleporter
@export var player_pos: Marker2D ## Where player spawns when teleported here
@export var static_camera: bool = false
@export var camera_pos: Vector2 ## If camera is static, it's set to this position when teleported here
@export var music: AudioStream ## Optional room music that starts when the player is teleported here
@export_range(0.05, 3.0, 0.05, "suffix:s") var fade_duration: float = 0.4 ## Length of each fade (out and in) when using this door
@export var instant: bool = false

var _teleporting: bool = false

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var main_camera: Camera2D = %MainCamera

func _ready() -> void:
	interactable_component.player_interacted.connect(on_interact)

## Fade out, move the player, fade back in. Player input is locked meanwhile.
func on_interact(player: Player):
	if _teleporting:
		return
	
	if instant:
		teleport_player(player)
		return
		
	_teleporting = true
	Events.disable_player_action.emit()
	Events.screen_fade.emit(1.0, fade_duration)
	await get_tree().create_timer(fade_duration).timeout

	teleport_player(player)

	Events.screen_fade.emit(0.0, fade_duration)
	await get_tree().create_timer(fade_duration).timeout
	Events.enable_player_action.emit()
	_teleporting = false

## Instant teleport with no fade (used by on_interact and by special doors with their own fades).
func teleport_player(player: Player):
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
