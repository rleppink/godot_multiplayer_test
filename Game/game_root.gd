extends Node2D


var local_player : Player


func _ready() -> void:
	if multiplayer.is_server():
		_spawn_characters()


func _process(_delta):
	_highlight_player_target()


func _highlight_player_target():
	var player_local_position : Vector2i = %TileMap.to_local(local_player.center)
	var cell : Vector2i = %TileMap.local_to_map(player_local_position)
	var target_cell := cell + local_player.target_direction
	var cell_local_position : Vector2 = %TileMap.map_to_local(target_cell)
	$Target.position = %TileMap.to_global(cell_local_position)


func _tween_target():
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property($Target, "scale", Vector2(-0.5, -0.5), 0.16).as_relative()
	tween.tween_property($Target, "scale", Vector2(0.5, 0.5), 0.16).as_relative()


func _spawn_characters():
	var i := 0
	for peer_id in LobbyManager.get_all_peer_ids():
		var character := _spawn_character(
				%PlayerSpawnPositions.get_children()[i].position,
				peer_id)
		
		if peer_id ==  multiplayer.get_unique_id():
			local_player = character

		i += 1


func _spawn_character(spawn_position: Vector2, player_id: int) -> Player:
	var character = preload("res://Game/player.tscn").instantiate()
	character.position = spawn_position
	character.name = "Character_%s" % str(player_id)

	character.player_id = player_id
	var peer_config = LobbyManager.get_peer_config(player_id)
	character.player_name = peer_config["player_name"]
	character.color = peer_config["player_color"]

	$PlayerSpawner.add_child(character, true)

	return character
