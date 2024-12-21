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
			anim.stop()  # Остановка текущей анимации
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

# Переменные для анимации
@onready var anim = $Moshroomhead_anim_player  # Анимационный плеер врага

# Переменные для взаимодействия с игроком и движения
var player                       # Позиция игрока
var health = 100                 # Здоровье врага
var damage = 10                  # Урон врага
var move_speed = 100             # Скорость движения врага
var alive = true                 # Статус врага
var chase = false                # Флаг преследования

# Радиус атаки
const ATTACK_RANGE = 40.0

func _ready() -> void:
	# Подключение сигналов игрока
	PlayerSignal.connect("player_position_update", Callable(self, "_on_player_position_update"))
	PlayerSignal.connect("player_attack", Callable(self, "_on_damage_received"))

# Обновление позиции игрока
func _on_player_position_update(player_pos: Vector2) -> void:
	player = player_pos

func set_state(new_state: int) -> void:
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

		# Преследование игрока
		if state == CHASE:
			var direction = (player - position).normalized()
			velocity.x = direction.x * move_speed
			anim.play("Run")
			$Moshroomhead_anim.flip_h = direction.x < 0
	else:
		velocity.x = 0
		anim.play("Idle")

	move_and_slide()

# Состояние ожидания
func idle_state():
	velocity.x = 0
	anim.play("Idle")

# Состояние преследования
func chase_state():
	anim.play("Run")

# Обработка входа в зону агрессии
func _on_agro_zone_moshroom_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true
		call_deferred("set_state", CHASE)

# Обработка выхода из зоны агрессии
func _on_agro_zone_moshroom_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false
		call_deferred("set_state", IDLE)

# Состояние атаки
func attack_state():
	velocity.x = 0
	anim.play("Attack")
	await anim.animation_finished  # Ожидание завершения анимации атаки

	# Проверка, что игрок всё ещё находится в зоне атаки перед нанесением урона
	if position.distance_to(player) <= ATTACK_RANGE and state == ATTACK:
		PlayerSignal.emit_signal("enemy_attack", damage)  # Наносим урон игроку

	state = CHASE  # Возвращаемся к преследованию

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
	if state == DEATH:
		return  # Если моб уже мёртв, игнорируем урон

	health -= player_damage
	if health <= 0:
		alive = false
		call_deferred("set_state", DEATH)  # Отложенное переключение в состояние смерти
	else:
		call_deferred("set_state", DAMAGE)  # Отложенное переключение в состояние получения урона
