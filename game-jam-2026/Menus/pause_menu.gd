extends CanvasLayer

@onready var pause_panel: Panel = $PausePanel

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		pause_panel.visible = get_tree().paused

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	TransitionScene.change_scene("res://Menus/main_menu.tscn")
