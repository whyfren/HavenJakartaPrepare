extends Node


signal pause_changed(paused: bool)
signal game_over_started()
signal health_changed(current_health: float, max_health: float)
@onready var pause_menu = "res://UI/pause_menu.tscn"
@onready var is_game_over: bool = false

var max_health: float = 100.0
var current_health: float = 100.0
var is_paused: bool = false

func take_damage(amount: float) -> void:
	if is_game_over:
		return
	
	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		trigger_game_over()


func heal(amount: float) -> void:
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func toggle_pause() -> void:
	if is_game_over:
		return
	
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_changed.emit(is_paused)

func trigger_game_over() -> void:
	if is_game_over:
		return

	is_game_over = true
	is_paused = true

	get_tree().paused = true
	game_over_started.emit()

func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	pause_changed.emit(false)

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
func restart_game() -> void:
	is_game_over = false
	is_paused = false
	get_tree().paused = false
	reset_health()
	get_tree().reload_current_scene()
	
func go_to_main_menu() -> void:
	is_game_over = false
	is_paused = false
	get_tree().paused = false
	reset_health()
	get_tree().change_scene_to_file("res://UI/Menu.tscn")
