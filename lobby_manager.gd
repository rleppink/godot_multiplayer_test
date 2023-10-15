extends Node

signal state_changed(new_state: State)
signal player_joined(player_id: int, player_config: Dictionary)

enum State { Uninitialized, CreatingHost, Hosting, Connecting, Clienting }

var state := State.Uninitialized :
	set(value):
		state = value
		state_changed.emit(value)

var peers := {}

var my_peer_config := {}


func _ready() -> void:
	# Server events
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Client events
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_hosting(port: int, peer_config: Dictionary) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	state = State.CreatingHost
	if error:
		push_error("Could not host server")
		return FAILED

	multiplayer.multiplayer_peer = peer
	my_peer_config = peer_config
	state = State.Hosting
	return OK

func start_clienting(ip: String, port: int, peer_config: Dictionary) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	state = State.Connecting
	if error:
		push_error("Could not create client")
		return FAILED

	multiplayer.multiplayer_peer = peer
	my_peer_config = peer_config
	return OK

func stop_multiplayering():
	multiplayer.multiplayer_peer = null
	state = State.Uninitialized
	peers = {}
	
func is_multiplayering():
	return state != State.Uninitialized

func get_all_peer_ids():
	return [multiplayer.get_unique_id()] + peers.keys()

func get_peer_config(peer_id: int) -> Dictionary:
	if multiplayer.get_unique_id() == peer_id:
		return my_peer_config

	if peers.has(peer_id):
		return peers[peer_id]

	push_error("Could not find peer config for given peer id")
	return {}

func load_scene(scene_path):
	_load_scene.rpc(scene_path)

@rpc("authority", "call_local", "reliable")
func _load_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)

func send_my_peer_config(peer_id):
	_send_my_peer_confg.rpc_id(peer_id, my_peer_config)

@rpc("any_peer", "reliable")
func _send_my_peer_confg(remote_peer_config):
	peers[multiplayer.get_remote_sender_id()] = remote_peer_config
	player_joined.emit(multiplayer.get_remote_sender_id(), remote_peer_config)
	
func _on_peer_connected(id):
	send_my_peer_config(id)

func _on_peer_disconnected(id):
	if peers.has(id):
		peers.erase(id)

func _on_connected_to_server():
	state = State.Clienting

func _on_connection_failed():
	stop_multiplayering()

func _on_server_disconnected():
	stop_multiplayering()

func _print_mp(val):
	if !multiplayer.multiplayer_peer:
		print("[NC] " + val)
		return
	
	var id = multiplayer.multiplayer_peer.get_unique_id()
	if id:
		print("[" + str(id) + "] " + val)
	else:
		print(val)
