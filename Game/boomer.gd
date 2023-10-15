extends Node2D


var line := Line2D.new()

func _ready():
	add_child(line)


func _process(_delta):
	var center := get_viewport_rect().size / 2
	var mouse_position := get_global_mouse_position()

	line.clear_points()
	line.add_point(center)
	line.add_point(mouse_position)
