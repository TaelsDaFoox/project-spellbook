extends CSGCombiner3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free()
