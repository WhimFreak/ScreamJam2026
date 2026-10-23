class_name DialogueChoices extends Resource

@export var text := ""
@export_range(0,100) var target_line_idx : int = 0
@export var end_branch_idx: int = 0
@export var convergence_idx: int = 0 ## Skips here after branch is finished
@export var is_quit : bool = false
