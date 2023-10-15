extends Node

const CONFIG_PATH := "user://player_data.cfg"

# One section is fine for now
const SECTION := "player_data"

@onready var config_file := ConfigFile.new()


func _ready():
	config_file.load(CONFIG_PATH)


func set_value(key: String, value: Variant):
	config_file.set_value(SECTION, key, value)
	config_file.save(CONFIG_PATH)


func get_value(key: String) -> Variant:
	return config_file.get_value(SECTION, key)