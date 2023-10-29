extends Node2D


var target_position: Vector2


func _ready():
	print("Ready. Current pos: " + str(position) + ", target pos: " + str(target_position))
	var property_tweener := \
			create_tween() \
				.tween_property(self, "position", target_position, 0.5) \
				.set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_CIRC)

	property_tweener.connect("finished", _tween_finished)


func _tween_finished():
	queue_free()
