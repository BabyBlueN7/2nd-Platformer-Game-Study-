extends Node2D

const SPEED = 100
var direction = 1
var hit_count: int = 0
var is_dead: bool = false
var is_hit: bool = false
var hit_timer: float = 0.0

@onready var ray_cast_right: RayCast2D = $AnimatedSprite2D/RayCastRight
@onready var ray_cast_left: RayCast2D = $AnimatedSprite2D/RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("ideal")

func _process(delta: float) -> void:
	if is_dead:
		return  # Stop all movement if dead
	
	if is_hit:
		hit_timer -= delta
		if hit_timer <= 0:
			is_hit = false
			animated_sprite.play("ideal")
		return  # Don't move while hit
	
	# Patrol logic
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

# Call this function when player dashes into slime
func take_dash_damage():
	if is_dead or is_hit:
		return
	
	hit_count += 1
	is_hit = true
	hit_timer = 0.3  # Brief pause when hit
	
	# PLAY THE HIT SOUND
	AudioManager.play_hit() # (Make sure this function exists in your AudioManager!)
	
	# Play hit animation
	animated_sprite.play("hit")
	
	# --- CHANGE 1: Now requires 3 hits to die! ---
	if hit_count >= 3:
		die()

func die():
	is_dead = true
	is_hit = false
	animated_sprite.play("died")
	
	# --- CHANGE 2: Disables the original DeathZone instead of DeathZone2 ---
	var death_zone = get_node_or_null("DeathZone") 
	if death_zone:
		death_zone.set_deferred("monitoring", false)
