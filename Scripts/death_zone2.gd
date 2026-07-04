extends Area2D

# This value appears in the Inspector for each DeathZone2 instance!
# Default is 1, but you can change it per-enemy in the editor.
@export var damage: int = 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Check if player is dashing
		if body.is_dashing:
			# Player is dashing - damage the slime instead!
			var slime = get_parent()  # Get the slime node (parent of DeathZone2)
			if slime.has_method("take_dash_damage"):
				slime.take_dash_damage()
		else:
			# Player is NOT dashing - hurt the player
			if body.has_method("take_damage"):
				body.take_damage(damage)  # Use the exported damage value!
