class_name Teleporter
extends Node2D

@export var teleporter_to: Teleporter
@export var player_pos: Marker2D ## Where player spawns when teleported here
@export var static_camera: bool = false
@export var camera_pos: Vector2 ## If camera is static, it's set to this position when teleported here
@export var music: AudioStream ## Optional room music that starts when the player is teleported here
@export_range(0.05, 3.0, 0.05, "suffix:s") var fade_duration: float = 0.4 ## Length of each fade (out and in) when using this door

var _teleporting: bool = false

@onready var interactable_component: InteractableComponent = $InteractableComponent
@onready var main_camera: Camera2D = %MainCamera

func _ready() -> void:
	interactable_component.player_interacted.connect(on_interact)

## Fade out, move the player, fade back in. Player input is locked meanwhile.
func on_interact(player: Player):
	if _teleporting:
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
	player.global_position = teleporter_to.player_pos.global_position
	if teleporter_to.music:
		MusicPlayer.play(teleporter_to.music)
	if teleporter_to.static_camera:
		main_camera.reparent(teleporter_to)
		main_camera.global_position = teleporter_to.camera_pos
	else:
		main_camera.reparent(player)
		main_camera.position = Vector2.ZERO
