extends Control

class_name HUD

@onready var health_bar = $HealthBar
@onready var coin_label = $CoinLabel

func _ready():
	if Engine.is_editor_hint():
		visible = false
	else:
		visible = true
	
	update_health_display(3)
	update_coin_display()

func update_health_display(current_health: int):
	if health_bar:
		if current_health >= 3:
			health_bar.frame = 0
		elif current_health == 2:
			health_bar.frame = 1
		elif current_health == 1:
			health_bar.frame = 2
		else:
			health_bar.frame = 3

func update_coin_display():
	var game_manager = get_node_or_null("/root/Game/GameManager")
	if game_manager and coin_label:
		coin_label.text = "%03d" % game_manager.score
