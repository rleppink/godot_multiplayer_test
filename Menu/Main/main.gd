extends Control


func _on_multiplayer_pressed():
	get_tree().change_scene_to_file("res://Menu/Multiplayer/host_or_join.tscn")

func _on_exit_pressed():
	get_tree().quit()
