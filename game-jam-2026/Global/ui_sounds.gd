extends Node
## Plays a click sound whenever any button in the game is pressed.

const CLICK_SOUND_PATH := "res://sounds/sfx/click.mp3"  # change this to your sound file


var _player := AudioStreamPlayer.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # also works while the game is paused
	if ResourceLoader.exists(CLICK_SOUND_PATH):
		_player.stream = load(CLICK_SOUND_PATH)
	else:
		push_warning("UISounds: click sound not found at " + CLICK_SOUND_PATH)
	add_child(_player)
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node is BaseButton and not node.pressed.is_connected(_play_click):
		node.pressed.connect(_play_click)

func _play_click() -> void:
	if _player.stream:
		_player.play()
