extends Control


func _ready():
	LobbyManager.player_joined.connect(_on_player_joined)
	LobbyManager.player_left.connect(_on_player_left)
	LobbyManager.start_hosting()

	%IPAddresses.clear()
	for ip in _try_get_ips():
		%IPAddresses.add_item(ip, null, false)

	_build_player_list()


## Gets all IP addresses reserved for use on private internets
## https://www.ietf.org/rfc/rfc1918.html#section-3
func _try_get_ips() -> Array[String]:
	var local_addresses := IP.get_local_addresses()
	var user_addresses : Array[String] = []
	for address in local_addresses:
		if address.begins_with("192.168.") \
			|| address.begins_with("172.16.") \
			|| address.begins_with("10."):
			user_addresses.append(address)
	
	return user_addresses


func _on_player_joined(_player_id: int):
	_build_player_list()
	%PlayerJoinedAudio.play()


func _on_player_left(_player_id: int):
	_build_player_list()
	%PlayerLeftAudio.play()


func _on_back_button_pressed():
	LobbyManager.stop_multiplayering()
	get_tree().change_scene_to_file("res://Menu/Multiplayer/host_or_join.tscn")


func _build_player_list():
	%PlayerList.clear()
	for player_config in LobbyManager.get_all_peers().values():
		%PlayerList.add_item(player_config["player_name"], null, false)


func _on_start_level_pressed():
	LobbyManager.load_scene("res://Game/game_root.tscn")
