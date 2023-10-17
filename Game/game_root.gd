extends Node2D


func _ready() -> void:
	if multiplayer.is_server():
		_spawn_characters()


func _spawn_characters():
	var i := 0
	for peer_id in LobbyManager.get_all_peer_ids():
		_spawn_character(
				%PlayerSpawnPositions.get_children()[i].position,
				peer_id)
		i += 1


func _spawn_character(spawn_position: Vector2, player_id: int) -> void:
	var character = preload("res://Game/player.tscn").instantiate()
	character.position = spawn_position
	character.name = "Character_%s" % str(player_id)

	character.player_id = player_id
	var peer_config = LobbyManager.get_peer_config(player_id)
	character.player_name = peer_config["player_name"]
	character.color = peer_config["player_color"]

	$PlayerSpawner.add_child(character, true)