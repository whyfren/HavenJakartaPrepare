extends CharacterBody2D

const SPEED = 600.0

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var hitbox: Area2D = %Hitbox

func _ready():
	Gamemanager.damaged.connect(damaged)
	Gamemanager.level_up.connect(_on_level_up)
	
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0

func _on_level_up(new_level: int) -> void:
	# Efek kilatan emas saat level up
	if animasi:
		var orig_mod: Color = animasi.modulate
		animasi.modulate = Color(2.5, 2.0, 0.4, 1.0)
		var tween := create_tween()
		tween.tween_property(animasi, "modulate", orig_mod, 0.5)

	# Teks mengambang "LEVEL UP!"
	var lbl := Label.new()
	lbl.text = "LEVEL UP! (LV. %d)\nDAMAGE +5" % new_level
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.position = Vector2(-70, -90)
	lbl.modulate = Color(1.0, 0.9, 0.2, 1.0)
	add_child(lbl)

	var tween_lbl := create_tween()
	tween_lbl.tween_property(lbl, "position:y", -140.0, 1.2)
	tween_lbl.parallel().tween_property(lbl, "modulate:a", 0.0, 1.2)
	tween_lbl.tween_callback(lbl.queue_free)

func damaged() -> void:
	await camera_shake(5.0, 0.2)

func camera_shake(intensity: float, duration: float):
	var elapsed := 0.0

	while elapsed < duration:
		camera.offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)

		await get_tree().create_timer(0.02).timeout
		elapsed += 0.02

	camera.offset = Vector2.ZERO

var is_attacking: bool = false

func _physics_process(_delta: float) -> void:
	var move := Input.get_vector("left", "right", "up", "down")

	velocity = move * SPEED
	move_and_slide()

	if move.x != 0:
		animasi.flip_h = move.x < 0
		hitbox.scale.x = -1 if move.x < 0 else 1

	if is_attacking: return

	if move != Vector2.ZERO:
		animasi.play("walk")
	else:
		animasi.stop()
		animasi.frame = 0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not is_attacking:
		attack()

func attack() -> void:
	is_attacking = true
	animasi.play("attack")
	hitbox.call("attack")

func is_parrying() -> bool:
	return is_attacking
	
func _on_animated_sprite_2d_animation_finished() -> void:
	if animasi.animation == "attack":
		is_attacking = false
		animasi.animation = "walk"
		animasi.frame = 0
