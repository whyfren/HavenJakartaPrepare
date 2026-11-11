extends Control

func _ready():
	hide()

func _on_continue_pressed():
	get_tree().paused = false
	hide()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(
        "res://UI/Menu.tscn"
	)
