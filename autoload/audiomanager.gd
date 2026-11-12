extends Node

var sounds = {
	"fireball": preload("res://asset/sound/floraphonic-fireball-whoosh-1-179125.mp3"),
	"blast": preload("res://asset/sound/yodguard-fire-magic-6-378641.mp3")
}

func play_sfx(sound_name: String):
	if not sounds.has(sound_name):
		push_warning("Sound tidak ditemukan: " + sound_name)
		return

	var player = AudioStreamPlayer.new()
	player.stream = sounds[sound_name]

	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
