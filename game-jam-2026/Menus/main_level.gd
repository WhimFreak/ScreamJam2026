extends Node2D

@onready var black_overlay: ColorRect = $BlackScreen/BlackOverlay

@onready var may_npc: NPC = %MayNPC
@onready var dialogue_ui: CanvasLayer = $DialogueUI

func _ready() -> void:
	black_overlay.modulate = Color.WHITE
	
	Events.fade_to_black.connect(on_fade_to_black)
	Events.fade_to_color.connect(on_fade_to_color)
	Events.fade_to_black_then_color.connect(on_fade_to_black_then_color)
	Events.slow_fade_to_black.connect(on_slow_fade_to_black)
	
	Events.dialogue_start_request.connect(start_dialogue_tree)
	
func on_fade_to_black():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.WHITE, 1)
	
func on_fade_to_color():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.TRANSPARENT, 1)
	
func on_fade_to_black_then_color():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.WHITE, 1)
	tween.tween_interval(1)
	tween.tween_property(black_overlay, "modulate", Color.TRANSPARENT, 1)

func start_dialogue_tree(tree: DialogueTree):
	dialogue_ui.set_dialogue_tree(tree)
	
func on_slow_fade_to_black():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.WHITE, 5)
