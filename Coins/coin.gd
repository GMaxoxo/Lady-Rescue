extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		var tween_visibility = get_tree().create_tween()
		tween.tween_property(self, "position", position - Vector2(0, 25), 0.3)
		tween_visibility.tween_property(self, "modulate:a", 0, 0.3)
		tween.tween_callback(queue_free)
		body.gold += 1