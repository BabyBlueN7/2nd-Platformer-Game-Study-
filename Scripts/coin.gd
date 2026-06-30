extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		# Play sound through AudioManager (for consistency)
		AudioManager.play_coin()
		
		# The AnimationPlayer will automatically play PickupSound 
		# at the right frame when the animation plays
		# No need to call it manually!
		
		queue_free()
