extends StaticBody3D

@export var floor_size: Vector3 = Vector3(10.0, 1.0, 4.0)
@export var texture_tile_scale: float = 1.0

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	update_floor()

func update_floor() -> void:
	# --- Collision ---
	var box_shape := BoxShape3D.new()
	box_shape.size = floor_size
	collision_shape.shape = box_shape

	# --- Mesh ---
	var box_mesh := BoxMesh.new()
	box_mesh.size = floor_size
	mesh_instance.mesh = box_mesh

	# --- Material tiling ---
	var material := mesh_instance.material_override as StandardMaterial3D
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance.material_override = material

	# Tile texture based on floor size
	# X maps across width, Z maps across depth for a top face in 3D
	material.uv1_scale = Vector3(
		floor_size.x * texture_tile_scale,
		floor_size.z * texture_tile_scale,
		1.0
	)
