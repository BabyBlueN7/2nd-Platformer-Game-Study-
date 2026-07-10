extends Camera2D

var is_shaking: bool = false
var shake_timer: float = 0.0
var shake_intensity: float = 0.0

func _ready():
	# Automatically add to the "camera" group so the Golem can find it
	add_to_group("camera")

func _process(delta):
	if is_shaking:
		shake_timer -= delta
		if shake_timer <= 0:
			stop_shake()
		else:
			# Apply random offset based on intensity
			offset = Vector2(
				randf_range(-shake_intensity, shake_intensity),
				randf_range(-shake_intensity, shake_intensity)
			)
	else:
		# Smoothly return to center when not shaking
		if offset != Vector2.ZERO:
			offset = offset.move_toward(Vector2.ZERO, 10.0 * delta)

func start_shake(duration: float, intensity: float):
	is_shaking = true
	shake_timer = duration
	shake_intensity = intensity

func stop_shake():
	is_shaking = false
	shake_timer = 0.0
	shake_intensity = 0.0
	offset = Vector2.ZERO
