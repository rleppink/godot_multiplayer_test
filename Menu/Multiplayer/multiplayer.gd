extends Control

const port = 55443

func _ready() -> void:
	LobbyManager.state_changed.connect(_on_lobby_state_changed)

func _on_host_button_down():
	$ButtonClickedAudio.play()
	LobbyManager.start_hosting(port, $NameLineEdit.text)

func _on_connect_button_down():
	$ButtonClickedAudio.play()
	LobbyManager.start_clienting(
		$IpAddressLineEdit.text,
		port,
		$NameLineEdit.text)

func _on_cancel_button_down():
	$ButtonClickedAudio.play()
	LobbyManager.stop_multiplayering()

func _on_lobby_state_changed(new_state):
	$StateChangedAudio.play()
	$Status.text = str(new_state)
	
	var is_multiplayering = LobbyManager.is_multiplayering()
	$Host.disabled = is_multiplayering
	$Connect.disabled = is_multiplayering
	$Cancel.disabled = !is_multiplayering
	
	$StartGame.disabled = !is_multiplayering && !multiplayer.is_server()

func _on_send_hello_to_host_button_down():
	LobbyManager.load_scene("res://Game/game_root.tscn")

func _on_host_focus_entered():
	$ButtonFocusAudio.play()
