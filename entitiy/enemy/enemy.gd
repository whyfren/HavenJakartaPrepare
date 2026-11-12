extends CharacterBody2D

const WANDER_SPEED := 140.0
const VIEW_RANGE := 500.0
const FIREBALL_SPEED := 420.0
const SHOOT_COOLDOWN := 1.2
const WANDER_CHANGE_TIME := 2.5
const FIREBALL_LIFETIME := 3.0
const FIREBALL_SCENE := preload("res://entity/projectile/fireball.tscn")

# @export var player_path: NodePath

var wander_direction := Vector2.ZERO
var wander_time_left := 0.0
var shoot_time_left := 0.0
@export var player: Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	randomize()
	_choose_wander_direction()



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
			_shoot_fireball(player.global_position)
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

func _choose_wander_direction() -> void:
	wander_direction = Vector2.from_angle(randf_range(0.0, TAU))
	wander_time_left = randf_range(1.0, WANDER_CHANGE_TIME)

func _shoot_fireball(target_position: Vector2) -> void:
	var direction := global_position.direction_to(target_position)
	var fireball := FIREBALL_SCENE.instantiate()
	fireball.scale = fireball.scale * 4
	fireball.global_position = global_position + direction * 38.0
	fireball.direction = direction
	fireball.speed = FIREBALL_SPEED
	fireball.lifetime = FIREBALL_LIFETIME
	audio.play()
	get_tree().current_scene.add_child(fireball)
