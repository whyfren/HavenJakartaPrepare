extends Control

@onready var health_bar: ProgressBar = %ProgressBar
@onready var health_label: Label = %Label
@onready var pause_button: Button = %Pause

var exp_bar: ProgressBar
var exp_label: Label
var level_label: Label
var level_panel: Panel

func _ready() -> void:
	Gamemanager.health_changed.connect(_on_health_changed)
	Gamemanager.exp_changed.connect(_on_exp_changed)
	Gamemanager.level_up.connect(_on_level_up)

	_setup_exp_and_level_ui()

	_update_health(Gamemanager.current_health, Gamemanager.max_health)
	_update_exp(Gamemanager.current_exp, Gamemanager.max_exp, Gamemanager.level)

func _setup_exp_and_level_ui() -> void:
	level_panel = Panel.new()
	level_panel.name = "LevelPanel"
	level_panel.offset_left = 12.0
	level_panel.offset_top = 70.0
	level_panel.offset_right = 91.0
	level_panel.offset_bottom = 96.0

	level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "LV. 1"
	level_label.offset_left = 0.0
	level_label.offset_top = 2.0
	level_label.offset_right = 79.0
	level_label.offset_bottom = 26.0
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_panel.add_child(level_label)
	add_child(level_panel)

	exp_bar = ProgressBar.new()
	exp_bar.name = "ExpBar"
	exp_bar.offset_left = 99.0
	exp_bar.offset_top = 70.0
	exp_bar.offset_right = 1068.0
	exp_bar.offset_bottom = 96.0
	exp_bar.show_percentage = false

	var sb_bg := StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.12, 0.12, 0.16, 0.85)
	sb_bg.corner_radius_top_left = 3
	sb_bg.corner_radius_top_right = 3
	sb_bg.corner_radius_bottom_left = 3
	sb_bg.corner_radius_bottom_right = 3

	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.2, 0.65, 1.0, 0.9)
	sb_fill.corner_radius_top_left = 3
	sb_fill.corner_radius_top_right = 3
	sb_fill.corner_radius_bottom_left = 3
	sb_fill.corner_radius_bottom_right = 3

	exp_bar.add_theme_stylebox_override("background", sb_bg)
	exp_bar.add_theme_stylebox_override("fill", sb_fill)

	exp_label = Label.new()
	exp_label.name = "ExpLabel"
	exp_label.text = "EXP: 0 / 20"
	exp_label.offset_left = 10.0
	exp_label.offset_top = 2.0
	exp_label.offset_right = 300.0
	exp_label.offset_bottom = 26.0
	exp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	exp_bar.add_child(exp_label)

	add_child(exp_bar)

func _on_health_changed(current: float, maximum: float) -> void:
	_update_health(current, maximum)

func _on_exp_changed(current: float, maximum: float, current_level: int) -> void:
	_update_exp(current, maximum, current_level)

func _on_level_up(new_level: int) -> void:
	if level_label:
		level_label.text = "LV. %d" % new_level
		var tween := create_tween()
		tween.tween_property(level_label, "modulate", Color(2.5, 2.0, 0.4, 1.0), 0.2)
		tween.tween_property(level_label, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)

func _on_pause_pressed() -> void:
	Audiomanager.play_sfx("click")
	Gamemanager.toggle_pause()

func _update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "HP: %d" % [current]

func _update_exp(current: float, maximum: float, current_level: int) -> void:
	if exp_bar:
		exp_bar.max_value = maximum
		exp_bar.value = current
	if exp_label:
		exp_label.text = "EXP: %d / %d" % [int(current), int(maximum)]
	if level_label:
		level_label.text = "LV. %d" % current_level
