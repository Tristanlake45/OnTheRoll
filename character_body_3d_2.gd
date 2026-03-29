extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 6.5

@onready var anim: AnimatedSprite3D = $AnimatedSprite3D

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Left / right movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Lock depth axis
	velocity.z = 0

	move_and_slide()

	update_animation(direction)


func update_animation(direction: float) -> void:
	# In air → play Idle animation
	if not is_on_floor():
		if anim.animation != "Idle":
			anim.play("Idle")
		anim.speed_scale = -1.0
		return

	# Idle on ground
	if direction == 0:
		if anim.animation != "Idle":
			anim.play("Idle")
		anim.speed_scale = 3.0
		return

	# Rolling on ground
	if anim.animation != "Roll":
		anim.play("Roll")

	# Right = normal roll, left = reverse roll
	if direction > 0:
		anim.speed_scale = 3.0
	else:
		anim.speed_scale = -3.0
