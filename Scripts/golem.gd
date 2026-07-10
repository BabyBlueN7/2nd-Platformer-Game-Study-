extends CharacterBody2D

class_name Golem

@export var walk_speed: float = 40.0
@export var attack_range: float = 100.0
@export var bash_dash_health: int = 6

var hit_count: int = 0
var direction: int = 1
var is_attacking: bool = false
var player_in_range: bool = false
var can_turn: bool = true
var is_dead: bool = false

enum State { WALK, ATTACK, HIT, DEAD }
var current_state: State = State.WALK

@onready var animated_sprite = $AnimatedSprite2D
@onready var death_zone = $DeathZone2
@onready var detection_zone = $DetectionZone
@onready var edge_ray = $EdgeRay

func _ready():
	animated_sprite.play("walk")
	if death_zone:
		death_zone.monitoring = false
	
	if detection_zone:
		detection_zone.body_entered.connect(_on_detection_body_entered)
		detection_zone.body_exited.connect(_on_detection_body_exited)

func _physics_process(_delta):
	if is_dead:
		velocity = Vector2.ZERO
		set_collision_mask_value(8, false)
		move_and_slide()
		return

	if current_state == State.HIT or current_state == State.ATTACK:
		velocity = Vector2.ZERO
	else:
		velocity.y += get_gravity().y * _delta
		velocity.x = direction * walk_speed

	update_edge_ray()
	
	match current_state:
		State.WALK:
			handle_walk()

	move_and_slide()

func update_edge_ray():
	var front_x = 25 * direction
	edge_ray.position = Vector2(front_x, 0)
	edge_ray.target_position = Vector2(0, 60)

func handle_walk():
	if is_dead or current_state == State.ATTACK:
		return
		
	if player_in_range:
		var player = get_tree().get_first_node_in_group("player")
		if player and player.global_position.distance_to(global_position) <= attack_range:
			start_attack()
			return
	
	if can_turn and not edge_ray.is_colliding():
		direction *= -1
		animated_sprite.flip_h = (direction == -1)
		can_turn = false
		get_tree().create_timer(0.5).timeout.connect(func(): can_turn = true)

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
	if is_attacking or is_dead or current_state == State.DEAD:
		return
	
	is_attacking = true
	current_state = State.ATTACK
	animated_sprite.play("attack")
	
	# 11 FPS: Frame 5 end = 0.55s, Frame 9 start = 0.82s, Finish = 1.0s
	get_tree().create_timer(0.55).timeout.connect(_enable_hitbox)
	get_tree().create_timer(0.82).timeout.connect(_disable_hitbox)
	get_tree().create_timer(1.0).timeout.connect(_finish_attack)

func _enable_hitbox():
	if current_state == State.ATTACK and death_zone and not is_dead:
		death_zone.monitoring = true
		death_zone.monitorable = true
		
		# START SCREEN SHAKE HERE
		start_camera_shake()
		
		# PLAY ATTACK SOUND
		if AudioManager and AudioManager.has_method("play_golem_attack"):
			AudioManager.play_golem_attack()

func _disable_hitbox():
	if death_zone:
		death_zone.monitoring = false
		death_zone.monitorable = false

func _finish_attack():
	if not is_dead:
		is_attacking = false
		current_state = State.WALK
		animated_sprite.play("walk")
		
		# STOP SCREEN SHAKE HERE
		stop_camera_shake()

# --- CAMERA SHAKE FUNCTIONS ---

func start_camera_shake():
	var camera = get_tree().get_first_node_in_group("camera")
	if camera:
		# Start shaking with a long duration (it will be stopped manually)
		if camera.has_method("start_shake"):
			camera.start_shake(999.0, 1.3) # Changed 10.0 to 2.0 for a small shake
		# Fallback if your camera doesn't have start_shake but uses a tween
		elif camera.has_method("shake"):
			camera.shake(0.45, 1.3) # Changed 10.0 to 2.0

func stop_camera_shake():
	var camera = get_tree().get_first_node_in_group("camera")
	if camera:
		if camera.has_method("stop_shake"):
			camera.stop_shake()
		elif camera.has_method("stop"):
			camera.stop()

# --- DAMAGE LOGIC ---

func trigger_screen_shake():
	# Kept for backwards compatibility, but we use the new functions now
	start_camera_shake()

func take_dash_damage(_is_bash_dash: bool = false):
	if is_dead or current_state == State.HIT:
		return
	
	hit_count += 1
	print("GOLEM HIT! Count: ", hit_count, " / ", bash_dash_health)
	
	if AudioManager and AudioManager.has_method("play_hit"):
		AudioManager.play_hit()
	
	current_state = State.HIT
	animated_sprite.play("hit")
	
	if hit_count >= bash_dash_health:
		die()
	else:
		get_tree().create_timer(0.4).timeout.connect(_return_to_walk)

func _return_to_walk():
	if current_state == State.HIT and not is_dead:
		current_state = State.WALK
		animated_sprite.play("walk")

func die():
	is_dead = true
	current_state = State.DEAD
	
	if death_zone:
		death_zone.monitoring = false
		death_zone.monitorable = false
	
	for child in get_children():
		if child is Area2D:
			child.monitoring = false
			child.monitorable = false
	
	set_collision_mask_value(8, false)
	stop_camera_shake() # Ensure shake stops if golem dies mid-attack
	
	if AudioManager and AudioManager.has_method("play_golem_death"):
		AudioManager.play_golem_death()
	
	animated_sprite.play("died")
	
	var frame_count = animated_sprite.sprite_frames.get_frame_count("died")
	var fps = animated_sprite.sprite_frames.get_animation_speed("died")
	var duration = frame_count / fps
	
	await get_tree().create_timer(duration).timeout
	
	animated_sprite.stop()
	animated_sprite.frame = frame_count - 1
	
	set_physics_process(false)
	set_process(false)
