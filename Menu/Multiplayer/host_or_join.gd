extends Control


func _ready():
	var config_player_name = ConfigManager.get_value("player_name")
	if config_player_name:
		%NameLineEdit.text = config_player_name
		# TODO: Incorrect: this should check sanitized name, but cbf right now
		_on_sanitized_name_changed(config_player_name)

	var config_player_color = ConfigManager.get_value("player_color")
	if config_player_color:
		print("setting color: " + str(config_player_color))
		%ColorPickerButton.color = config_player_color


func _on_sanitized_name_changed(sanitized_name: String):
	var regex := RegEx.new()
	regex.compile("^\\s+$")
	var valid_name :=  \
		sanitized_name != null \
		&& sanitized_name != "" \
		&& regex.search(sanitized_name) == null

	if valid_name:
		ConfigManager.set_value("player_name", sanitized_name)
		%HostButton.disabled = false
		%JoinButton.disabled = false
	else:
		%HostButton.disabled = true
		%JoinButton.disabled = true


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Menu/Main/main.tscn")


func _on_join_button_pressed():
	get_tree().change_scene_to_file("res://Menu/Multiplayer/Join/join_game.tscn")


func _on_host_button_pressed():
	get_tree().change_scene_to_file("res://Menu/Multiplayer/Host/host_game.tscn")


func _on_color_picker_button_color_changed(color:Color):
	ConfigManager.set_value("player_color", %ColorPickerButton.color)
