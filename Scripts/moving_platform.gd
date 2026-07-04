extends Path2D

class_name MovingPlatform

@export var path_time: float = 1.0
@export var ease: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var looping: bool = false

var path_follow_2D: PathFollow2D

func _ready():
	# Find PathFollow2D automatically
	path_follow_2D = $PathFollow2D
	move_tween()

func move_tween():
	if path_follow_2D == null:
		push_error("MovingPlatform: PathFollow2D not assigned!")
		return
		
	var tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(path_follow_2D, "progress_ratio", 1.0, path_time).set_ease(ease).set_trans(transition)
	
	if !looping:
		tween.tween_property(path_follow_2D, "progress_ratio", 0.0, path_time).set_ease(ease).set_trans(transition)
	else: 
		tween.tween_property(path_follow_2D, "progress_ratio", 0.0, 0.0).set_ease(ease).set_trans(transition)
