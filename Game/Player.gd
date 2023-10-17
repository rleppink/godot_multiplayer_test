extends CharacterBody2D


const SPEED = 500.0

@export var player_id: int
@export var player_name: String
@export var velocity_sync: Vector2
@export var color: Color


func _ready():
	$NameLabel.text = player_name
	$AnimatedSprite2D.modulate = Color(
		0.8 + clamp(color.r, 0.0, 0.5),
		0.8 + clamp(color.g, 0.0, 0.5),
		0.8 + clamp(color.b, 0.0, 0.5),
		255)


func _process(_delta: float) -> void:
	process_input()

	z_index = int(round(position.y))
	
	if velocity_sync:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
	
	if velocity_sync.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity_sync.x > 0:
		$AnimatedSprite2D.flip_h = false


func process_input():
	if player_id != multiplayer.get_unique_id():
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if not multiplayer.is_server():
		_move(direction)

	_request_move.rpc(direction)


func _move(direction: Vector2):
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED
	
	velocity_sync = velocity
		
	move_and_slide()


@rpc("any_peer", "call_local")
func _request_move(direction: Vector2):
	if not multiplayer.is_server():
		return
	
	_move(direction)