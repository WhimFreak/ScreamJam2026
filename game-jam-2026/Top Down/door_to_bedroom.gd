extends Teleporter

const MAY_DISCOVERY_1 = preload("uid://dvs2xell2t8ua")
const MAY_DISCOVERY_2 = preload("uid://4e1o2qxisd2a")

@onready var area_2d: Area2D = $InteractableComponent/Area2D

func start_scene(player: Player):
	Events.dialogue_start_request.emit(MAY_DISCOVERY_1)
	
	await Events.tree_finished
	area_2d.monitorable = true

func on_interact(player: Player):
	if not area_2d.monitorable:
		return
	
	area_2d.monitorable = false
	Events.dialogue_start_request.emit(MAY_DISCOVERY_2)
	
