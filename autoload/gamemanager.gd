extends Node


signal pause_changed(paused: bool)
signal health_changed(current_health: float, max_health: float)
@onready var pause_menu = "res://UI/pause_menu.tscn"


var max_health: float = 100.0
var current_health: float = 100.0
var is_paused: bool = false

func take_damage(amount: float) -> void:
	current_health = maxf(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)


func heal(amount: float) -> void:
	current_health = minf(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_changed.emit(is_paused)


func resume_game() -> void:
	is_paused = false
	get_tree().paused = false
	pause_changed.emit(false)

func reset_health() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
