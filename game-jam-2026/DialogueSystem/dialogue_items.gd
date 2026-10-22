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

@export_group("fullscreen image")
## Full-screen image shown behind the dialogue box once this line is advanced past.
@export var show_image_after: Texture2D
## Hides the full-screen image once this line is advanced past (ignored if show_image_after is set).
@export var hide_image_after: bool = false
@export_range(0.0, 5.0, 0.1, "or_greater", "suffix:s") var image_fade_time: float = 0.5

@export_group("music")
## Background music that starts (crossfades in) when this line appears. Empty keeps the current music.
@export var music: AudioStream
## Fades the background music out when this line appears (ignored if music is set).
@export var stop_music: bool = false
@export_range(0.0, 10.0, 0.1, "or_greater", "suffix:s") var music_fade_time: float = 1.0
@export var music_volume_db: float = 0.0

func set_choices(new_choices: Array[DialogueChoices]) -> void:
	for index in new_choices.size():
		if new_choices[index] == null:
			new_choices[index] = DialogueChoices.new()
	choices = new_choices
