extends Node

signal state_changed(new_state: State)

enum State { Uninitialized, CreatingHost, Hosting, Connecting, Clienting }

var state := State.Uninitialized :
	set(value):
		state = value
		state_changed.emit(value)

var peers = {}


func _ready() -> void:
	# Server events
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	# Client events
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_hosting(port, player_name) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port)
	state = State.CreatingHost
	if error:
		push_error("Could not host server")
		return FAILED

	multiplayer.multiplayer_peer = peer
	peers[multiplayer.get_unique_id()] = { "name": player_name }
	state = State.Hosting
	return OK

func start_clienting(ip, port, player_name) -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	state = State.Connecting
	if error:
		push_error("Could not create client")
		return FAILED

	multiplayer.multiplayer_peer = peer
	peers[multiplayer.get_unique_id()] = { "name": player_name }
	return OK

func stop_multiplayering():
	multiplayer.multiplayer_peer = null
	state = State.Uninitialized
	peers = {}
	
func is_multiplayering():
	return state != State.Uninitialized

func get_state():
	return state
	
func get_peers():
	return peers

func load_scene(scene_path):
	_load_scene.rpc(scene_path)

@rpc("authority", "call_local", "reliable")
func _load_scene(scene_path):
	get_tree().change_scene_to_file(scene_path)
	
func _on_peer_connected(id):
	_print_mp("Peer connected: " + str(id))
	peers[id] = {}
	
	_print_mp(str(peers))

func _on_peer_disconnected(id):
	_print_mp("Peer disconnected: " + str(id))
	if peers.has(id):
		peers.erase(id)

func _on_connected_to_server():
	_print_mp("Connected to server")
	state = State.Clienting

func _on_connection_failed():
	_print_mp("Failed to connect")
	stop_multiplayering()

func _on_server_disconnected():
	_print_mp("Server disconnected")
	stop_multiplayering()

func _print_mp(val):
	if !multiplayer.multiplayer_peer:
		print(val)
		return
	
	var id = multiplayer.multiplayer_peer.get_unique_id()
	if id:
		print("[" + str(id) + "] " + val)
	else:
		print(val)

func _print_state():
	_print_mp(str(state))
	await get_tree().create_timer(1).timeout
	_print_state()
