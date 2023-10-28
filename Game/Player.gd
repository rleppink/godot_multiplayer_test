extends CharacterBody2D
class_name Player


const SPEED = 400.0

@export var player_id: int
@export var player_name: String
@export var velocity_sync: Vector2
@export var color: Color

var target_direction: Vector2i
var center : Vector2
var tile_map : TileMap
var carrying_block : BlockTile :
		set (value):
			carrying_block = value
			%CarriedBlock.visible = carrying_block != null


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

	if not multiplayer.is_server():
		velocity = velocity_sync

	z_index = int(round(position.y))

	center = to_global($CollisionShape2D.position)

	if player_id == multiplayer.get_unique_id():
		_highlight_target()

	_process_character_animation()


func _process_movement():
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		target_direction = direction

	# Simple client side prediction
	# If the server has a different value, it will be synchronized to the
	# client, overwriting what the client thinks is its position
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

	_request_action.rpc_id(1, _get_my_tilemap_target())


@rpc("any_peer", "call_local", "reliable")
func _request_action(target: Vector2i):
	if not multiplayer.is_server():
		return

	_pickup_or_place_tile.rpc(target)


@rpc("authority", "call_local", "reliable")
func _pickup_or_place_tile(target: Vector2i):
	if not carrying_block:
		var source_id := tile_map.get_cell_source_id(2, target)
		if source_id == -1:
			return

		carrying_block = BlockTile.new()
		carrying_block.source_id = source_id
		carrying_block.atlas_coords = tile_map.get_cell_atlas_coords(2, target)

		%CarriedBlock.region_rect = Rect2(
				18 * carrying_block.atlas_coords.x,
				18 * carrying_block.atlas_coords.y,
				18,
				18)

		tile_map.erase_cell(2, target)
	else:
		if tile_map.get_cell_source_id(1, target) != -1 || \
				tile_map.get_cell_source_id(2, target) != -1:
			return

		tile_map.set_cell(
				2,
				target,
				carrying_block.source_id,
				carrying_block.atlas_coords)

		carrying_block = null


func _process_character_animation():
	if velocity_sync:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
	
	if velocity_sync.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity_sync.x > 0:
		$AnimatedSprite2D.flip_h = false


func _get_my_tilemap_position() -> Vector2i:
	var local_position : Vector2i = tile_map.to_local(center)
	return tile_map.local_to_map(local_position)


func _get_my_tilemap_target() -> Vector2i:
	return _get_my_tilemap_position() + target_direction


func _highlight_target():
	var cell_local_position : Vector2 = tile_map.map_to_local(_get_my_tilemap_target())
	%Target.position = tile_map.to_global(cell_local_position)


func _tween_target():
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(%Target, "scale", Vector2(-0.5, -0.5), 0.16).as_relative()
	tween.tween_property(%Target, "scale", Vector2(0.5, 0.5), 0.16).as_relative()
