extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.0
const DOUBLE_JUMP_VELOCITY = 4.8
const MAX_JUMPS = 2
const SQUASH_BOUNCE = 5.5
const FALL_MULTIPLIER = 1.8

const MAX_HEALTH = 3
const DAMAGE_KNOCKBACK_X = 4.0
const DAMAGE_BOUNCE_Y = 4.0
const INVINCIBILITY_TIME = 1.0

const FALL_DEATH_Y = -15.0

@onready var anim: AnimatedSprite3D = $AnimatedSprite3D

var jumps_left = MAX_JUMPS
var health = MAX_HEALTH
var coins = 0
var is_invincible = false
var is_dead = false

var anim_start_position: Vector3
var respawn_position: Vector3

func _ready() -> void:
	add_to_group("player")
	anim_start_position = anim.position
	respawn_position = global_position
	update_health_ui()
	update_coin_ui()

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Save last safe platform position
	if is_on_floor():
		jumps_left = MAX_JUMPS
		respawn_position = global_position

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

		if velocity.y < 0:
			velocity += get_gravity() * (FALL_MULTIPLIER - 1.0) * delta

	# Jump + double jump
	if Input.is_action_just_pressed("ui_accept") and jumps_left > 0:
		if jumps_left == MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = DOUBLE_JUMP_VELOCITY
		jumps_left -= 1

	# Left / right movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Lock to 2D plane
	velocity.z = 0

	move_and_slide()
	global_position.z = 0

	# 🔥 FALL CHECK
	if global_position.y < FALL_DEATH_Y:
		handle_fall()
		return

	update_animation(direction)

func update_animation(direction: float) -> void:
	if is_dead:
		return

	if not is_on_floor():
		if anim.animation != "Idle":
			anim.play("Idle")
		anim.speed_scale = 1.0
		return

	if direction == 0:
		if anim.animation != "Idle":
			anim.play("Idle")
		anim.speed_scale = 1.0
		return

	if anim.animation != "Roll":
		anim.play("Roll")

	if direction > 0:
		anim.speed_scale = 3.0
	else:
		anim.speed_scale = -3.0

func bounce_after_squash() -> void:
	velocity.y = SQUASH_BOUNCE

func collect_coin() -> void:
	coins += 1
	update_coin_ui()

func take_damage(enemy_x: float) -> void:
	if is_invincible or is_dead:
		return

	health -= 1
	update_health_ui()

	print("Player hit! Health:", health)

	if health <= 0:
		die()
		return

	is_invincible = true

	if global_position.x < enemy_x:
		velocity.x = -DAMAGE_KNOCKBACK_X
	else:
		velocity.x = DAMAGE_KNOCKBACK_X

	velocity.y = DAMAGE_BOUNCE_Y
	start_invincibility_timer()

# 🔥 FALL HANDLER (NEW)
func handle_fall() -> void:
	if is_invincible or is_dead:
		return

	health -= 1
	update_health_ui()

	print("Player fell! Health:", health)

	if health <= 0:
		die()
		return

	is_invincible = true

	# Respawn slightly above last platform
	global_position = respawn_position + Vector3(0, 1.0, 0)
	global_position.z = 0

	velocity = Vector3.ZERO
	jumps_left = MAX_JUMPS

	start_invincibility_timer()

func start_invincibility_timer() -> void:
	var timer := get_tree().create_timer(INVINCIBILITY_TIME)
	await timer.timeout
	is_invincible = false

func die() -> void:
	if is_dead:
		return

	is_dead = true
	is_invincible = true
	velocity = Vector3.ZERO

	anim.stop()
	anim.scale = Vector3(1.0, 1.0, 1.0)
	anim.position = anim_start_position

	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(anim, "scale", Vector3(1.45, 0.45, 1.0), 0.12)
	tween.tween_property(anim, "position", anim_start_position + Vector3(0, -0.12, 0), 0.12)

	await tween.finished
	await get_tree().create_timer(0.3).timeout

	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func update_health_ui() -> void:
	var ui = get_node_or_null("/root/Main/CanvasLayer/HealthLabel")
	if ui:
		ui.text = "Hearts: " + str(health)

func update_coin_ui() -> void:
	var ui = get_node_or_null("/root/Main/CanvasLayer/CoinLabel")
	if ui:
		ui.text = "Coins: " + str(coins)
