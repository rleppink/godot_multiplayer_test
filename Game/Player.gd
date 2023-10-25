extends CharacterBody2D
class_name Player


signal action_requested

const SPEED = 400.0

@export var player_id: int
@export var player_name: String
@export var velocity_sync: Vector2
@export var color: Color

var target_direction: Vector2i
var center : Vector2
var tile_map : TileMap


func _ready():
	$NameLabel.text = player_name
	$AnimatedSprite2D.modulate = Color(
		0.8 + clamp(color.r, 0.0, 0.5),
		0.8 + clamp(color.g, 0.0, 0.5),
		0.8 + clamp(color.b, 0.0, 0.5),
		255)

	if player_id == multiplayer.get_unique_id():
		%Target.visible = true
		_tween_target()


func _process(_delta: float) -> void:
	if player_id == multiplayer.get_unique_id():
		_process_movement()
		_process_action()

	z_index = int(round(position.y))

	center = to_global($CollisionShape2D.position)

	if player_id == multiplayer.get_unique_id():
		_highlight_target()

	_process_character_animation()


func _process_movement():
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		target_direction = direction

	if not multiplayer.is_server():
		_move(direction)

	_request_move.rpc_id(1, direction)


@rpc("any_peer", "call_local")
func _request_move(direction: Vector2):
	if not multiplayer.is_server():
		return
	
	_move(direction)


func _move(direction: Vector2):
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED
	
	velocity_sync = velocity
		
	move_and_slide()


func _process_action():
	if !Input.is_action_just_pressed("action"):
		return

	print("Action pressed!")


func _process_character_animation():
	if velocity_sync:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
	
	if velocity_sync.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity_sync.x > 0:
		$AnimatedSprite2D.flip_h = false


func _highlight_target():
	var local_position : Vector2i = tile_map.to_local(center)
	var cell : Vector2i = tile_map.local_to_map(local_position)
	var target_cell := cell + target_direction
	var cell_local_position : Vector2 = tile_map.map_to_local(target_cell)
	%Target.position = tile_map.to_global(cell_local_position)


func _tween_target():
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(%Target, "scale", Vector2(-0.5, -0.5), 0.16).as_relative()
	tween.tween_property(%Target, "scale", Vector2(0.5, 0.5), 0.16).as_relative()
