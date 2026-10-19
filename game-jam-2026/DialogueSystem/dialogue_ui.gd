extends Control

@export var dialogue_items: Array[DialogueItem] : set = set_dialogue_items

@onready var portrait : TextureRect = %Portrait
@onready var dialogue_text : RichTextLabel = %DialogueText
@onready var choices_box : HBoxContainer = %ChoicesBox
@onready var dialogue_voice_player: AudioStreamPlayer = %DialogueVoicePlayer

func _ready() -> void:
	show_text(0)

func show_text(current_item_index: int) -> void:
	
	var current_item := dialogue_items[current_item_index]
	dialogue_text.text = current_item.text
	portrait.texture = current_item.portrait
	dialogue_text.visible_ratio = 0.0
	create_buttons(current_item.choices)
	
	var tween := create_tween()
	var text_appearing_duration: float = current_item["text"].length() / 30.0
	tween.tween_property(dialogue_text, "visible_ratio", 1.0, text_appearing_duration)
	
	var sound_max_offset := dialogue_voice_player.stream.get_length() - text_appearing_duration
	var sound_start_position := randf() * sound_max_offset
	dialogue_voice_player.play(sound_start_position)
	tween.finished.connect(dialogue_voice_player.stop)
	
	for button : Button in choices_box.get_children():
			button.modulate.a = 0
			button.disabled = true
	tween.finished.connect(func() -> void:
		var button_tween := create_tween()
		for button : Button in choices_box.get_children():
			button.disabled = false
			button_tween.tween_property(button,"modulate:a", 1.0, 0.3)
			)
	
	slide_in()
	
	update_configuration_warnings()

func slide_in() -> void:
	var slide_tween := create_tween()
	slide_tween.set_ease(Tween.EASE_OUT)
	portrait.position.x = get_viewport_rect().size.x / 7
	slide_tween.tween_property(portrait, "position:x", 0, 0.3)
	portrait.modulate.a = 0
	slide_tween.parallel().tween_property(portrait, "modulate:a", 1, 0.2)
	
func create_buttons(choices_data: Array[DialogueChoices]) -> void:
	for button in choices_box.get_children():
		button.queue_free()
	for choice in choices_data:
		var button := Button.new()
		choices_box.add_child(button)
		button.text = choice.text
		if choice.is_quit == true :
			button.pressed.connect(get_tree().quit)
		else :
			var target_line_index :int = choice.target_line_idx
			button.pressed.connect(show_text.bind(target_line_index))

func set_dialogue_items(new_dialogue_items: Array[DialogueItem]) -> void:
	for index in new_dialogue_items.size():
		if new_dialogue_items[index] == null:
			new_dialogue_items[index] = DialogueItem.new()
	dialogue_items = new_dialogue_items

func _get_configuration_warnings() -> PackedStringArray:
	if dialogue_items.is_empty():
		return ["You need at least one dialogue item for the dialogue system to work."]
	return []
