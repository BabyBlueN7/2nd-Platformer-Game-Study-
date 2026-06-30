extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1
@export var invincibility_duration: float = 1.5

# --- DASH VARIABLES ---
@export var dash_speed: float = 350.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.5 

@onready var hud = $"/root/Game/CanvasLayer/HUD" 

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0
var facing_direction: float = 1.0

# --- HEALTH VARIABLES ---
var max_health: int = 3
var current_health: int = 3
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var is_dead: bool = false 

# --- DASH STATE ---
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: float = 0.0

# --- Track previous frame state ---
var was_on_floor: bool = false
var impact_delay_timer: float = 0.5  # <-- NEW: 1-second delay to fix startup glitch

func _ready():
	if hud:
		hud.update_health_display(current_health)
	was_on_floor = is_on_floor()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

func _physics_process(delta: float) -> void:
	# 1. Handle Death Physics
	if is_dead:
		velocity += get_gravity() * delta
		move_and_slide()
		return

	# 2. Handle Dash Cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# 3. Trigger Dash
	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()

	# 4. Handle Active Dash
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * dash_speed
		
		if dash_timer <= 0:
			is_dashing = false
			velocity.x = move_toward(velocity.x, 0, SPEED) 
			AudioManager.stop_walk() # Stop walk sound when dash ends
	else:
		# --- NORMAL MOVEMENT LOGIC ---
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

		# Handle jump
		if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
			velocity.y = JUMP_VELOCITY
			jump_buffer_timer = 0.0
			coyote_timer = 0.0
			AudioManager.play_jump()

		var direction := Input.get_axis("left", "right")
		
		if direction != 0:
			facing_direction = direction

		# Apply horizontal movement
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# --- CRITICAL FIX: Call move_and_slide BEFORE checking is_on_floor() ---
	move_and_slide()

	# 5. Check for landing (Impact Sound) - WITH 1 SECOND DELAY
	if impact_delay_timer > 0.0:
		# Countdown the delay
		impact_delay_timer -= delta
	else:
		# Delay is over, now check for landing normally
		if is_on_floor() and not was_on_floor:
			AudioManager.play_impact()

	# 6. Walk sound logic (Only when actually moving)
	if is_on_floor() and not is_invincible and not is_dashing:
		var direction := Input.get_axis("left", "right")
		var is_moving = abs(velocity.x) > 10.0 and direction != 0
		
		if is_moving:
			if not AudioManager.sfx_walk.playing:
				AudioManager.play_walk()
		else:
			AudioManager.stop_walk()
	else:
		AudioManager.stop_walk()

	# Update previous frame state
	was_on_floor = is_on_floor()

func start_dash():
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	
	var dir = Input.get_axis("left", "right")
	if dir == 0:
		dir = facing_direction
	
	dash_direction = dir
	is_invincible = true
	invincibility_timer = dash_duration + 0.1 
	
	AudioManager.play_dash()

func take_damage(amount: int):
	if is_invincible or current_health <= 0 or is_dead:
		return
		
	current_health -= amount
	is_invincible = true
	invincibility_timer = invincibility_duration
	
	AudioManager.play_hurt()
	
	if hud:
		hud.update_health_display(current_health)
	
	if current_health <= 0:
		die()

func die():
	is_dead = true
	set_process_input(false)
	
	# Play death SFX
	AudioManager.play_death()
	
	velocity = Vector2.ZERO
	velocity.y = -150 

	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
