extends Node

signal dialogue_start_request(tree: DialogueTree)

signal disable_player_action
signal enable_player_action

signal tree_finished(tree: DialogueTree)

signal enable_cafe_scene

signal fade_to_black
signal fade_to_color
signal fade_to_black_then_color
signal slow_fade_to_black
signal fade_in_red_tint
signal fade_out_red_tint

signal stop_blur

signal mirror_jumpscare_start

signal screen_fade(to_alpha: float, duration: float)
