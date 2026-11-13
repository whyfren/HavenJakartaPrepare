extends Area2D

@export var damage: int = 20
@onready var collision_shape: CollisionShape2D = %HitboxCollision

var hit_targets: Array[Node] = []

func _ready() -> void:
	add_to_group("player_hitbox")
	collision_shape.disabled = true

func attack() -> void:
	hit_targets.clear()
	collision_shape.disabled = false
	await get_tree().create_timer(0.3).timeout
	collision_shape.disabled = true
	hit_targets.clear()

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("parry"):
		area.parry(get_parent())
		return

	var target: Node = area.get_parent()
	var damage_receiver: Node = null

	if is_instance_valid(target) and not target.is_queued_for_deletion() and target.has_method("take_damage"):
		damage_receiver = target
	elif is_instance_valid(area) and not area.is_queued_for_deletion() and area.has_method("take_damage"):
		damage_receiver = area

	if damage_receiver and not damage_receiver in hit_targets:
		hit_targets.append(damage_receiver)
		var current_damage: int = Gamemanager.get_player_damage(damage)
		damage_receiver.take_damage(current_damage)
