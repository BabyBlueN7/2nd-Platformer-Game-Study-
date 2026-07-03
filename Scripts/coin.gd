extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		AudioManager.play_coin()
		
		var game_manager = get_node("/root/Game/GameManager")
		if game_manager:
			game_manager.add_point()
		
		queue_free()
