extends Control

## Song that plays on the main menu. Drag your music file here in the Inspector.
@export var menu_music: AudioStream = preload("uid://cti6ee0vte6tf")
## How long the menu song takes to fade in when the menu opens (0 = full volume instantly).
@export var music_fade_in: float = 0.5
## How long the menu song takes to fade out when Play is pressed.
@export var music_fade_out: float = 1.0

@export_group("intro fade")
@export var warning_text: String = "Not suitable for those who are easily disturbed"
@export var warning_fade_in: float = 1.5
@export var warning_hold: float = 2.5
@export var warning_fade_out: float = 1.5
## How long the menu takes to fade in from black.
@export var menu_fade_in: float = 1.5

# Static, so the warning only shows once per game launch (not every time you
# come back to the main menu from the pause menu).
static var warning_shown: bool = false

@onready var options_menu: Panel = $OptionsMenu
## Looping background video. Assign an .ogv file to its Stream in the Inspector.
@onready var menu_video: VideoStreamPlayer = get_node_or_null("MenuVideo")

func _ready() -> void:
	if menu_video and menu_video.stream:
		menu_video.play()
	_start_menu_music() # starts from the beginning, together with the warning
	_play_intro()

func _play_intro() -> void:
	# Black cover on top of the whole menu. It also blocks clicks while it is visible.
	var cover := ColorRect.new()
	cover.color = Color.BLACK
	cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	cover.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(cover)

	var tween := create_tween()

	if not warning_shown:
		warning_shown = true
		var warning := Label.new()
		warning.text = warning_text
		warning.set_anchors_preset(Control.PRESET_FULL_RECT)
		warning.offset_left = 40
		warning.offset_right = -40
		warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		warning.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		warning.add_theme_font_override("font", load("res://fonts/PressStart2P-Regular.ttf"))
		warning.add_theme_font_size_override("font_size", 12)
		warning.modulate.a = 0.0
		cover.add_child(warning)

		tween.tween_property(warning, "modulate:a", 1.0, warning_fade_in)
		tween.tween_interval(warning_hold)
		tween.tween_property(warning, "modulate:a", 0.0, warning_fade_out)
		tween.tween_interval(0.3)

	tween.tween_property(cover, "modulate:a", 0.0, menu_fade_in)
	tween.tween_callback(cover.queue_free)

func _start_menu_music() -> void:
	if menu_music:
		MusicPlayer.volume_db = 0.0
		MusicPlayer.play(menu_music, music_fade_in)
	else:
		push_warning("MainMenu: no menu_music assigned in the Inspector.")

func _on_play_button_pressed() -> void:
	MusicPlayer.stop(music_fade_out) # menu song ends when the game starts
	TransitionScene.change_scene("res://Menus/main_level.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_options_button_pressed() -> void:
	options_menu.show()
