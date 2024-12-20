extends CharacterBody2D

# Определение состояний врага
enum {
	IDLE,      # Ожидание
	ATTACK,    # Атака
	CHASE,     # Преследование
	DAMAGE,    # Получение урона
	DEATH,     # Смерть
	RECOVER    # Состояние после смерти
}

# Состояние врага с автоматическим вызовом соответствующих методов
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

# Переменные для анимации
@onready var anim = $Moshroomhead_anim_player  # Анимационный плеер врага
@onready var sprite = $Moshroomhead_anim       # Спрайт врага

# Переменные для взаимодействия с игроком и движения
var player = Vector2.ZERO       # Позиция игрока
var direction = Vector2.ZERO    # Направление движения врага
var health = 100                # Здоровье врага
var damage = 10                 # Урон, наносимый врагом
var move_speed = 100            # Скорость движения врага

# Метод, вызываемый при загрузке узла
func _ready() -> void:
	# Подключение сигналов игрока для отслеживания его позиции и получения урона
	PlayerSignal.connect("player_position_update", Callable(self, "_on_player_position_update"))
	PlayerSignal.connect("player_attack", Callable(self, "_on_damage_received"))
	state = CHASE  # Установка начального состояния - преследование

# Обновление позиции игрока
func _on_player_position_update(player_pos):
	player = player_pos

# Основной цикл обработки физики
func _physics_process(delta: float) -> void:
	# Добавление гравитации, если враг не на земле
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Если враг в состоянии преследования, выполняется соответствующая логика
	if state == CHASE:
		chase_state()
	move_and_slide()

# Состояние ожидания
func idle_state():
	velocity.x = 0  # Остановка движения
	anim.play("Idle")  # Проигрывание анимации ожидания
	state = CHASE  # Переход к преследованию

# Состояние атаки
func attack_state():
	velocity.x = 0  # Остановка движения
	anim.play("Attack")  # Проигрывание анимации атаки
	await anim.animation_finished  # Ожидание завершения анимации
	state = RECOVER  # Переход в состояние восстановления

# Состояние преследования
func chase_state():
	anim.play("Run")  # Проигрывание анимации бега
	direction = (player - self.position).normalized()  # Вычисление направления к игроку
	# Инверсия спрайта при смене направления
	if direction.x < 0:
		sprite.flip_h = true
		$Attack_area.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$Attack_area.rotation_degrees = 0
	velocity.x = direction.x * move_speed  # Установка скорости движения

# Состояние получения урона
func damage_state():
	velocity.x = 0  # Остановка движения
	anim.play("Damage")  # Проигрывание анимации получения урона
	await anim.animation_finished  # Ожидание завершения анимации
	state = IDLE  # Переход в состояние ожидания

# Состояние смерти
func death_state():
	velocity.x = 0  # Остановка движения
	anim.play("Death")  # Проигрывание анимации смерти
	await anim.animation_finished  # Ожидание завершения анимации
	queue_free()  # Удаление объекта из сцены

# Состояние восстановления
func recover_state():
	velocity.x = 0  # Остановка движения
	anim.play("Recover")  # Проигрывание анимации восстановления
	await anim.animation_finished  # Ожидание завершения анимации
	state = IDLE  # Переход в состояние ожидания

# Обработка входа в область атаки
func _on_attack_body_entered(body: Node2D) -> void:
	state = ATTACK  # Переход в состояние атаки

# Обработка столкновения с хитбоксом
func _on_hitbox_area_entered(area: Area2D) -> void:
	PlayerSignal.emit_signal("enemy_attack", damage)  # Отправка сигнала о нанесении урона игроку

# Получение урона от игрока
func _on_damage_received(player_damage):
	health -= player_damage  # Уменьшение здоровья
	print(player_damage)  # Вывод нанесённого урона в консоль
	if health <= 0:
		state = DEATH  # Переход в состояние смерти
	else:
		state = IDLE  # Временно переход в ожидание
		state = DAMAGE  # Переход в состояние получения урона

# Метод для изменения скорости бега врага
func _on_run_speed_timeout() -> void:
	move_speed = move_toward(move_speed, randi_range(100, 150), 100)  # Изменение скорости с постепенным переходом
