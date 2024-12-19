extends CharacterBody2D

enum{
	IDLE,
	ATTACK,
	CHASE,
	DAMAGE,
	DEATH,
	RECOVER
}

var state: int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()

@onready var anim = $Moshroomhead_anim_player
@onready var sprite = $Moshroomhead_anim

var player = Vector2.ZERO
var direction = Vector2.ZERO
var health = 100
var damage = 10
var move_speed = 100

func _ready() -> void:
	PlayerSignal.connect("player_position_update", Callable(self, "_on_player_position_update"))
	PlayerSignal.connect("player_attack", Callable(self, "_on_damage_received")) 
	state = CHASE

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
	velocity.x = 0
	anim.play("Idle")
	state = CHASE

func attack_state():
	velocity.x = 0
	anim.play("Attack")
	await anim.animation_finished
	state = RECOVER

func chase_state():
	anim.play("Run")
	direction = (player - self.position).normalized()
	if direction.x < 0:
		sprite.flip_h = true
		$Attack_area.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$Attack_area.rotation_degrees = 0
	velocity.x = direction.x * move_speed

func damage_state():
	velocity.x = 0
	anim.play("Damage")
	await anim.animation_finished
	state = IDLE

func death_state():
	velocity.x = 0
	anim.play("Death")
	await anim.animation_finished
	queue_free()

func recover_state():
	velocity.x = 0
	anim.play("Recover")
	await anim.animation_finished
	state = IDLE

func _on_hitbox_area_entered(area: Area2D) -> void:
	PlayerSignal.emit_signal("enemy_attack", damage)

func _on_damage_received (player_damage):
	health -= player_damage
	print (player_damage)
	if health <= 0:
		state = DEATH
	else:
		state = IDLE
		state = DAMAGE

func _on_run_speed_timeout() -> void:
	move_speed = move_toward(move_speed, randi_range(100, 150), 100)
