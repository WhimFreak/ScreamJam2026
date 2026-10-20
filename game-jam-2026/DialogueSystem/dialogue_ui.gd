extends Control

signal dialogue_finished

@export var dialogue_tree: DialogueTree

@onready var portrait : TextureRect = %Portrait
@onready var dialogue_text : RichTextLabel = %DialogueText
@onready var choices_box : HBoxContainer = %ChoicesBox
@onready var dialogue_voice_player: AudioStreamPlayer = %DialogueVoicePlayer
@onready var sound_effect_player: AudioStreamPlayer = %SoundEffectPlayer

var _text_tween: Tween
var current_item: DialogueItem
var is_transitioning: bool = true  # true while advancing between lines; blocks all input

func _ready() -> void:
	start_tree()
	
func start_tree():
	show()
	Events.disable_player_action.emit()
	show_text(0)

func show_text(current_item_index: int) -> void:
	if current_item_index < 0 or current_item_index >= dialogue_tree.dialogue_items.size():
		dialogue_finished.emit()
		Events.enable_player_action.emit()
		hide()
		return
	
	current_item = dialogue_tree.dialogue_items[current_item_index]
	visible = true
	
	if _text_tween and _text_tween.is_valid():
		_text_tween.kill()
	dialogue_voice_player.stop()
	
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
	var text_appearing_duration: float = current_item["text"].length() / 30.0
	_text_tween.tween_property(dialogue_text, "visible_ratio", 1.0, text_appearing_duration)
	dialogue_voice_player.stream = current_item.dialogue_sound
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

	var button_tween := create_tween()
	for button : Button in choices_box.get_children():
		button.disabled = false
		button_tween.tween_property(button, "modulate:a", 1.0, 0.3)

func advance(from_index: int, target_index: int) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	
	for button : Button in choices_box.get_children():
		button.disabled = true
	
	var delay := dialogue_tree.dialogue_items[from_index].delay_before_next
	if delay > 0.0:
		visible = false
		await get_tree().create_timer(delay).timeout
	show_text(target_index)

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
		if button.text == "continue":
			button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
		else:
			button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_SHRINK_CENTER
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
	if event.is_action_pressed("left_mouse") and current_item.click_advance:
		var idx: int = dialogue_tree.dialogue_items.find(current_item)
		if _text_tween and _text_tween.is_valid() and _text_tween.is_running():
			_text_tween.set_speed_scale(3.0)
		elif current_item.choices.is_empty():
			advance(idx, idx + 1)
