extends NPC

func on_tree_finished(tree: DialogueTree):
	if tree == dialogue_trees[next_tree_idx]:
		interactable = false
		if dialogue_trees.size() > next_tree_idx + 1:
			next_tree_idx += 1
