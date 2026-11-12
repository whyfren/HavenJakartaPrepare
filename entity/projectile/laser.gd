extends Area2D

@export var damage: float = 10.0
@export var duration: float = 1.0
@export_enum("arcane", "crimson", "electric", "fire", "holy", "ice", "plasma", "rose", "shadow", "toxic") var element: String = "fire"

var direction: Vector2 = Vector2.RIGHT

@onready var start_sprite: AnimatedSprite2D = $Start
@onready var mid_sprite: AnimatedSprite2D = $Mid
@onready var end_sprite: AnimatedSprite2D = $End

func _ready() -> void:
	for part in [start_sprite, mid_sprite, end_sprite]:
		if part and part.sprite_frames and part.sprite_frames.has_animation(element):
			part.play(element)
	rotation = direction.angle()
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	duration -= delta
	if duration <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Gamemanager.take_damage(damage)
