extends Control


func _ready():
	LobbyManager.player_joined.connect(_on_player_joined)

	for ip in _try_get_ips():
		%IPAddresses.add_item(ip, null, false)


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


func _on_player_joined(_player_id: int, player_config: Dictionary):
	%PlayerList.add_item(player_config["name"], null, false)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Menu/Multiplayer/host_or_join.tscn")
