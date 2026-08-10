extends Node

@export var sfx_bus: String = "SFX"
@export var music_bus: String = "Music"

var sfx_players: Array[AudioStreamPlayer] = []
var current_music: AudioStreamPlayer

const SFX_POOL_SIZE := 8

func _ready() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = sfx_bus
		add_child(player)
		sfx_players.append(player)

	current_music = AudioStreamPlayer.new()
	current_music.bus = music_bus
	add_child(current_music)

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	# all busy, steal the first one
	sfx_players[0].stream = stream
	sfx_players[0].play()

func play_music(stream: AudioStream, fade_time: float = 0.5) -> void:
	if current_music.stream == stream and current_music.playing:
		return
	current_music.stream = stream
	current_music.play()

func stop_music() -> void:
	current_music.stop()
