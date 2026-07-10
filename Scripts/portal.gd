extends Area2D

@export var next_scene: PackedScene

@onready var portal_ambient = $PortalAmbient

func _ready():
	body_entered.connect(_on_body_entered)
	
	# Start the looping ambient sound immediately
	if portal_ambient:
		portal_ambient.play()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		if next_scene:
			# Optional: Play a one-time "enter" sound here
			monitoring = false
			await get_tree().create_timer(0.3).timeout
			get_tree().change_scene_to_packed(next_scene)
