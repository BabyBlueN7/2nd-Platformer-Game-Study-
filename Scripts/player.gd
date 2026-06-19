extends CharacterBody2D


const SPEED = 120.0
const JUMP_VELOCITY = -300.0

@export var jump_buffer_time: float = 0.1
@export var coyote_time: float = 0.1

var jump_buffer_timer: float = 0.0
var coyote_timer: float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("JUMP"):
		jump_buffer_timer = jump_buffer_time

func _physics_process(delta: float) -> void:
	# Add the gravity.
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


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("LEFT", "RIGHT")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
