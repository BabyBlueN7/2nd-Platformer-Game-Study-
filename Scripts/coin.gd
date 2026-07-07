extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		AudioManager.play_coin()
		
		# Find GameManager by GROUP - works in ANY folder!
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.add_point()
		
		queue_free()
