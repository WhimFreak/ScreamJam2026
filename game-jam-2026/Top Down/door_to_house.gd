extends Teleporter

const BEDROOM_1 = preload("uid://c6bpiodoi7cxl")
const BEDROOM_2 = preload("uid://beni64xc2lnxe")

@onready var area_2d: Area2D = $InteractableComponent/Area2D
@onready var night_overlay: ColorRect = %NightOverlay

func start_scene(player: Player):
	night_overlay.modulate = Color("ffffff40")
	teleport_here(player)
	Events.dialogue_start_request.emit(BEDROOM_1)
	await Events.tree_finished
	
	area_2d.monitorable = true
	
func on_interact(player: Player):
	Events.dialogue_start_request.emit(BEDROOM_2)
	await Events.tree_finished
	night_overlay.modulate = Color.TRANSPARENT
