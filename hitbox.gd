extends Area2D

@export var damage: int = 10
@onready var collision_shape: CollisionShape2D = %HitboxCollision

func _ready() -> void:
	add_to_group("player_hitbox")
	collision_shape.disabled = true

func attack() -> void:
	collision_shape.disabled = false
	await get_tree().create_timer(0.5).timeout
	collision_shape.disabled = true

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("parry"):
		area.parry(get_parent())
		return
		
	var target = area.get_parent()
	var current_damage: int = Gamemanager.get_player_damage(damage)
	
	if is_instance_valid(target) and not target.is_queued_for_deletion() and target.has_method("take_damage"):
		target.take_damage(current_damage)
	elif is_instance_valid(area) and not area.is_queued_for_deletion() and area.has_method("take_damage"):
		area.take_damage(current_damage)
