extends Area3D

@export_file("*.tscn") var next_level_scene: String = ""

@onready var leaves = $Tree/Leaves

var triggered = false

func _on_body_entered(body: Node3D) -> void:
	if triggered:
		return

	if body.is_in_group("player"):
		triggered = true

		# 🔊 Tell player to play LevelComplete sound
		if body.has_method("play_level_complete_sound"):
			body.play_level_complete_sound()

		play_leaves_animation()

		await get_tree().create_timer(0.8).timeout

		if next_level_scene != "":
			get_tree().change_scene_to_file(next_level_scene)
		else:
			get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func play_leaves_animation() -> void:
	var tween = create_tween()

	var start_pos = leaves.position
	var end_pos = start_pos + Vector3(0, -1.5, 0)

	tween.tween_property(leaves, "position", end_pos, 0.6) \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
