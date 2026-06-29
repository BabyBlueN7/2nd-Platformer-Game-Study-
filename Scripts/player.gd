extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1
@export var invincibility_duration: float = 1.5  # <-- NEW: Now in Inspector!
@onready var animated_sprite = $AnimatedSprite2D
@onready var hud = $"../HUD"

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

# --- HEALTH VARIABLES ---
var max_health: int = 3
var current_health: int = 3
var is_invincible: bool = false
var invincibility_timer: float = 0.0
var is_dead: bool = false 

func _ready():
	if hud:
		hud.update_health_display(current_health)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("JUMP"):
		jump_buffer_timer = jump_buffer_time

func _physics_process(delta: float) -> void:
	# Exit early if player is dead (no movement or input)
	if is_dead:
		return
	# Handle Invincibility Timer
	if is_invincible:
		invincibility_timer -= delta
		if invincibility_timer <= 0:
			is_invincible = false

	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Update timers
	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta
	if coyote_timer > 0.0:
		coyote_timer -= delta

	# Reset coyote timer when grounded
	if is_on_floor():
		coyote_timer = coyote_time

	# Handle jump with buffer and coyote
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# Get input direction
	var direction := Input.get_axis("LEFT", "RIGHT")
	
	# Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
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
			if direction == 0:
				animated_sprite.play("ideal")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")

	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func take_damage(amount: int):
	if is_invincible or current_health <= 0:
		return
		
	current_health -= amount
	is_invincible = true
	invincibility_timer = invincibility_duration  # Use the @export variable
	
	# Play the hit animation
	animated_sprite.play("hit")
	
	if hud:
		hud.update_health_display(current_health)
	
	if current_health <= 0:
		die()

func die():
	is_dead = true
	# Stop player input
	set_process_input(false)
	
	# Play death animation
	animated_sprite.play("death")
	animated_sprite.visible = true
	
	# Make character pop up and fall (more dramatic!)
	velocity = Vector2.ZERO
	velocity.y = -150  # Small upward pop

	# Wait for death animation, then restart
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
