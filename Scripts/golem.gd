extends CharacterBody2D

class_name Golem

@export var walk_speed: float = 40.0
@export var attack_range: float = 80.0
@export var max_health: int = 10
@export var bash_dash_health: int = 6

var current_health: int
var hit_count: int = 0
var direction: int = 1
var is_attacking: bool = false
var player_in_range: bool = false
var can_turn: bool = true

enum State { WALK, ATTACK, HIT, DEAD }
var current_state: State = State.WALK

@onready var animated_sprite = $AnimatedSprite2D
@onready var death_zone = $DeathZone2
@onready var detection_zone = $DetectionZone
@onready var edge_ray = $EdgeRay
@onready var body_collision = $CollisionShape2D

func _ready():
	current_health = max_health
	animated_sprite.play("walk")
	death_zone.monitoring = false
	
	if detection_zone:
		detection_zone.body_entered.connect(_on_detection_body_entered)
		detection_zone.body_exited.connect(_on_detection_body_exited)

func _physics_process(delta):
	if current_state == State.DEAD:
		velocity += get_gravity() * delta
		move_and_slide()
		return

	update_edge_ray()
	
	match current_state:
		State.WALK:
			handle_walk()
		State.ATTACK:
			velocity.x = 0
		State.HIT:
			velocity.x = 0

	if current_state != State.ATTACK and current_state != State.HIT:
		velocity += get_gravity() * delta
		
	move_and_slide()

func update_edge_ray():
	var front_x = 30 * direction
	edge_ray.position = Vector2(front_x, 0)
	edge_ray.target_position = Vector2(0, 50)

func handle_walk():
	if player_in_range:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.distance_to(global_position) <= attack_range:
			start_attack()
			return
	
	if can_turn and not edge_ray.is_colliding():
		direction *= -1
		animated_sprite.flip_h = (direction == -1)
		can_turn = false
		await get_tree().create_timer(0.5).timeout
		can_turn = true

	velocity.x = direction * walk_speed
	
	if animated_sprite.animation != "walk":
		animated_sprite.play("walk")

func _on_detection_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = true
		if body.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
		animated_sprite.flip_h = (direction == -1)

func _on_detection_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = false

func start_attack():
	if is_attacking or current_state == State.DEAD:
		return
	
	is_attacking = true
	current_state = State.ATTACK
	animated_sprite.play("attack")
	
	# Activate hitbox at frame 5
	await _wait_for_animation_frame(5)
	death_zone.monitoring = true
	death_zone.monitorable = true
	trigger_screen_shake()
	
	# Deactivate after frame 9
	await _wait_for_animation_frame(10)
	death_zone.monitoring = false
	death_zone.monitorable = false
	
	await animated_sprite.animation_finished
	
	is_attacking = false
	current_state = State.WALK
	animated_sprite.play("walk")

func _wait_for_animation_frame(target_frame: int):
	# Wait until animation reaches target frame
	while animated_sprite.frame < target_frame and animated_sprite.is_playing():
		await get_tree().process_frame

func trigger_screen_shake():
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("start_shake"):
		camera.start_shake(0.3, 8)

# --- DAMAGE FUNCTION (Called by death_zone2.gd) ---
func take_dash_damage(is_bash_dash: bool = false):
	if current_state == State.DEAD or current_state == State.HIT:
		return
	
	hit_count += 1
	print("🗿 GOLEM HIT! Count: ", hit_count, " / ", (bash_dash_health if is_bash_dash else max_health))
	
	# Play hit sound
	if AudioManager and AudioManager.has_method("play_hit"):
		AudioManager.play_hit()
	
	current_state = State.HIT
	animated_sprite.play("hit")
	
	var threshold = bash_dash_health if is_bash_dash else max_health
	
	if hit_count >= threshold:
		die()
	else:
		await animated_sprite.animation_finished
		if current_state == State.HIT:
			current_state = State.WALK
			animated_sprite.play("walk")

func die():
	current_state = State.DEAD
	animated_sprite.play("died")
	death_zone.monitoring = false
	if body_collision:
		body_collision.set_deferred("disabled", true)
	
	if AudioManager and AudioManager.has_method("play_death"):
		AudioManager.play_death()
	
	await animated_sprite.animation_finished
	queue_free()
