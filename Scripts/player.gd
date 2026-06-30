extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1
@export var invincibility_duration: float = 1.5

# --- NEW DASH VARIABLES (Visible in Inspector!) ---
@export var dash_speed: float = 350.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5 # Prevents spamming the dash

@onready var animated_sprite = $AnimatedSprite2D
@onready var hud = $"/root/Game/CanvasLayer/HUD" # Updated path based on your scene

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

# --- HEALTH VARIABLES ---
var max_health: int = 3
var current_health: int = 3
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var is_dead: bool = false 

# --- DASH VARIABLES ---
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: float = 0.0

func _ready():
	if hud:
		hud.update_health_display(current_health)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

func _physics_process(delta: float) -> void:
	# 1. Handle Death Physics (Gravity still applies so they fall)
	if is_dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# 2. Handle Dash Cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# 3. Trigger Dash (Works in Air and Ground!)
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()

	# 4. Handle Active Dash
	if is_dashing:
		dash_timer -= delta
		# Lock horizontal velocity to dash speed
		velocity.x = dash_direction * dash_speed
		
		# End dash when timer runs out
		if dash_timer <= 0:
			is_dashing = false
			# Slow down slightly after dash ends for better game feel
			velocity.x = move_toward(velocity.x, 0, SPEED) 
	else:
		# --- NORMAL MOVEMENT LOGIC (Only runs if NOT dashing) ---
		
		# Handle Invincibility Timer
		if is_invincible:
			invincibility_timer -= delta
			if invincibility_timer <= 0:
				is_invincible = false

		# Add gravity
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Update timers
		if jump_buffer_timer > 0.0: jump_buffer_timer -= delta
		if coyote_timer > 0.0: coyote_timer -= delta
		if is_on_floor(): coyote_timer = coyote_time

		# Handle jump with buffer and coyote
		if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			coyote_timer = 0.0

		# Get input direction
		var direction := Input.get_axis("left", "right")
		
		# Flip sprite
		if direction > 0: animated_sprite.flip_h = false
		elif direction < 0: animated_sprite.flip_h = true
		
		# Animation logic with flashing
		if is_invincible:
			var flash_speed = 0.1
			if fmod(invincibility_timer, flash_speed * 2) > flash_speed:
				animated_sprite.visible = true
			else:
				animated_sprite.visible = false
		else:
			animated_sprite.visible = true
			if is_on_floor():
				if direction == 0: animated_sprite.play("ideal")
				else: animated_sprite.play("run")
			else:
				animated_sprite.play("jump")

		# Apply normal movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Apply physics
	move_and_slide()

func start_dash():
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	var dir = Input.get_axis("left", "right")
	if dir == 0:
		dir = -1 if animated_sprite.flip_h else 1
	
	dash_direction = dir
	animated_sprite.flip_h = dir < 0 
	
	is_invincible = true
	invincibility_timer = dash_duration + 0.1 
	
	# --- THE SMOOTH ANIMATION FIX ---
	# Calculate the exact FPS needed so 8 frames finish perfectly with the dash duration
	var total_frames = 8
	var required_fps = total_frames / dash_duration
	
	# Set the animation speed dynamically
	animated_sprite.sprite_frames.set_animation_speed("roll", required_fps)
	
	# Play the animation (Godot will handle the smooth frame transitions now!)
	animated_sprite.play("roll") 

func take_damage(amount: int):
	if is_invincible or current_health <= 0 or is_dead:
		return
		
	current_health -= amount
	is_invincible = true
	invincibility_timer = invincibility_duration
	
	animated_sprite.play("hit")
	
	if hud:
		hud.update_health_display(current_health)
	
	if current_health <= 0:
		die()

func die():
	is_dead = true
	set_process_input(false)
	
	animated_sprite.play("death")
	animated_sprite.visible = true
	
	velocity = Vector2.ZERO
	velocity.y = -150  # Small upward pop

	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
