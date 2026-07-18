extends Node

# This variable will survive scene changes!
var score: int = 0
var deaths: int = 0 

func reset_score():
	score = 0
	deaths = 0 

func add_death():
	deaths += 1

# --- WINDOW TOGGLE LOGIC ---
func _unhandled_input(event: InputEvent) -> void:
	# 'ui_cancel' is the default Godot action for the Esc key
	if event.is_action_pressed("ui_cancel"):
		toggle_window_mode()

func toggle_window_mode():
	var current_mode = DisplayServer.window_get_mode()
	
	# If it's currently windowed, switch to fullscreen
	if current_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		print("Switched to Fullscreen")
	else:
		# Otherwise, switch back to windowed
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		print("Switched to Windowed")
