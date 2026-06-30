extends AnimatedSprite2D

@onready var player = get_parent()

# Track states
var last_health: int = 3
var was_dashing: bool = false
var was_dead: bool = false

func _physics_process(delta: float) -> void:
	# 1. Handle Death Animation
	if player.is_dead:
		if not was_dead:
			play("death")
			visible = true
		was_dead = true
		return
	was_dead = false

	# 2. Handle Dash Animation
	if player.is_dashing:
		if not was_dashing:
			var required_fps = 8.0 / player.dash_duration
			sprite_frames.set_animation_speed("roll", required_fps)
			play("roll")
			flip_h = player.dash_direction < 0 
		was_dashing = true
		return
	else:
		was_dashing = false

	# 3. Handle Hit Animation
	if player.current_health < last_health:
		play("hit")
	last_health = player.current_health

	if animation == "hit" and is_playing():
		handle_flashing()
		handle_flip()
		return

	# 4. Handle Normal Animations (Air vs Ground)
	if not player.is_on_floor():
		play("jump")
	else:
		# Check if ACTUALLY moving (not just pressing button)
		var is_moving = abs(player.velocity.x) > 10.0
		
		if is_moving:
			play("run")  # Running animation
		else:
			play("ideal")  # Idle animation (not frozen!)
	
	# 5. Handle Flashing
	handle_flashing()
	
	# 6. Handle Sprite Flipping
	handle_flip()

func handle_flashing():
	if player.is_invincible:
		var flash_speed = 0.1
		if fmod(player.invincibility_timer, flash_speed * 2) > flash_speed:
			visible = true
		else:
			visible = false
	else:
		visible = true

func handle_flip():
	if not player.is_dashing:
		if player.velocity.x > 0:
			flip_h = false
		elif player.velocity.x < 0:
			flip_h = true
