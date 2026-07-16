extends Node2D

@onready var coins_label = $CoinsLabel
@onready var deaths_label = $DeathsLabel

func _ready():
	# Display the final stats
	coins_label.text = "Total Coins Collected: %d" % Global.score
	deaths_label.text = "Number of Times Died: %d" % Global.deaths

func _on_restart_button_pressed():
	# Reset game and go back to tutorial
	Global.reset_score()
	get_tree().change_scene_to_file("res://Scenes/Areas/tutorial.tscn")
