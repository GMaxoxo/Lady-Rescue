extends CharacterBody2D

signal health_changed (new_health) 

# Определение состояний игрока
enum {
	IDLE,             # Ожидание
	MOVE,             # Движение
	ATTACK,           # Атака
	DAMAGE,           # Получение урона
	COMBO_ATTACK_1,   # Комбо атака 1
	COMBO_ATTACK_2,   # Комбо атака 2
	DEATH,            # Смерть
	BLOCK,            # Блокировка
	SLIDE             # Скольжение
}

# Константы скорости и силы прыжка
const SPEED = 200.0
const JUMP_VELOCITY = -300.0

# Ссылки на анимационные узлы
@onready var anim = $Player_Anim
@onready var animpack = $AnimationPlayer

# Переменные для управления состояниями и параметрами игрока
var max_health = 100            # Максимальное здоровье игрока
var health                      # Здоровье игрока
var state = MOVE                # Текущее состояние игрока
var run_speed = 0.8             # Скорость бега
var combo = false               # Флаг выполнения комбо
var player_pos                  # Позиция игрока
var damage_basic = 20           # Базовый урон
var combo_damage = 1            # Коэффициент увеличения урона для комбо
var damage_current              # Текущий урон

# Инициализация
func _ready() -> void:
	# Подключение сигнала для обработки урона от врагов
	PlayerSignal.connect("enemy_attack", Callable(self, "_on_damage_received"))
	health = max_health

# Основной цикл обработки физики
func _physics_process(delta: float) -> void:
	# Добавление гравитации, если игрок не на земле
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Анимация падения, если игрок падает
	if velocity.y > 0:
		animpack.play("Fall")
	
	# Расчёт текущего урона с учётом комбо
	damage_current = damage_basic * combo_damage
	
	# Переключение между состояниями
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
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
	
	# Движение персонажа
	move_and_slide()
	
	# Обновление позиции игрока
	player_pos = self.position
	PlayerSignal.emit_signal("player_position_update", player_pos)

# Состояние движения
func move_state():
	var direction := Input.get_axis("Left", "Right")  # Получение направления движения
	if direction:
		velocity.x = direction * SPEED * run_speed  # Установка скорости
		if velocity.y == 0:
			# Выбор анимации ходьбы или бега
			if run_speed == 0.5:
				animpack.play("Walk")
			else:
				animpack.play("Sprint")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)  # Плавное замедление
		if velocity.y == 0:
			animpack.play("Idle")  # Анимация ожидания
	
	# Инверсия спрайта при изменении направления
	if direction == 1:
		anim.flip_h = false
		$Attack_area.rotation_degrees = 0
	elif direction == -1:
		anim.flip_h = true
		$Attack_area.rotation_degrees = 180
	
	# Управление скоростью бега
	if Input.is_action_pressed("Run"):
		run_speed = 1
	else:
		run_speed = 0.5
	
	# Атака
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	
	# Прыжок
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animpack.play("Jump")
	
	# Блок с переходом на уворот
	if Input.is_action_just_pressed("Block"):
		if velocity.x == 0:
			state = BLOCK
		else:
			state = SLIDE

# Состояние блока
func block_state():
	velocity.x = 0
	animpack.play("Block")
	if Input.is_action_just_released("Block"):
		state = MOVE

# Состояние уворота
func slide_state():
	# Отключение коллизий
	set_collision_layer(0)
	set_collision_mask(1)
	
	animpack.play("Slide")
	await animpack.animation_finished
	
	# Включение коллизий
	set_collision_layer(3)
	set_collision_mask(1)
	
	state = MOVE

# Состояние атаки
func attack_state():
	combo_damage = 1  # Комбо множитель = 1
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = COMBO_ATTACK_1
	velocity.x = 0
	animpack.play("Attack")
	await animpack.animation_finished
	state = MOVE

# Выполнение комбо
func combo_attack():
	combo = true
	await animpack.animation_finished
	combo = false

# Первая комбо-атака
func combo_attack_1():
	combo_damage = 1.5 # Комбо множитель = 1.5
	if Input.is_action_just_pressed("Attack") and combo == true:
		state = COMBO_ATTACK_2
	animpack.play("Combo Attack 1")
	await animpack.animation_finished
	state = MOVE

# Вторая комбо-атака
func combo_attack_2():
	combo_damage = 2 # Комбо множитель = 2
	animpack.play("Combo Attack 2")
	await animpack.animation_finished
	state = MOVE

# Состояние получения урона
func damage_state():
	velocity.x = 0
	animpack.play("Damage")
	await animpack.animation_finished
	state = MOVE

# Состояние смерти
func death_state():
	velocity.x = 0
	animpack.play("Death")
	await animpack.animation_finished
	
	# Проверка существования дерева
	if get_tree():
		get_tree().change_scene_to_file("res://Scene/Main_menu/Main.tscn")
	
	queue_free()  # Удаление объекта

# Получение урона от врага
func _on_damage_received(enemy_damage):
	if state == BLOCK:
		enemy_damage /= 2  # Уменьшение урона при блоке
	elif state == SLIDE:
		enemy_damage = 0  # Урон не наносится при увороте
	else:
		state = DAMAGE  # Переход в состояние получения урона
	health -= enemy_damage
	if health <= 0:
		health = 0
		state = DEATH  # Переход в состояние смерти
		
	emit_signal("health_changed", health)

# Обработка столкновения с хитбоксом
func _on_hitbox_area_entered(area: Area2D) -> void:
	PlayerSignal.emit_signal("player_attack", damage_current)
