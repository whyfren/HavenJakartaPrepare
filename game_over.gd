extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	Gamemanager.game_over_started.connect(_on_game_over)
	hide()


func _on_game_over() -> void:
	show()


func _on_restart_pressed() -> void:
	Audiomanager.play_sfx("click")
	Gamemanager.restart_game()
	
func _on_settings_pressed() -> void:
	Audiomanager.play_sfx("click")


func _on_main_menu_pressed() -> void:
	Audiomanager.play_sfx("click")
	Gamemanager.go_to_main_menu()
