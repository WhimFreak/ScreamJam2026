class_name Player
extends CharacterBody2D

@export var speed: float = 50
@export var accel: float = 600
@export_enum("Rudy", "May") var cur_char: String = "Rudy":
	set(val):
		cur_char = val
		if animation_player:
			animation_player.play("idle_" + val.to_lower())
@export var sitting: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var interaction_label: RichTextLabel = $InteractionLabel
@onready var interaction_range: Area2D = $InteractionRange
@onready var walker : AudioStreamPlayer = %walker
@onready var animation_player = %AnimationPlayer

var interactables_in_range: Array[InteractableComponent]

var last_dir: Vector2
var can_act: bool = true

func _ready() -> void:
	Events.disable_player_action.connect(
		func():
			can_act = false
			velocity = Vector2.ZERO
			walker.stop())
	Events.enable_player_action.connect(
		func():
			can_act = true
			sitting = false)
	cur_char = cur_char

func _physics_process(delta:float) -> void:
	if sitting:
		walker.stop()
		animation_player.play("sit_rudy")
		sprite_2d.z_index = 2
		return

	sprite_2d.z_index = 0

	if not can_act:
		walker.stop() # no footsteps while a dialogue/cutscene has control
		animation_player.play("idle_" + cur_char.to_lower())
		interaction_label.hide()
		return
		
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = velocity.move_toward(dir * speed, accel * delta)
	move_and_slide()
	
	if velocity.x < 0:
		sprite_2d.flip_h = true
	elif velocity.x > 0:
		sprite_2d.flip_h = false
	# Face towards the last direction even when stopped
	if last_dir.x != 0:
		sprite_2d.flip_h = last_dir.x < 0
	
	if velocity.length() > 0.0:
		animation_player.play("walk_" + cur_char.to_lower())
		if not walker.playing:
			walker.play()
	else:
		animation_player.stop()
		sprite_2d.frame = 0
		walker.stop()
		
# Interaction
func _input(event: InputEvent) -> void:
	if not can_act:
		return
	
	if event.is_action_pressed("interact") and not interactables_in_range.is_empty():
		interactables_in_range[0].player_interacted.emit(self)
	
func _on_interaction_range_area_entered(area: Area2D) -> void:
	if area.get_parent() is InteractableComponent:
		interactables_in_range.append(area.get_parent())
	
	if not interactables_in_range.is_empty():
		interaction_label.show()
	else:
		interaction_label.hide()

func _on_interaction_range_area_exited(area: Area2D) -> void:
	if area.get_parent() is InteractableComponent:
		interactables_in_range.erase(area.get_parent())
		
	if not interactables_in_range.is_empty():
		interaction_label.show()
	else:
		interaction_label.hide()
