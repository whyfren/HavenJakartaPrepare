extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Gamemanager.pause_changed.connect(_on_pause_changed)
	hide()

func _on_pause_changed(paused: bool) -> void:
	visible = paused

func _on_continue_pressed():
	Gamemanager.resume_game()
	hide()

func _on_main_menu_pressed():
	Gamemanager.resume_game()
	get_tree().change_scene_to_file(
        "res://UI/Menu.tscn"
	)
