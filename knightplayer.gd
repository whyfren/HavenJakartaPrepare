extends CharacterBody2D

const SPEED = 400.0

@onready var animasi: AnimatedSprite2D = $AnimatedSprite2D

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
