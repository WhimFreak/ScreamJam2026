extends Node2D

const CAFE_CONVO_2 = preload("uid://dg620lcleuhem")
const BEDROOM_1 = preload("uid://c6bpiodoi7cxl")

@onready var black_overlay: ColorRect = $BlackScreen/BlackOverlay
@onready var main_camera: Camera2D = %MainCamera

@onready var player: Player = $Player
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var screen_animation_player: AnimationPlayer = %ScreenAnimationPlayer

@onready var ava_jumpscare: AnimationPlayer = $AvaJumpscare
@onready var post_mirror_pos: Node2D = $Cafe/PostMirrorPos
@onready var cafe_may_npc: NPC = %CafeMayNPC
@onready var door_to_house: Teleporter = $Bedroom/DoorToHouse

## Turn off while testing to skip the black-screen intro and start in the room.
@export var play_intro: bool = true

var _screen_fade_tween: Tween

func _ready() -> void:
	Events.fade_to_black.connect(on_fade_to_black)
	Events.fade_to_color.connect(on_fade_to_color)
	Events.fade_to_black_then_color.connect(on_fade_to_black_then_color)
	Events.slow_fade_to_black.connect(on_slow_fade_to_black)
	Events.screen_fade.connect(on_screen_fade)
	if play_intro:
		# Start on a black screen, run the intro text, then the intro_therapy dialogue
		# starts at the end of the "intro" animation (it also fades the screen back in).
		black_overlay.modulate = Color.WHITE
		Events.disable_player_action.emit()
		screen_animation_player.play("intro")

	Events.dialogue_start_request.connect(start_dialogue_tree)
	Events.mirror_jumpscare_start.connect(mirror_jumpscare)
	
func on_fade_to_black():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.WHITE, 1)
	
func on_fade_to_color():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.TRANSPARENT, 1)
	
func on_fade_to_black_then_color():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.WHITE, 1)
	tween.tween_interval(1)
	tween.tween_property(black_overlay, "modulate", Color.TRANSPARENT, 1)

func start_dialogue_tree(tree: DialogueTree):
	dialogue_ui.set_dialogue_tree(tree)
	
func on_slow_fade_to_black():
	var tween := create_tween()
	tween.tween_property(black_overlay, "modulate", Color.WHITE, 5)
	
func mirror_jumpscare():
	Events.disable_player_action.emit()
	ava_jumpscare.play("mirror")
	await ava_jumpscare.animation_finished
	
	ava_jumpscare.play("RESET")
	
	player.global_position = post_mirror_pos.find_child("PlayerPos").global_position
	cafe_may_npc.global_position = post_mirror_pos.find_child("MayPos").global_position
	main_camera.global_position = post_mirror_pos.find_child("CameraPos").global_position
	
	await get_tree().create_timer(1).timeout
	Events.dialogue_start_request.emit(CAFE_CONVO_2)
  await Events.tree_finished
	Events.fade_to_black.emit()
	await get_tree().create_timer(1).timeout
	door_to_house.teleport_here(player)
	Events.dialogue_start_request.emit(BEDROOM_1)
	

func on_screen_fade(to_alpha: float, duration: float):
	if _screen_fade_tween and _screen_fade_tween.is_valid():
		_screen_fade_tween.kill()
	_screen_fade_tween = create_tween()
	_screen_fade_tween.tween_property(black_overlay, "modulate:a", to_alpha, duration)

