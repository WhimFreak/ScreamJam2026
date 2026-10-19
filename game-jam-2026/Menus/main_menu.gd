extends Control

func _on_play_button_pressed() -> void:
	TransitionScene.change_scene("res://Menus/main_level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
