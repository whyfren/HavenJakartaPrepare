extends CharacterBody2D

const SPEED = 600.0

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D

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
