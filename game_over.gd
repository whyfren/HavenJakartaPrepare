extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	Gamemanager.game_over_started.connect(_on_game_over)
	hide()


func _on_game_over() -> void:
	show()


func _on_restart_pressed() -> void:
	Gamemanager.restart_game()


func _on_main_menu_pressed() -> void:
	Gamemanager.go_to_main_menu()
