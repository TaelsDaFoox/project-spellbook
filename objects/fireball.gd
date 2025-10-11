extends StaticBody3D
var move_dir:=Vector3.ZERO
@export var move_speed: float

func _physics_process(delta: float) -> void:
	position+=move_dir*delta*move_speed

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name.contains("IceBlock"):
		body.queue_free()
	queue_free()
