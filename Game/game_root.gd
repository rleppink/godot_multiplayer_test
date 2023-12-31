extends Node2D


func _ready() -> void:
	%PlayerSpawner.spawn_function = _spawn_character

	if multiplayer.is_server():
		_spawn_characters()
		$RestartButton.visible = true


func _spawn_characters() -> void:
	var i := 0
	for peer_id in LobbyManager.get_all_peer_ids():
		var player_spawn_data := _build_spawn_data(peer_id, i)
		%PlayerSpawner.spawn(player_spawn_data)

		i += 1


## MultiplayerSpawner's spawn_function
## Runs on every peer, spawn_data is received from server
func _spawn_character(spawn_data: Dictionary) -> Player:
	var character = preload("res://Game/player.tscn").instantiate()
	character.position = spawn_data.spawn_position
	character.name = "Character_%s" % str(spawn_data.id)
	character.player_id = spawn_data.id
	character.player_name = spawn_data.name
	character.color = spawn_data.color
	character.tile_map = %TileMap

	return character


func _build_spawn_data(player_id: int, spawn_position_index: int) -> Dictionary:
	var peer_config := LobbyManager.get_peer_config(player_id)
	var spawn_data := {
		"id": player_id,
		"spawn_position": %PlayerSpawnPositions.get_children()[spawn_position_index].position,
		"name": peer_config["player_name"],
		"color": peer_config["player_color"],
	}

	return spawn_data


func _on_restart_button_pressed():
	if not multiplayer.is_server():
		return

	restart_game.rpc()


@rpc("authority", "call_local")
func restart_game() -> void:
	get_tree().reload_current_scene()
