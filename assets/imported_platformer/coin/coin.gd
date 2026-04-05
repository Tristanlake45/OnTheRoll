extends Area3D

var taken = false

func _on_body_entered(body: Node3D) -> void:
	if taken:
		return

	if body.name == "CharacterBody3D2":
		taken = true
		print("Coin collected")

		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("take")

		if body.has_method("collect_coin"):
			body.collect_coin()

		await get_tree().create_timer(0.2).timeout
		queue_free()
