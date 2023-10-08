extends CharacterBody2D


const SPEED = 500.0

@export var player_id: int
@export var player_name: String
@export var velocity_sync: Vector2
@export var color: Color

func _ready():
	$NameLabel.text = player_name
	$AnimatedSprite2D.modulate = color

func _process(_delta: float) -> void:
	z_index = int(round(position.y))
	
	if velocity_sync:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")
	
	if velocity_sync.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity_sync.x > 0:
		$AnimatedSprite2D.flip_h = false

func move(direction: Vector2):
	velocity.x = direction.x * SPEED
	velocity.y = direction.y * SPEED
	
	velocity_sync = velocity
		
	move_and_slide()
