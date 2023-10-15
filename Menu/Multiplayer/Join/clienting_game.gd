extends Control


func _ready():
	LobbyManager.player_joined.connect(_on_player_joined)
	LobbyManager.player_left.connect(_on_player_left)
	LobbyManager.start_clienting(ConfigManager.get_value("ip_address"))


func _on_player_joined(_player_id: int):
	_build_player_list()
	%PlayerJoinedAudio.play()


func _on_player_left(_player_id: int):
	_build_player_list()
	%PlayerLeftAudio.play()


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Menu/Multiplayer/host_or_join.tscn")


func _build_player_list():
	%PlayerList.clear()
	for player_config in LobbyManager.get_all_peers().values():
		print(player_config)
		%PlayerList.add_item(player_config["player_name"], null, false)
