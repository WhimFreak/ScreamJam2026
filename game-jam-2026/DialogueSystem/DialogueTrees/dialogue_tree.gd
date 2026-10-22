class_name DialogueTree
extends Resource

@export var dialogue_items: Array[DialogueItem] : set = set_dialogue_items

@export_group("music")
## Background music for this whole scene/conversation. Starts when the tree starts; individual lines can still change it.
@export var music: AudioStream
@export_range(0.0, 10.0, 0.1, "or_greater", "suffix:s") var music_fade_time: float = 1.0

func set_dialogue_items(new_dialogue_items: Array[DialogueItem]) -> void:
	for index in new_dialogue_items.size():
		if new_dialogue_items[index] == null:
			new_dialogue_items[index] = DialogueItem.new()
	dialogue_items = new_dialogue_items
