extends CharacterBody2D

# Определение состояний врага
enum {
	IDLE,      # Ожидание
	ATTACK,    # Атака
	CHASE,     # Преследование
	DAMAGE,    # Получение урона
	DEATH,     # Смерть
}

# Состояние врага
var state: int = IDLE:
	set(value):
		# Прерываем текущую анимацию при изменении состояния
		if state != value:
			state = value
			match state:
				IDLE:
					idle_state()
				ATTACK:
					attack_state()
				CHASE:
					chase_state()
				DAMAGE:
					damage_state()
				DEATH:
					death_state()

# Переменные для взаимодействия с игроком и движения
var player                       # Позиция игрока
var health = 75                  # Здоровье врага
var damage = 5                   # Урон врага
var move_speed = 75              # Скорость движения врага
var alive = true                 # Статус врага
var chase = false                # Флаг преследования

var player_dmg

# Радиус атаки
const ATTACK_RANGE = 35.0

@onready var anim = $Skeleton_anim_player

func _ready() -> void:
	# Подключение сигналов игрока
	PlayerSignal.connect("player_position_update", Callable(self, "_on_player_position_update"))
	PlayerSignal.connect("player_attack", Callable(self, "_on_damage_received"))

# Обновление позиции игрока
func _on_player_position_update(player_pos: Vector2) -> void:
	player = player_pos

func set_state(new_state: int) -> void:
	print("State changing from", state, "to", new_state)
	state = new_state

# Основной цикл обработки физики
func _physics_process(delta: float) -> void:
	if not alive:
		return

	if state == DAMAGE or state == DEATH:
		velocity.x = 0
		return

	if chase:
		var distance_to_player = position.distance_to(player)

		# Если игрок в зоне атаки, переключаемся в состояние ATTACK
		if distance_to_player <= ATTACK_RANGE and state != ATTACK:
			state = ATTACK
			return

	if state == CHASE:
		var direction = (player - position).normalized()
		velocity.x = direction.x * move_speed
		anim.play("Run")
		$Skeleton_Anim.flip_h = direction.x < 0  # Обновление направления взгляда

	move_and_slide()

# Состояние ожидания
func idle_state():
	velocity.x = 0
	anim.play("Idle")

# Состояние преследования
func chase_state():
	anim.play("Run")

# Обработка входа в зону агрессии
func _on_skeleton_agro_area_body_entered(body):
	if body.name == "Player":
		chase = true
		call_deferred("set_state", CHASE)

# Обработка выхода из зоны агрессии
func _on_skeleton_agro_area_body_exited(body):
	if body.name == "Player":
		chase = false
		call_deferred("set_state", IDLE)

# Состояние атаки
func attack_state():
	velocity.x = 0
	anim.play("Attack")
	await anim.animation_finished  # Ожидание завершения анимации атаки

	# Проверяем, находится ли игрок перед мобом и в зоне атаки
	var is_player_in_front = ($Skeleton_Anim.flip_h and player.x < position.x) or (not $Skeleton_Anim.flip_h and player.x > position.x)

	if position.distance_to(player) <= ATTACK_RANGE and is_player_in_front:
		# Попадание: наносим урон игроку
		PlayerSignal.emit_signal("enemy_attack", damage)

	# Возврат в состояние CHASE для продолжения преследования
	if alive:
		state = CHASE if chase else IDLE

# Состояние получения урона
func damage_state():
	velocity.x = 0  # Остановка перед проигрыванием анимации
	anim.play("Damage")
	await anim.animation_finished  # Ожидание завершения анимации получения урона
	# Возврат в активное состояние
	if alive:
		state = CHASE if chase else IDLE

# Состояние смерти
func death_state():
	velocity.x = 0
	anim.play("Death")
	await anim.animation_finished
	queue_free()

# Получение урона от игрока
func _on_damage_received(player_damage: int) -> void:
	player_dmg = player_damage

func _on_hurt_box_area_entered(area: Area2D) -> void:
	await get_tree().create_timer(0.1).timeout
	if state == DEATH:
		return  # Если моб уже мёртв, игнорируем урон

	health -= player_dmg
	if health <= 0:
		alive = false
		call_deferred("set_state", DEATH)  # Отложенное переключение в состояние смерти
	else:
		call_deferred("set_state", DAMAGE)  # Отложенное переключение в состояние получения урона
