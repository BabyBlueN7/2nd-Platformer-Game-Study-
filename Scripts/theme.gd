extends Node2D

# Drag your background music file here in the Inspector!
@export var area_music: AudioStream

func _ready():
	# Tell the AudioManager to play this level's music
	AudioManager.play_bgm(area_music)
