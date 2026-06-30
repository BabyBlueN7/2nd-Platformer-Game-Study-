extends AnimatedSprite2D

# Get the Player node (which is the parent of this sprite)
@onready var player = get_parent()

# Track states to trigger animations only once
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
		return # Stop all other animations if dead
	was_dead = false

	# 2. Handle Dash Animation
	if player.is_dashing:
		if not was_dashing:
			# Calculate perfect FPS for 8 frames
			var required_fps = 8.0 / player.dash_duration
			sprite_frames.set_animation_speed("roll", required_fps)
			play("roll")
			# Force flip based on dash direction
			flip_h = player.dash_direction < 0 
		was_dashing = true
		return # Don't play other animations while dashing
	else:
		was_dashing = false

	# 3. Handle Hit Animation (Triggered when health drops)
	if player.current_health < last_health:
		play("hit")
	last_health = player.current_health

	# If currently playing the hit animation, let it finish before changing
	if animation == "hit" and is_playing():
		handle_flashing()
		handle_flip()
		return

	# 4. Handle Normal Animations (Air vs Ground)
	if not player.is_on_floor():
		play("jump")
	else:
		var direction = Input.get_axis("left", "right")
		if direction == 0:
			play("ideal")
		else:
			play("run")

	# 5. Handle Flashing (Invincibility)
	handle_flashing()
	
	# 6. Handle Sprite Flipping (Left/Right)
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
	# Only flip if moving normally (not dashing)
	if not player.is_dashing:
		if player.velocity.x > 0:
			flip_h = false
		elif player.velocity.x < 0:
			flip_h = true
