class_name DialogueItem extends BaseDialogue

@export_group("choices")
@export var choices : Array[DialogueChoices] : set = set_choices
@export var click_advance : bool = true ## Advance/complete text by clicking. Disable to auto advance
@export var auto_advance_delay: float = 0.5 ## Amount of time text stays on dialoguebox before auto advancing. (Disable click_advance)

@export_group("timing")
@export_range(0.0, 60.0, 0.1, "or_greater", "suffix:s") var delay_before_next : float = 0.0
@export var base_speed: float = 1

@export_group("effect")
@export var signal_on_advance: String

func set_choices(new_choices: Array[DialogueChoices]) -> void:
	for index in new_choices.size():
		if new_choices[index] == null:
			new_choices[index] = DialogueChoices.new()
	choices = new_choices
