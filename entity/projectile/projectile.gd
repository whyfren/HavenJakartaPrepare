extends Area2D

const HIT_EFFECT_SCENE := preload("res://entity/projectile/hit.tscn")

@export var speed: float = 420.0
@export var damage: float = 5.0
@export var lifetime: float = 3.0
@export_enum("arcane", "crimson", "electric", "fire", "holy", "ice", "plasma", "rose", "shadow", "toxic") var element: String = "fire"

var direction: Vector2 = Vector2.RIGHT
var _exploded: bool = false
var is_parried: bool = false

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
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if _exploded:
		return
	rotation = direction.angle()
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return

	if not is_parried:
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if is_instance_valid(player):
			var dist := global_position.distance_to(player.global_position)
			
			# Sistem Parry: Jika player sedang menyerang (is_attacking) dan proyektil berada dalam jangkauan pedang
			var is_attacking: bool = bool(player.get("is_attacking"))
			if is_attacking and dist < 110.0:
				var to_proj := global_position - player.global_position
				var facing_left: bool = false
				if player.has_node("AnimatedSprite2D"):
					facing_left = player.get_node("AnimatedSprite2D").flip_h
				var facing_dir := Vector2.LEFT if facing_left else Vector2.RIGHT
				
				# Cek apakah proyektil berada di arah tebasan atau dekat dengan pedang
				if to_proj.normalized().dot(facing_dir) > -0.3 or dist < 65.0:
					parry(player)
					return

			# Jika tidak tertangkis dan mengenai player
			if dist < 30.0:
				Gamemanager.take_damage(damage)
				_explode()
	else:
		# Jika sudah di-parry: cari musuh terdekat untuk dihantam
		var parry_damage: int = int(Gamemanager.get_player_damage(10) * 3.0)
		for enemy in get_tree().get_nodes_in_group("enemy"):
			if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
				if global_position.distance_to(enemy.global_position) < 45.0:
					if enemy.has_method("take_damage"):
						enemy.take_damage(parry_damage)
					_explode()
					return

func _on_body_entered(body: Node2D) -> void:
	if _exploded:
		return
	if not is_parried:
		if body.is_in_group("player"):
			if body.get("is_attacking"):
				parry(body)
				return
			Gamemanager.take_damage(damage)
			_explode()
		elif body is TileMapLayer or body is StaticBody2D:
			_explode()
	else:
		if body.is_in_group("player"):
			return # Abaikan player, jangan sampai melukai player sendiri
		if body.has_method("take_damage"):
			var parry_damage: int = int(Gamemanager.get_player_damage(10) * 3.0)
			body.take_damage(parry_damage)
			_explode()
		elif body is TileMapLayer or body is StaticBody2D:
			_explode()

func _on_area_entered(area: Area2D) -> void:
	if _exploded:
		return
	if not is_parried:
		# Deteksi sentuhan dengan Hitbox pedang player
		if area.name == "Hitbox" or area.is_in_group("player_hitbox"):
			var player := area.get_parent()
			if is_instance_valid(player) and player.get("is_attacking"):
				parry(player)
				return
	else:
		# Deteksi sentuhan dengan Hurtbox musuh
		var target := area.get_parent()
		if is_instance_valid(target) and not target.is_in_group("player") and target.has_method("take_damage"):
			var parry_damage: int = int(Gamemanager.get_player_damage(10) * 3.0)
			target.take_damage(parry_damage)
			_explode()

## Fungsi untuk membalikkan proyektil dan memicu efek parry
func parry(player: Node2D) -> void:
	if is_parried or _exploded:
		return
	is_parried = true

	# 1. Pantulkan arahnya ke musuh terdekat, atau balikkan arah jika musuh tidak ditemukan
	var nearest_enemy: Node2D = null
	var min_dist: float = 999999.0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			var d := global_position.distance_to(enemy.global_position)
			if d < min_dist:
				min_dist = d
				nearest_enemy = enemy

	if nearest_enemy:
		direction = global_position.direction_to(nearest_enemy.global_position)
	else:
		direction = -direction

	# 2. Tingkatkan kecepatan proyektil dan reset lifetime
	speed *= 1.6
	lifetime = 4.0
	rotation = direction.angle()

	# 3. Ubah warna visual proyektil menjadi emas bercahaya (parried glow)
	if animated_sprite:
		animated_sprite.modulate = Color(2.5, 2.0, 0.4, 1.0)
	scale = scale * 1.3

	# 4. Munculkan efek kilatan/spark di titik benturan pedang
	if HIT_EFFECT_SCENE and get_tree().current_scene:
		var spark := HIT_EFFECT_SCENE.instantiate()
		spark.global_position = global_position
		spark.scale = scale * 2.0
		spark.animation_name = "holy" if element != "holy" else "arcane"
		get_tree().current_scene.call_deferred("add_child", spark)

	# 5. Putar efek suara parry (benturan logam / clink ber-pitch tinggi)
	if Audiomanager:
		Audiomanager.play_sfx("blast", 2.2)

	# 6. Guncangan kamera (camera shake)
	if player and player.has_method("camera_shake"):
		player.camera_shake(7.0, 0.15)

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
