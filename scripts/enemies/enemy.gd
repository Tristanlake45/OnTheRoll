extends CharacterBody3D

const SPEED = 2.0
const FLOOR_RAY_FORWARD = 0.7
const FLOOR_RAY_DOWN = -1.5

const STOMP_DELAY = 0.08
const EXPLOSION_LIFETIME = 0.35

var direction = 1
var can_turn = true
var is_dying = false

@onready var ray_floor: RayCast3D = $RayFloor
@onready var visuals: Node3D = $Enemy
@onready var sound_hit: AudioStreamPlayer3D = $SoundHit
@onready var sound_explode: AudioStreamPlayer3D = $SoundExplode
@onready var explosion: CPUParticles3D = $Explosion

func _ready() -> void:
	update_facing()

	# Make sure explosion is off at start
	if explosion:
		explosion.emitting = false

func _physics_process(delta: float) -> void:
	if is_dying:
		velocity = Vector3.ZERO
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = SPEED * direction
	velocity.z = 0

	move_and_slide()
	global_position.z = 0

	if not ray_floor.is_colliding():
		turn_around()

func turn_around() -> void:
	if not can_turn or is_dying:
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
	if is_dying:
		return

	is_dying = true
	can_turn = false
	velocity = Vector3.ZERO

	# Stop normal visuals/movement
	if visuals:
		visuals.visible = false

	# Play explode sound and particles after tiny delay
	if sound_explode:
		sound_explode.play()

	if explosion:
		explosion.emitting = true

	await get_tree().create_timer(EXPLOSION_LIFETIME).timeout
	queue_free()

func _on_hurt_zone_body_entered(body: Node3D) -> void:
	if is_dying:
		return

	if body.is_in_group("player"):
		body.take_damage(global_position.x)

func _on_squash_zone_body_entered(body: Node3D) -> void:
	if is_dying:
		return

	if body.is_in_group("player") and body.velocity.y <= 0:
		body.bounce_after_squash()

		if sound_hit:
			sound_hit.play()

		await get_tree().create_timer(STOMP_DELAY).timeout
		die()
