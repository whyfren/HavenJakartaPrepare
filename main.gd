extends Node

@onready var pause_menu = $UI/PauseMenu

func _input(event):
	if event.is_action_pressed("esc"):
		toggle_pause()

func toggle_pause():
	var is_paused = not get_tree().paused

	get_tree().paused = is_paused
	pause_menu.visible = is_paused
