extends Node2D


var target_position: Vector2 = Vector2(0, 0)
var tween_finished: Callable = func(): push_error("Tween finished not initialized!")

var thrower_id: int


func _ready():
	var throw_distance := position.distance_to(target_position)
	var throw_time := throw_distance / 1000
	var throw_offset := throw_distance / 15

	var offset_tween := create_tween()
	offset_tween.tween_property($Block, "offset", Vector2(0, -throw_offset), throw_time * 0.2) \
			.as_relative() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_EXPO)

	offset_tween.tween_property($Block, "offset", Vector2(0, throw_offset), throw_time * 0.8) \
			.as_relative() \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_EXPO)

	var position_tweener := \
			create_tween().tween_property(self, "position", target_position, throw_time) \
				.set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_EXPO)

	position_tweener.connect("finished", _tween_finished)


func _tween_finished():
	$AudioStreamPlayer2D.volume_db = randf_range(-7, 7)
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.5, 1.5)
	$AudioStreamPlayer2D.play()

	impact_players()

	tween_finished.call()

	$Shadow.visible = false
	$Block.visible = false

	await $AudioStreamPlayer2D.finished

	queue_free()


func impact_players() -> void:
	if not multiplayer.is_server():
		return

	for overlapping_body in $ImpactArea.get_overlapping_bodies() :
		if not overlapping_body is Player:
			continue

		if overlapping_body.player_id == thrower_id:
			continue

		overlapping_body.impact()
