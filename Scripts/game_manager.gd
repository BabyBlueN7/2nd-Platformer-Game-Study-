extends Node

@onready var score_label: Label = $ScoreLabel

var score = 0

func add_point():
	score += 1
	# Update the GameManager's label (for end screen/message)
	score_label.text = "You Collected " + str(score) + " Coins."
	
	# Also update the HUD counter
	var hud = get_node_or_null("/root/Game/CanvasLayer/HUD")
	if hud and hud.has_method("update_coin_display"):
		hud.update_coin_display()
