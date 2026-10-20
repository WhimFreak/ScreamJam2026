extends CanvasLayer

@onready var dialogue_ui: Control = $DialogueUI

func set_dialogue_tree(tree: DialogueTree):
	dialogue_ui.dialogue_tree = tree
	dialogue_ui.start_tree()
	
