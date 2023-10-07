extends Node2D


func _ready() -> void:
	if multiplayer.is_server():
		_spawn_characters()

func _process(_delta) -> void:
	move()

func _spawn_characters():
	var i := 1
	for peer_id in LobbyManager.get_peers().keys():
		_spawn_character(Vector2(i * 300, 300), peer_id)
		i += 1

func _spawn_character(spawn_position: Vector2, player_id: int) -> void:
	var character = preload("res://Game/player.tscn").instantiate()
	character.position = spawn_position
	character.player_id = player_id
	character.name = str(player_id)
	add_child(character, true)

func move():
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_request_move.rpc(direction)

@rpc("any_peer", "call_local")
func _request_move(direction: Vector2):
	if not multiplayer.is_server():
		return
	
	var player_id := multiplayer.get_remote_sender_id()
	var player_character : CharacterBody2D
	for node in get_children():
		if not node is CharacterBody2D:
			continue
		
		if not node.player_id == player_id:
			continue
		
		player_character = node
	
	if not player_character:
		push_error("Tried to move character that doesn't exist")
	
	player_character.move(direction)
