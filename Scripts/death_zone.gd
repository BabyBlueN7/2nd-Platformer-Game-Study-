extends Area2D

@onready var timer = $Timer
#instant kill
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		print("WASTED")
		Engine.time_scale = 0.5
		body.take_damage(3)  # Instant kill
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
