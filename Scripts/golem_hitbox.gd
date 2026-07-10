extends Area2D

func _ready():
	# Automatically connect the signal so it works immediately
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the body is the player
	if body.name == "Player" or body.is_in_group("player"):
		if body.is_dashing:
			var golem = get_parent()
			if golem and golem.has_method("take_dash_damage"):
				# Check for bash dash
				var is_bash = false
				if body.has_method("is_bash_dashing"):
					is_bash = body.is_bash_dashing()
				elif body.get("dash_iframe_active"):
					is_bash = body.dash_iframe_active
				
				golem.take_dash_damage(is_bash)
