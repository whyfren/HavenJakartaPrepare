extends Node2D

@export var enemy: PackedScene = preload("res://entitiy/enemy/enemy.tscn")
@export var player: CharacterBody2D

@export var min_delay: float = 2.0
@export var max_delay: float = 6.0
@export var min_spawn_distance: float = 400.0
@export var max_spawn_distance: float = 750.0

@onready var timer: Timer = $Timer
@onready var root = get_parent()

func _ready() -> void:
	randomize()
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	delay()

func _on_timer_timeout() -> void:
	spawn()
	delay()

func delay() -> void:
	timer.wait_time = randf_range(min_delay, max_delay)
	timer.start()

func spawn() -> void:
	if not enemy:
		return

	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	var instance = enemy.instantiate()
	instance.player = player

	var target_parent = root if root else self
	target_parent.add_child(instance)

	var spawn_pos: Vector2
	if is_instance_valid(player):
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(min_spawn_distance, max_spawn_distance)
		spawn_pos = player.global_position + Vector2.from_angle(angle) * distance
	else:
		var screen := get_viewport_rect().size
		spawn_pos = global_position + Vector2(randf_range(-screen.x * 0.5, screen.x * 0.5), randf_range(-screen.y * 0.5, screen.y * 0.5))

	instance.global_position = spawn_pos
