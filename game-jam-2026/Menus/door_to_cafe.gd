extends Teleporter

const CAFE_CONVO_1 = preload("uid://cctyukxbit6m1")

@onready var area_2d: Area2D = $InteractableComponent/Area2D

var start_cafe_scene: bool = false:
	set(value):
		start_cafe_scene = value
		if area_2d:
			area_2d.monitorable = start_cafe_scene
			
func _ready() -> void:
	super._ready()
	Events.enable_cafe_scene.connect(func(): start_cafe_scene = true)

func on_interact(player: Player):
	if not start_cafe_scene:
		return
		
	start_cafe_scene = false
		
	Events.disable_player_action.emit()
	Events.fade_to_black.emit()
		
	await get_tree().create_timer(1.5).timeout
		
	super.on_interact(player)
	Events.fade_to_color.emit()
	await get_tree().create_timer(1.0).timeout
	Events.dialogue_start_request.emit(CAFE_CONVO_1)
