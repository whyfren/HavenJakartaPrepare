extends Area2D

const HIT_EFFECT_SCENE := preload("res://entity/projectile/hit.tscn")


@export var speed: float = 420.0
@export var damage: float = 5.0
@export var lifetime: float = 3.0
@export_enum("arcane", "crimson", "electric", "fire", "holy", "ice", "plasma", "rose", "shadow", "toxic") var element: String = "fire"

var direction: Vector2 = Vector2.RIGHT
var _exploded: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if animated_sprite and animated_sprite.sprite_frames:
		if animated_sprite.sprite_frames.has_animation(element):
			animated_sprite.play(element)
		else:
			animated_sprite.play()
	rotation = direction.angle()
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if _exploded:
		return
	rotation = direction.angle()
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if is_instance_valid(player) and global_position.distance_to(player.global_position) < 30.0:
		Gamemanager.take_damage(damage)
		_explode()

func _on_body_entered(body: Node2D) -> void:
	if _exploded:
		return
	if body.is_in_group("player"):
		Gamemanager.take_damage(damage)
		_explode()
	elif body is TileMapLayer or body is StaticBody2D:
		_explode()

func _explode() -> void:
	if _exploded:
		return
	_exploded = true
	Audiomanager.play_sfx("blast")
	if HIT_EFFECT_SCENE and get_tree().current_scene:
		var hit := HIT_EFFECT_SCENE.instantiate()
		hit.global_position = global_position
		hit.scale = scale * 2.0
		hit.animation_name = element
		get_tree().current_scene.call_deferred("add_child", hit)
	queue_free()
