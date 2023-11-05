extends Node2D


var target_position: Vector2 = Vector2(0, 0)
var tween_finished: Callable = func(): push_error("Tween finished not initialized!")


func _ready():
	var throw_distance := position.distance_to(target_position)
	var throw_time := throw_distance / 1000
	var throw_offset := throw_distance / 15

	var offset_tween := create_tween()
	offset_tween.tween_property($Sprite2D, "offset", Vector2(0, -throw_offset), throw_time * 0.2) \
			.as_relative() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_QUINT)

	offset_tween.tween_property($Sprite2D, "offset", Vector2(0, throw_offset), throw_time * 0.8) \
			.as_relative() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_QUINT)

	var position_tweener := \
			create_tween().tween_property(self, "position", target_position, throw_time) \
				.set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_QUINT)

	position_tweener.connect("finished", _tween_finished)


func _tween_finished():
	$AudioStreamPlayer2D.volume_db = randf_range(-7, 7)
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.5, 1.5)
	$AudioStreamPlayer2D.play()
	tween_finished.call()
	$Sprite2D.visible = false
	await $AudioStreamPlayer2D.finished
	queue_free()
