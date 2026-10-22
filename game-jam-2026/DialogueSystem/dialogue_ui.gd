extends Control

@export var dialogue_tree: DialogueTree

@onready var portrait : TextureRect = %Portrait
@onready var dialogue_text : RichTextLabel = %DialogueText
@onready var choices_box : VBoxContainer = %ChoicesBox
@onready var dialogue_voice_player: AudioStreamPlayer = %DialogueVoicePlayer
@onready var sound_effect_player: AudioStreamPlayer = %SoundEffectPlayer
@onready var character_name: Label = %CharacterName
@onready var fullscreen_image: TextureRect = %FullscreenImage

var abigail_voice = preload("uid://een5bkj7ap6")
var demonic_voice = preload("uid://bdw1i2a1fyd3e")
var may_voice = preload("uid://dq4onou3d1n0x")
var mark_voice = preload("uid://cafdmuy66bfns")
var rudy_voice = preload("uid://bnmdpjo2onaij")
var rosila_voice = preload("uid://0tf1liw4fv8i")


var _image_tween: Tween
var _text_tween: Tween
var current_item: DialogueItem
var is_transitioning: bool = true  # true while advancing between lines; blocks all input
	
func start_tree():
	show()
	Events.disable_player_action.emit()
	if dialogue_tree.music:
		MusicPlayer.play(dialogue_tree.music, dialogue_tree.music_fade_time)
	show_text(0)

func show_text(current_item_index: int) -> void:
	if current_item_index < 0 or current_item_index >= dialogue_tree.dialogue_items.size():
		Events.enable_player_action.emit()
		Events.tree_finished.emit(dialogue_tree)
		hide()
		return
	
	current_item = dialogue_tree.dialogue_items[current_item_index]
	visible = true

	MusicPlayer.volume_db = current_item.music_volume_db
	if current_item.music:
		MusicPlayer.play(current_item.music, current_item.music_fade_time)
	elif current_item.stop_music:
		MusicPlayer.stop(current_item.music_fade_time)
	

	if _text_tween and _text_tween.is_valid():
		_text_tween.kill()
	dialogue_voice_player.stop()
	
	character_name.text = current_item.character_name
	character_name.visible = not current_item.character_name.is_empty()
	
	dialogue_text.text = current_item.text
	portrait.texture = current_item.portrait
	dialogue_text.visible_ratio = 0.0
	create_buttons(current_item_index, current_item.choices)
	
	if current_item.sound_effect != null:
		sound_effect_player.stream = current_item.sound_effect
		sound_effect_player.play()
	else:
		sound_effect_player.stop()
	
	_text_tween = create_tween()
	_text_tween.set_speed_scale(current_item.base_speed)
	var text_appearing_duration: float = current_item["text"].length() / 30.0
	_text_tween.tween_property(dialogue_text, "visible_ratio", 1.0, text_appearing_duration)
	if current_item.character_name == "Rosila":
		dialogue_voice_player.stream = rosila_voice
	elif  current_item.character_name == "Mark":
		dialogue_voice_player.stream = mark_voice
	elif current_item.character_name == "Abigail":
		dialogue_voice_player.stream = abigail_voice
	elif current_item.character_name == "May":
		dialogue_voice_player.stream = may_voice
	elif current_item.character_name == "rudy":
		dialogue_voice_player.stream = rudy_voice
	elif current_item.character_name == "Ava":
		dialogue_voice_player.stream = demonic_voice
	else:
		dialogue_voice_player.stream = rudy_voice
	
	
	
	
	
	
	var sound_max_offset := maxf(dialogue_voice_player.stream.get_length() - text_appearing_duration, 0.0)
	var sound_start_position := randf() * sound_max_offset
	dialogue_voice_player.play(sound_start_position)
	
	for button : Button in choices_box.get_children():
			button.modulate.a = 0
			button.disabled = true
	
	_text_tween.finished.connect(_on_text_finished.bind(current_item_index))
	
	slide_in()
	
	is_transitioning = false  # reveal is now running; input is allowed again (to skip or wait)

func _on_text_finished(item_index: int) -> void:
	if item_index != dialogue_tree.dialogue_items.find(current_item):
		return  # stale call from a skipped/killed tween, ignore
	
	dialogue_text.visible_ratio = 1.0
	dialogue_voice_player.stop()

	var item := dialogue_tree.dialogue_items[item_index]

	if item.choices.is_empty() and not item.click_advance:
		is_transitioning = true
		await get_tree().create_timer(item.auto_advance_delay).timeout
		is_transitioning = false
		advance(item_index, item_index + 1)
		return

	# Prevents message errors when no choice
	if choices_box.get_children().is_empty():
		return
		
	var button_tween := create_tween()
	for button : Button in choices_box.get_children():
		button.disabled = false
		button_tween.tween_property(button, "modulate:a", 1.0, 0.3)

func advance(from_index: int, target_index: int) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	var item: DialogueItem = dialogue_tree.dialogue_items[from_index]
	if item.signal_on_advance:
		Events.emit_signal(item.signal_on_advance)

	if item.show_image_after:
		show_image(item.show_image_after, item.image_fade_time)
	elif item.hide_image_after:
		hide_image(item.image_fade_time)

	for button : Button in choices_box.get_children():
		button.disabled = true
	
	var delay := item.delay_before_next
	if delay > 0.0:
		visible = false
		await get_tree().create_timer(delay).timeout
	show_text(target_index)

## Shows a full-screen image behind the dialogue box. It stays until hide_image() is called.
func show_image(texture: Texture2D, fade_time: float = 0.5) -> void:
	if _image_tween and _image_tween.is_valid():
		_image_tween.kill()
	var was_visible := fullscreen_image.visible
	fullscreen_image.texture = texture
	fullscreen_image.show()
	if was_visible:
		# Swapping one image for another: no fade, just replace
		fullscreen_image.modulate.a = 1.0
	elif fade_time > 0.0:
		fullscreen_image.modulate.a = 0.0
		_image_tween = create_tween()
		_image_tween.tween_property(fullscreen_image, "modulate:a", 1.0, fade_time)
	else:
		fullscreen_image.modulate.a = 1.0

func hide_image(fade_time: float = 0.5) -> void:
	if not fullscreen_image.visible:
		return
	if _image_tween and _image_tween.is_valid():
		_image_tween.kill()
	if fade_time > 0.0:
		_image_tween = create_tween()
		_image_tween.tween_property(fullscreen_image, "modulate:a", 0.0, fade_time)
		_image_tween.tween_callback(fullscreen_image.hide)
	else:
		fullscreen_image.hide()

func slide_in() -> void:
	var slide_tween := create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	portrait.position.x = get_viewport_rect().size.x / 7
	slide_tween.tween_property(portrait, "position:x", 17, 0.3)
	portrait.modulate.a = 0
	slide_tween.parallel().tween_property(portrait, "modulate:a", 1, 0.2)
	
func create_buttons(item_index: int, choices_data: Array[DialogueChoices]) -> void:
	for button in choices_box.get_children():
		choices_box.remove_child(button)
		button.queue_free()

	for choice in choices_data:
		var button := Button.new()
		button.text = choice.text
		button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_EXPAND_FILL
		choices_box.add_child(button)
		if choice.is_quit:
			button.pressed.connect(get_tree().quit)
		else:
			button.pressed.connect(advance.bind(item_index, choice.target_line_idx))

func _get_configuration_warnings() -> PackedStringArray:
	if dialogue_tree.dialogue_items.is_empty():
		return ["You need at least one dialogue item for the dialogue system to work."]
	return []

func _input(event: InputEvent) -> void:
	if is_transitioning:
		return
	if (event.is_action_pressed("left_mouse") or event.is_action_pressed("space")) and current_item.click_advance:
		var idx: int = dialogue_tree.dialogue_items.find(current_item)
		if _text_tween and _text_tween.is_valid() and _text_tween.is_running():
			_text_tween.set_speed_scale(40.0)
		elif current_item.choices.is_empty():
			advance(idx, idx + 1)
