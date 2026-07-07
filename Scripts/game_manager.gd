extends Node

@onready var score_label: Label = $ScoreLabel

# Music control (from theme.gd)
@export var area_music: AudioStream

var score = 0

func _ready():
	# Play background music for this area
	if area_music:
		AudioManager.play_bgm(area_music)
	
	# Update HUD display
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_coin_display"):
		hud.update_coin_display()

func add_point():
	score += 1
	
	# Update the GameManager's label (for end screen/message)
	if score_label:
		score_label.text = "You Collected " + str(score) + " Coins."
	
	# Find and update HUD anywhere in scene tree
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("update_coin_display"):
		hud.update_coin_display()

# Scene transition function (for future use)
func load_next_area(next_area_path: String):
	get_tree().change_scene_to_file(next_area_path)
