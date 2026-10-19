extends Node2D

@onready var black_overlay: ColorRect = $BlackScreen/BlackOverlay

func _ready() -> void:
	Events.fade_in.connect(on_fade_in)
	
func on_fade_in():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.TRANSPARENT, 1)
