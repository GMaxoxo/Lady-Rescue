extends CharacterBody2D

enum{
	IDLE,
	MOVE,
	ATTACK,
	DAMAGE,
	COMBO_ATTACK_1,
	COMBO_ATTACK_2,
	DEATH
}

const SPEED = 200.0
const JUMP_VELOCITY = -300.0

#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $Player_Anim
@onready var animpack = $AnimationPlayer

var health = 20
var gold = 0
var state = MOVE
var run_speed = 0.8
var combo = false
var player_pos

func _ready() -> void:
	PlayerSignal.connect("enemy_attack", Callable(self, "_on_damage_received"))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if velocity.y > 0:
		animpack.play("Fall")
	
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		COMBO_ATTACK_1:
			combo_attack_1()
		COMBO_ATTACK_2:
			combo_attack_2()
		DEATH:
			death_state()
		DAMAGE:
			damage_state()
	move_and_slide()
	
	player_pos = self.position
	PlayerSignal.emit_signal("player_position_update", player_pos)

func move_state ():
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED * run_speed
		if velocity.y == 0:
			if run_speed == 0.8:
				animpack.play("Walk")
			else:
				animpack.play("Sprint")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animpack.play("Idle")

	if direction == 1:
		anim.flip_h = false
	elif direction == -1:
		anim.flip_h = true
		
	if Input.is_action_pressed("Run"):
		run_speed = 1.5
	else:
		run_speed = 0.8
		
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
		
	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animpack.play("Jump")

func attack_state():
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = COMBO_ATTACK_1
	velocity.x = 0
	animpack.play("Attack")
	await animpack.animation_finished
	state = MOVE

func combo_attack():
	combo = true
	await animpack.animation_finished
	combo = false

func combo_attack_1():
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = COMBO_ATTACK_2
	animpack.play("Combo Attack 1")
	await animpack.animation_finished
	state = MOVE

func combo_attack_2():
	animpack.play("Combo Attack 2")
	await animpack.animation_finished
	state = MOVE

func death_state():
	velocity.x = 0
	animpack.play("Death")
	await animpack.animation_finished
	queue_free()
	get_tree().change_scene_to_file("res://Scene/Main_menu/main_menu.tscn")

func damage_state():
	velocity.x = 0
	animpack.play("Damage")
	await animpack.animation_finished
	state = MOVE

func _on_damage_received(enemy_damage):
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH
	else:
		state = DAMAGE
	print(health)
