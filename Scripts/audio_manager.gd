extends Node

# --- SFX PLAYERS ---
@onready var sfx_jump = $SFX_Jump
@onready var sfx_hurt = $SFX_Hurt
@onready var sfx_dash = $SFX_Dash
@onready var sfx_coin = $SFX_Coin
@onready var sfx_death = $SFX_Death
@onready var sfx_walk = $SFX_Walk
@onready var sfx_impact = $SFX_Impact 

# --- BGM PLAYER ---
@onready var bgm_player = $BGM_Player

# --- SFX FUNCTIONS ---
# Added 'if' checks so it doesn't crash if a node name is slightly wrong
func play_jump():
	if sfx_jump: sfx_jump.play()

func play_hurt():
	if sfx_hurt: sfx_hurt.play()

func play_dash():
	if sfx_dash: sfx_dash.play()

func play_coin():
	if sfx_coin: sfx_coin.play()

func play_death():
	if sfx_death: sfx_death.play()

func play_walk():
	if sfx_walk:
		sfx_walk.play()

func stop_walk():
	if sfx_walk:
		sfx_walk.stop()

func play_impact():
	if sfx_impact:
		sfx_impact.play()

# --- SMART BGM FUNCTIONS ---

func play_bgm(new_music):
	# 1. If no music is provided, stop playing
	if new_music == null:
		if bgm_player.playing:
			bgm_player.stop()
		return

	# 2. If this exact song is already playing, DO NOTHING!
	if bgm_player.stream == new_music and bgm_player.playing:
		return

	# 3. If it's a NEW song, crossfade to it
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -20, 0.5) # Fade out
	await tween.finished
	
	bgm_player.stream = new_music
	bgm_player.volume_db = -20
	bgm_player.play()
	
	tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", 0, 0.5) # Fade in
