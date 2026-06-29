extends Control

class_name HUD

@onready var health_bar = $HealthBar

func update_health_display(current_health: int):
	if health_bar:
		if current_health >= 3:
			health_bar.frame = 0  # Full health
		elif current_health == 2:
			health_bar.frame = 1  # 2 bars
		elif current_health == 1:
			health_bar.frame = 2  # 1 bar
		else:
			health_bar.frame = 3  # No health (death)
