extends Control

func _ready():
	show()

func _on_start_pressed():
	get_tree().change_scene_to_file(
        "res://main.tscn"
	)

func _on_settings_pressed():
	show()

func _on_exits_pressed():
	get_tree().quit()   
