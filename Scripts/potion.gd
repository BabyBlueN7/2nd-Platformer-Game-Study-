extends Area2D

func _ready():
	# Automatically connect the signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the player touched it
	if body.is_in_group("player") or body.name == "Player":
		
		# 1. Unlock the Dash ability!
		if "can_dash" in body:
			body.can_dash = true
			print("Dash ability unlocked!")
		
		# 2. Play a power-up sound
		if AudioManager and AudioManager.has_method("play_power_up"):
			AudioManager.play_power_up()
		
		# 3. Make the potion disappear
		queue_free()
