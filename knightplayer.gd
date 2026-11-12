extends CharacterBody2D

const SPEED = 600.0

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

func _ready():
	Gamemanager.damaged.connect(damaged)
	
	camera.enabled = true
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		Gamemanager.take_damage(10)

	if event.is_action_pressed("ui_select"):
		Gamemanager.heal(10)

func _physics_process(_delta: float) -> void:
	var move := Input.get_vector("left", "right", "up", "down")

	velocity = move * SPEED
	move_and_slide()

	if move.x != 0:
		animasi.flip_h = move.x < 0

	if move != Vector2.ZERO:
		animasi.play("walk")
	else:
		animasi.stop()
		animasi.frame = 0
