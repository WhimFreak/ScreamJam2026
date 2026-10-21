class_name BaseDialogue extends Resource

@export var character_name := ""
@export var portrait := preload("res://testing_assets/nigum.png")

@export_multiline var text := ""


@export_group("sounds")
@export var dialogue_sound := preload("res://testing_assets/talking_synth.ogg")
@export var sound_effect: AudioStream = null
