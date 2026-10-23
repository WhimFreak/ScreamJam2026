extends Panel

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

func _ready() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear(1)
	sfx_slider.value = AudioServer.get_bus_volume_linear(2)

func _on_return_button_pressed() -> void:
	hide()

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value)
