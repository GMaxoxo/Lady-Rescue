extends Node2D

@onready var healthbar = $HUD/Healthbar
@onready var player = $Player/Player

var skeleton_preload = preload("res://Enemy/skeleton.tscn") 
var moshroom_preload = preload("res://Enemy/moshroomhead.tscn") 
var moshroom_max_mobs = 3
var skeleton_max_mobs = 3
var moshroom_mobs = 0
var skeleton_mobs = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	healthbar.max_value = player.max_health
	healthbar.value = healthbar.max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_health_changed(new_health: Variant) -> void:
	healthbar.value = new_health


func _on_spawner_timeout() -> void:
	moshroom_spawn()
	skeleton_spawn()


func moshroom_spawn():
	if moshroom_mobs < moshroom_max_mobs:
		var moshroom = moshroom_preload.instantiate()
		moshroom.position = Vector2(randf_range(-250, -500), 606)
		$Enemy.add_child(moshroom)
		moshroom_mobs += 1
		moshroom.connect("tree_exited", Callable(self, "_on_mob_removed")) # Подключаем сигнал для отслеживания удаления моба

func skeleton_spawn():
	if skeleton_mobs < skeleton_max_mobs:
		var skeleton = skeleton_preload.instantiate()
		skeleton.position = Vector2(randf_range(-800, -900), 606)
		$Enemy.add_child(skeleton)
		skeleton_mobs += 1
		skeleton.connect("tree_exited", Callable(self, "_on_mob_removed")) # Подключаем сигнал для отслеживания удаления моба

func _on_mob_removed():
	moshroom_mobs -= 1
	skeleton_mobs -= 1
