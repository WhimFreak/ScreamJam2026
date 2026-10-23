extends Node
## Autoload that plays background music and crossfades between tracks.
## Usage from anywhere:  MusicPlayer.play(my_stream, 1.5)  /  MusicPlayer.stop(2.0)

const SILENT_DB := -80.0

## Volume of the music when fully faded in.
@export var volume_db: float = 0.0

var current_stream: AudioStream

var _players: Array[AudioStreamPlayer] = []
var _tweens: Array[Tween] = [null, null]
var _active := 0 # index of the player that holds the current track


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # keep playing while the game is paused
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = &"Music" # so the Music slider in the options menu controls it
		player.volume_db = SILENT_DB
		add_child(player)
		_players.append(player)


## Crossfades to `stream`. Does nothing if it is already playing.
## Passing null fades the music out.
func play(stream: AudioStream, fade_time: float = 1.0, loop: bool = true) -> void:
	if stream == null:
		stop(fade_time)
		return
	if stream == current_stream and _players[_active].playing:
		return

	current_stream = stream
	if loop:
		_enable_loop(stream)

	_fade_out(_active, fade_time)
	_active = 1 - _active
	_fade_in(_active, stream, fade_time)


## Fades the current music out and stops it.
func stop(fade_time: float = 1.0) -> void:
	current_stream = null
	_fade_out(_active, fade_time)


func _fade_in(index: int, stream: AudioStream, fade_time: float) -> void:
	var player := _players[index]
	_kill_tween(index)
	player.stream = stream
	player.volume_db = SILENT_DB if fade_time > 0.0 else volume_db
	player.play()
	if fade_time > 0.0:
		_tweens[index] = create_tween()
		_tweens[index].tween_property(player, "volume_db", volume_db, fade_time)


func _fade_out(index: int, fade_time: float) -> void:
	var player := _players[index]
	if not player.playing:
		return
	_kill_tween(index)
	if fade_time <= 0.0:
		player.stop()
		return
	_tweens[index] = create_tween()
	_tweens[index].tween_property(player, "volume_db", SILENT_DB, fade_time)
	_tweens[index].tween_callback(player.stop)


func _kill_tween(index: int) -> void:
	if _tweens[index] and _tweens[index].is_valid():
		_tweens[index].kill()


func _enable_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
