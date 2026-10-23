extends Control

## Song that plays on the main menu. Drag your music file here in the Inspector.
@export var menu_music: AudioStream = preload("uid://cti6ee0vte6tf")
## How long the menu song takes to fade out when Play is pressed.
@export var music_fade_out: float = 1.0


@onready var options_menu: Panel = $OptionsMenu

func _ready() -> void:
	if menu_music:
		MusicPlayer.volume_db = 0.0
		MusicPlayer.play(menu_music, 1.0)
	else:
		push_warning("MainMenu: no menu_music assigned in the Inspector.")

func _on_play_button_pressed() -> void:
	MusicPlayer.stop(music_fade_out) # menu song ends when the game starts
	TransitionScene.change_scene("res://Menus/main_level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	options_menu.show()
