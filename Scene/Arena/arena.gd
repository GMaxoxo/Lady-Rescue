extends Node2D

@onready var healthbar = $HUD/Healthbar
@onready var player = $Player/Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthbar.max_value = player.max_health
	healthbar.value = healthbar.max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_health_changed(new_health: Variant) -> void:
	healthbar.value = new_health
