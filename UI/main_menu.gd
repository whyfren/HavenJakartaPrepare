extends Control

func _ready():
	show()

func _on_start_pressed():
	Audiomanager.play_sfx("click")
	get_tree().change_scene_to_file(
        "res://main.tscn"
	)

func _on_settings_pressed():
	Audiomanager.play_sfx("click")
	show()

func _on_exits_pressed():
	Audiomanager.play_sfx("click")
	get_tree().quit()   
