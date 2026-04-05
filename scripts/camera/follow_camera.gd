extends Camera3D

@export var target_path: NodePath
@export var follow_speed: float = 5.0
@export var x_offset: float = 0.0
@export var y_offset: float = 3.0
@export var z_position: float = 12.0

var target: Node3D

func _ready() -> void:
	target = get_node(target_path)

func _process(delta: float) -> void:
	if target == null:
		return

	var desired_position = Vector3(
		target.global_position.x + x_offset,
		target.global_position.y + y_offset,
		z_position
	)

	global_position = global_position.lerp(desired_position, follow_speed * delta)
