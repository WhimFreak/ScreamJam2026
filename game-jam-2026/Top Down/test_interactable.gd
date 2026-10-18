extends StaticBody2D

@onready var tv_forecast: Sprite2D = $TvForecast

func _ready() -> void:
	z_index = round(position.y)

func _on_interactable_component_player_interacted() -> void:
	tv_forecast.visible = not tv_forecast.visible
