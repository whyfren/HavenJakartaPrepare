extends CharacterBody2D

const WANDER_SPEED := 140.0
const VIEW_RANGE := 500.0
const ARROW_SPEED := 420.0
const SHOOT_COOLDOWN := 1.2
const WANDER_CHANGE_TIME := 2.5
const ARROW_LIFETIME := 3.0

# @export var player_path: NodePath

var wander_direction := Vector2.ZERO
var wander_time_left := 0.0
var shoot_time_left := 0.0
var arrows: Array[Dictionary] = []
@export var player: Node2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	randomize()
	_choose_wander_direction()
	# if not player_path.is_empty():
	# 	player = get_node_or_null(player_path) as Node2D

func _physics_process(delta: float) -> void:
	wander_time_left -= delta
	shoot_time_left -= delta
	
	print(velocity.angle())

	var target_in_range := is_instance_valid(player) and global_position.distance_to(player.global_position) <= VIEW_RANGE
	if target_in_range:
		velocity = Vector2.ZERO
		sprite.look_at(player.global_position)
		sprite.rotation += PI / 2
		if shoot_time_left <= 0.0:
			_shoot_arrow(player.global_position)
			shoot_time_left = SHOOT_COOLDOWN
	elif wander_time_left <= 0.0:
		_choose_wander_direction()
		velocity = wander_direction * WANDER_SPEED
		move_and_slide()
		sprite.rotation = velocity.angle() + PI / 2
	else:
		velocity = wander_direction * WANDER_SPEED
		move_and_slide()
		if velocity != Vector2.ZERO:
			sprite.rotation = velocity.angle() + PI / 2

	_update_arrows(delta)

func _choose_wander_direction() -> void:
	wander_direction = Vector2.from_angle(randf_range(0.0, TAU))
	wander_time_left = randf_range(1.0, WANDER_CHANGE_TIME)

func _shoot_arrow(target_position: Vector2) -> void:
	var direction := global_position.direction_to(target_position)
	var arrow := Area2D.new()
	arrow.collision_layer = 0
	arrow.collision_mask = 1
	arrow.global_position = global_position + direction * 38.0

	var arrow_sprite := Sprite2D.new()
	arrow_sprite.texture = load("res://icon.svg")
	arrow_sprite.scale = Vector2(0.4, 0.1)
	arrow_sprite.rotation = direction.angle()
	arrow.add_child(arrow_sprite)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 8.0
	shape.shape = circle
	arrow.add_child(shape)

	get_tree().current_scene.add_child(arrow)
	arrows.append({"node": arrow, "velocity": direction * ARROW_SPEED, "time_left": ARROW_LIFETIME})

func _update_arrows(delta: float) -> void:
	for arrow_data in arrows.duplicate():
		var arrow := arrow_data.node as Area2D
		if not is_instance_valid(arrow):
			arrows.erase(arrow_data)
			continue

		arrow.global_position += arrow_data.velocity * delta
		arrow_data.time_left -= delta
		if arrow_data.time_left <= 0.0:
			arrow.queue_free()
			arrows.erase(arrow_data)
			continue

		if is_instance_valid(player) and arrow.global_position.distance_to(player.global_position) < 30.0:
			Gamemanager.take_damage(5.0)
			arrow.queue_free()
			arrows.erase(arrow_data)
