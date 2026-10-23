extends Node2D

const CAFE_CONVO_2 = preload("uid://dg620lcleuhem")
const MAY_DISCOVERY_2 = preload("uid://4e1o2qxisd2a") # last dialogue of the game

@onready var black_overlay: ColorRect = $Overlays/BlackOverlay
@onready var main_camera: Camera2D = %MainCamera
@onready var red_tint: ColorRect = $OverDialogueOverlays/RedTint

@onready var player: Player = $Player
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var screen_animation_player: AnimationPlayer = %ScreenAnimationPlayer

@onready var ava_jumpscare: AnimationPlayer = $AvaJumpscare
@onready var post_mirror_pos: Node2D = $Cafe/PostMirrorPos
@onready var cafe_may_npc: Sprite2D = $Cafe/CafeMayNPC
@onready var abigail_npc: Sprite2D = $Cafe/AbigailNPC
@onready var mark_npc: Sprite2D = $Cafe/MarkNPC
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
	Events.fade_in_red_tint.connect(on_fade_in_red_tint)
	Events.fade_out_red_tint.connect(on_fade_out_red_tint)
	
	if play_intro:
		# Start on a black screen, run the intro text, then the intro_therapy dialogue
		# starts at the end of the "intro" animation (it also fades the screen back in).
		black_overlay.modulate = Color.WHITE
		Events.disable_player_action.emit()
		screen_animation_player.play("intro")

	Events.dialogue_start_request.connect(start_dialogue_tree)
	Events.mirror_jumpscare_start.connect(mirror_jumpscare)
	Events.tree_finished.connect(_on_tree_finished)

	#door_to_house.start_scene(player)
	#$House/DoorToBedroom.start_scene(player)
	
	#await get_tree().create_timer(1).timeout
	#$TherapyOutdoors/DoorToCafe.start_cafe_scene = true
	#$TherapyOutdoors/DoorToCafe.on_interact(player)
	
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
	
func on_fade_in_red_tint():
	var tween := create_tween()
	tween.tween_property(red_tint, "modulate", Color("ffffff40"), 1)
	
func on_fade_out_red_tint():
	var tween := create_tween()
	tween.tween_property(red_tint, "modulate", Color.TRANSPARENT, 1)
	
func mirror_jumpscare():
	# Wait for the washroom dialogue to fully end first, so the jumpscare and the
	# dialogue never run at the same time (the dialogue's end re-enables the player,
	# so we lock the player again right after).
	await Events.tree_finished
	Events.disable_player_action.emit()

	ava_jumpscare.play("mirror")
	await ava_jumpscare.animation_finished

	# Reset the mirror image / red tint / blur, then go dark again
	ava_jumpscare.play("RESET")
	ava_jumpscare.advance(0) # apply the reset right now
	black_overlay.modulate = Color.WHITE

	player.global_position = post_mirror_pos.find_child("PlayerPos").global_position
	player.sitting = false
	cafe_may_npc.global_position = post_mirror_pos.find_child("MayPos").global_position
	cafe_may_npc.frame = 0
	cafe_may_npc.flip_h = true
	main_camera.global_position = post_mirror_pos.find_child("CameraPos").global_position
	abigail_npc.hide()
	mark_npc.hide()
	
	await get_tree().create_timer(1).timeout
	Events.fade_to_color.emit() # fade in from black
	await get_tree().create_timer(1).timeout
	Events.dialogue_start_request.emit(CAFE_CONVO_2)
	await Events.tree_finished
	Events.fade_to_black.emit()
	await get_tree().create_timer(1).timeout
	door_to_house.start_scene(player)
	
func _on_tree_finished(tree: DialogueTree) -> void:
	if tree == MAY_DISCOVERY_2:
		play_ending()

## Black fade, "Thanks for playing", then quit the game.
func play_ending() -> void:
	Events.disable_player_action.emit()
	MusicPlayer.stop(3.0)

	# Built in code on a top layer so it covers everything, including the dialogue
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	var black := ColorRect.new()
	black.color = Color.BLACK
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_STOP # block clicks
	black.modulate.a = 0.0
	layer.add_child(black)

	var label := Label.new()
	label.text = "Thanks for playing"
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", load("res://fonts/PressStart2P-Regular.ttf"))
	label.add_theme_font_size_override("font_size", 16)
	label.modulate.a = 0.0
	layer.add_child(label)

	var tween := create_tween()
	tween.tween_property(black, "modulate:a", 1.0, 2.0)
	tween.tween_property(label, "modulate:a", 1.0, 1.5)
	tween.tween_interval(3.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_interval(0.5)
	tween.tween_callback(get_tree().quit)

func on_screen_fade(to_alpha: float, duration: float):
	if _screen_fade_tween and _screen_fade_tween.is_valid():
		_screen_fade_tween.kill()
	_screen_fade_tween = create_tween()
	_screen_fade_tween.tween_property(black_overlay, "modulate:a", to_alpha, duration)
