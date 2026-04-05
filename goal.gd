extends Area3D

@onready var leaves = $Tree/Leaves   # adjust this path if needed

var triggered = false

func _on_body_entered(body: Node3D) -> void:
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true

		play_leaves_animation()

		# wait for the animation to be seen
		await get_tree().create_timer(0.8).timeout

		# reset current level
		get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)


func play_leaves_animation() -> void:
	var tween = create_tween()

	var start_pos = leaves.position
	var end_pos = start_pos + Vector3(0, -1.5, 0)

	tween.tween_property(leaves, "position", end_pos, 0.6)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)
