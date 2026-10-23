extends Control

@onready var options_menu: Panel = $OptionsMenu

func _on_play_button_pressed() -> void:
	TransitionScene.change_scene("res://Menus/main_level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	options_menu.show()
