class_name Player
extends CharacterBody2D

@export var speed: float = 50
@export var accel: float = 1500

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_label: RichTextLabel = $InteractionLabel

var interactables_in_range: Array[InteractableComponent]

var last_dir: Vector2
var can_act: bool = true

func _ready() -> void:
	Events.disable_player_action.connect(func(): can_act = false)
	Events.enable_player_action.connect(func(): can_act = true)

func _process(delta: float) -> void:
	if not can_act:
		return
		
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = velocity.move_toward(dir * speed, accel * delta)
	move_and_slide()
	
	if dir:
		animated_sprite_2d.play("walk")
		last_dir = dir
	else:
		animated_sprite_2d.play("default")
		
	# Face towards the last direction even when stopped
	if last_dir.x != 0:
		animated_sprite_2d.flip_h = last_dir.x < 0
	
# Interaction
func _input(event: InputEvent) -> void:
	if not can_act:
		animated_sprite_2d.play("default")
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
