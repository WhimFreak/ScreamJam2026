class_name DialogueItem extends BaseDialogue

@export_group("choices")
@export var choices : Array[DialogueChoices] : set = set_choices


func set_choices(new_choices: Array[DialogueChoices]) -> void:
	for index in new_choices.size():
		if new_choices[index] == null:
			new_choices[index] = DialogueChoices.new()
	choices = new_choices
