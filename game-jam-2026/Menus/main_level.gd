extends Node2D

@onready var black_overlay: ColorRect = $BlackScreen/BlackOverlay

@onready var may_npc: NPC = %MayNPC
@onready var dialogue_ui: CanvasLayer = $DialogueUI

func _ready() -> void:
	Events.fade_in.connect(on_fade_in)
	
	may_npc.dialogue_start_request.connect(start_dialogue_tree)
	
func on_fade_in():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.TRANSPARENT, 1)

func start_dialogue_tree(tree: DialogueTree):
	dialogue_ui.set_dialogue_tree(tree)
