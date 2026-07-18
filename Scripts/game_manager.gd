extends Node

@onready var score_label: Label = $ScoreLabel

# Music control
@export var area_music: AudioStream

# --- ADDED: Track coins for this specific life ---
var coins_collected_this_run: int = 0 

func _ready():
	# Play background music for this area
	if area_music:
		AudioManager.play_bgm(area_music)
	
	# Update HUD display
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_coin_display"):
		hud.update_coin_display()
	
	if score_label:
		score_label.text = "You Collected " + str(Global.score) + " Coins."

func _exit_tree():
	if AudioManager:
		AudioManager.stop_walk()

func add_point():
	# Add to the GLOBAL score
	Global.score += 1
	
	# --- ADDED: Track it for this run ---
	coins_collected_this_run += 1 
	
	# ONLY update score_label if it exists
	if score_label:
		score_label.text = "You Collected " + str(Global.score) + " Coins."
	
	# Find and update HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_coin_display"):
		hud.update_coin_display()

# --- ADDED: Let the player read this number safely ---
func get_coins_collected_this_run() -> int:
	return coins_collected_this_run

func load_next_area(next_area_path: String):
	get_tree().change_scene_to_file(next_area_path)
