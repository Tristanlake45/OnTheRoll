extends CharacterBody3D

const SPEED = 2.0
const FLOOR_RAY_FORWARD = 0.7
const FLOOR_RAY_DOWN = -1.5

var direction = 1
var can_turn = true

@onready var ray_floor: RayCast3D = $RayFloor
@onready var visuals: Node3D = $Enemy

func _ready() -> void:
	update_facing()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = SPEED * direction
	velocity.z = 0

	move_and_slide()
	global_position.z = 0

	if not ray_floor.is_colliding():
		turn_around()

func turn_around() -> void:
	if not can_turn:
		return

	can_turn = false
	direction *= -1
	update_facing()

	await get_tree().create_timer(0.2).timeout
	can_turn = true

func update_facing() -> void:
	# Keep the ray on the enemy, but point it ahead/down based on direction
	ray_floor.target_position = Vector3(FLOOR_RAY_FORWARD * direction, FLOOR_RAY_DOWN, 0)

	# Flip the visual model
	if direction > 0:
		visuals.rotation.y = PI
	else:
		visuals.rotation.y = 0

func die() -> void:
	queue_free()

func _on_hurt_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.take_damage(global_position.x)

func _on_squash_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.velocity.y <= 0:
		body.bounce_after_squash()
		die()
