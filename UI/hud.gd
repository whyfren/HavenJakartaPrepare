extends Control

@onready var health_bar: ProgressBar = %ProgressBar
@onready var health_label: Label = %Label
@onready var pause_button: Button = %Pause

func _ready() -> void:
	Gamemanager.health_changed.connect(_on_health_changed)

	_update_health(
		Gamemanager.current_health,
		Gamemanager.max_health
	)


func _on_health_changed(current: float, maximum: float) -> void:
	_update_health(current, maximum)
	
	
func _on_pause_pressed():
	Gamemanager.toggle_pause()


func _update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

	health_label.text = "HP: %d" % [current]
