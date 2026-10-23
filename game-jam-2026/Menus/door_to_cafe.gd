extends Teleporter

const CAFE_CONVO_1 = preload("uid://cctyukxbit6m1")
const WASHROOM_1 = preload("uid://bmthpfl2tbbkd")

@export var washroom_door: Teleporter

@onready var area_2d: Area2D = $InteractableComponent/Area2D
@onready var screen_animation_player: AnimationPlayer = %ScreenAnimationPlayer

var start_cafe_scene: bool = false:
	set(value):
		start_cafe_scene = value
		if area_2d:
			area_2d.monitorable = start_cafe_scene
var player_ref: Player
			
func _ready() -> void:
	super._ready()
	Events.enable_cafe_scene.connect(func(): start_cafe_scene = true)
	Events.stop_blur.connect(func(): screen_animation_player.play("RESET"))
	Events.tree_finished.connect(on_tree_finished)

func on_interact(player: Player):
	if not start_cafe_scene:
		return
	
	player_ref = player
	start_cafe_scene = false
		
	Events.disable_player_action.emit()
	Events.fade_to_black.emit()
		
	await get_tree().create_timer(1.5).timeout
		
	super.on_interact(player)
	player.sitting = true
	Events.fade_to_color.emit()
	await get_tree().create_timer(1.0).timeout
	Events.dialogue_start_request.emit(CAFE_CONVO_1)

func on_tree_finished(tree):
	if tree != CAFE_CONVO_1:
		return
		
	player_ref.sitting = false
	player_ref.global_position = washroom_door.player_pos.global_position
	main_camera.reparent(washroom_door)
	main_camera.global_position = washroom_door.camera_pos
	
	screen_animation_player.play("pulse_blur")
	Events.dialogue_start_request.emit(WASHROOM_1)
		
