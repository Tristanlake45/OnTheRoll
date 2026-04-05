extends Area3D

func _ready() -> void:
	print("TestCoin ready")
	print("Monitoring:", monitoring)
	print("Monitorable:", monitorable)

func _on_body_entered(body: Node3D) -> void:
	print("TEST COIN HIT:", body.name)
