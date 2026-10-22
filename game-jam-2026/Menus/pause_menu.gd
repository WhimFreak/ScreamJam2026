extends CanvasLayer

@onready var pause_panel: Panel = $PausePanel
@onready var options_button: Button = $PausePanel/VBoxContainer/OptionsButton

func _ready() -> void:
	options_button.pressed.connect(_on_options_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		pause_panel.visible = get_tree().paused

func _on_options_button_pressed() -> void:
	options_button.text = "Devs were too lazy to add that"
	# The `true` makes the timer keep running while the game is paused
	await get_tree().create_timer(2.0, true).timeout
	options_button.text = "OPTIONS"

func _on_return_button_pressed() -> void:
	get_tree().paused = false
	TransitionScene.change_scene("res://Menus/main_menu.tscn")
