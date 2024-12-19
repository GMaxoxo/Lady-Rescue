extends CharacterBody2D

enum{
	IDLE,
	ATTACK,
	CHASE
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			CHASE:
				pass

@onready var anim = $Moshroomhead_anim_player
@onready var sprite = $Moshroomhead_anim

var player
var direction
var damage = 10

func _ready() -> void:
	PlayerSignal.connect("player_position_update", Callable(self, "_on_player_position_update"))
	
func _on_player_position_update(player_pos):
	player = player_pos
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if state == CHASE:
		chase_state()
	move_and_slide()

func _on_attack_body_entered(body: Node2D) -> void:
	state = ATTACK
	
func idle_state():
	anim.play("Idle")
	await get_tree().create_timer(1).timeout
	$Attack_area/Attack/Attack_collision.disabled = false
	state = CHASE
	
func attack_state():
	anim.play("Attack")
	await anim.animation_finished
	$Attack_area/Attack/Attack_collision.disabled = true
	state = IDLE

func chase_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$Attack_area.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$Attack_area.rotation_degrees = 0

func _on_hitbox_area_entered(area: Area2D) -> void:
	PlayerSignal.emit_signal("enemy_attack", damage)
