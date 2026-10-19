class_name BaseDialogue extends Resource

@export_group("images")
@export var portrait := preload("res://testing_assets/nigum.png")

@export_group("text")
@export_multiline var text := ""

@export_group("sounds")
@export var dialogue_sound := preload("res://testing_assets/talking_synth.ogg")
@export var sound_effect: AudioStream = null
