extends Control


func _ready():
	var config_ip_value = ConfigManager.get_value("ip_address")
	if config_ip_value:
		%IPAddressLineEdit.text = config_ip_value
		_validate_ip_address(config_ip_value)


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Menu/Multiplayer/host_or_join.tscn")


func _on_ip_address_line_edit_text_changed(new_ip_address: String):
	_validate_ip_address(new_ip_address)


func _validate_ip_address(ip_address: String):
	var ip_address_regex = RegEx.new()
	ip_address_regex.compile("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$")

	var is_valid_ip_address := \
		ip_address != null \
		&& ip_address != "" \
		&& ip_address_regex.search(ip_address) != null

	if is_valid_ip_address:
		ConfigManager.set_value("ip_address", ip_address)
		%JoinButton.disabled = false
	else:
		%JoinButton.disabled = true
