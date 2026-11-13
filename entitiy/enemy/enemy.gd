extends CharacterBody2D

const WANDER_SPEED := 140.0
const VIEW_RANGE := 500.0
const FIREBALL_SPEED := 420.0
const SHOOT_COOLDOWN := 1.2
const WANDER_CHANGE_TIME := 2.5
const FIREBALL_LIFETIME := 3.0
const FIREBALL_SCENE := preload("res://entity/projectile/fireball.tscn")
const HIT_EFFECT_SCENE := preload("res://entity/projectile/hit.tscn")

@export var base_hp: float = 25.0
@export var exp_reward: float = 10.0
@export var player: Node2D

var max_hp: float = 25.0
var current_hp: float = 25.0
var hp_bar: ProgressBar

var wander_direction := Vector2.ZERO
var wander_time_left := 0.0
var shoot_time_left := 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	add_to_group("enemy")
	randomize()
	_choose_wander_direction()
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	
	# Scaling HP berdasarkan waktu bermain dan level
	max_hp = Gamemanager.get_enemy_scaling_hp(base_hp)
	current_hp = max_hp
	_setup_hp_bar()

func _setup_hp_bar() -> void:
	hp_bar = ProgressBar.new()
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(50, 6)
	hp_bar.size = Vector2(50, 6)
	hp_bar.position = Vector2(-25, -42)
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	
	var sb_bg := StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	sb_bg.corner_radius_top_left = 2
	sb_bg.corner_radius_top_right = 2
	sb_bg.corner_radius_bottom_left = 2
	sb_bg.corner_radius_bottom_right = 2
	
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.9, 0.2, 0.2, 0.95)
	sb_fill.corner_radius_top_left = 2
	sb_fill.corner_radius_top_right = 2
	sb_fill.corner_radius_bottom_left = 2
	sb_fill.corner_radius_bottom_right = 2
	
	hp_bar.add_theme_stylebox_override("background", sb_bg)
	hp_bar.add_theme_stylebox_override("fill", sb_fill)
	add_child(hp_bar)
	hp_bar.visible = false # Ditampilkan saat pertama kali terkena damage

func _physics_process(delta: float) -> void:
	wander_time_left -= delta
	shoot_time_left -= delta

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

func take_damage(amount: int) -> void:
	current_hp -= amount
	if hp_bar:
		hp_bar.visible = true
		hp_bar.value = current_hp

	# Efek percikan saat terkena damage
	if HIT_EFFECT_SCENE and get_tree().current_scene:
		var hit := HIT_EFFECT_SCENE.instantiate()
		hit.global_position = global_position
		hit.scale = scale * 2.5
		hit.animation_name = "fire"
		get_tree().current_scene.call_deferred("add_child", hit)

	# Flash putih sesaat pada sprite musuh
	if sprite:
		var orig_color: Color = sprite.modulate
		sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
		get_tree().create_timer(0.08).timeout.connect(func():
			if is_instance_valid(sprite):
				sprite.modulate = orig_color
		)

	if current_hp <= 0:
		_die()

func _die() -> void:
	# Berikan EXP ke player
	Gamemanager.add_exp(exp_reward)
	Audiomanager.play_sfx("blast")
	
	if HIT_EFFECT_SCENE and get_tree().current_scene:
		var hit := HIT_EFFECT_SCENE.instantiate()
		hit.global_position = global_position
		hit.scale = scale * 4.0
		hit.animation_name = "fire"
		get_tree().current_scene.call_deferred("add_child", hit)

	queue_free()
