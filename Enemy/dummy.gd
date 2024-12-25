extends CharacterBody2D

# Определение состояний врага
enum {
	IDLE,      # Ожидание
	CHASE,     # Преследование
	DAMAGE,    # Получение урона
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
				DAMAGE:
					damage_state()

# Переменные для анимации
@onready var anim = $Dummy_animplayer  # Анимационный плеер врага

# Переменные для взаимодействия с игроком и движения
var player                       # Позиция игрока
var health = 100000              # Здоровье врага
var move_speed = 100             # Скорость движения врага
var alive = true                 # Статус врага
var chase = false                # Флаг преследования

var player_dmg 

# Основной цикл обработки физики
func _physics_process(delta: float) -> void:
	if not alive:
		return

	if state == DAMAGE:
		velocity.x = 0
		return

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

# Состояние получения урона
func damage_state():
	velocity.x = 0  # Остановка перед проигрыванием анимации
	if anim.has_animation("Damage"):
		anim.play("Damage")
		await get_tree().create_timer(anim.current_animation_length).timeout

	# Возврат в активное состояние
	if alive:
		state = IDLE

# Получение урона от игрока
func _on_damage_received(player_damage: int) -> void:
	player_dmg = player_damage

func _on_hurt_box_area_entered(area: Area2D) -> void:
	health -= player_dmg
	if health > 0:
		call_deferred("set_state", DAMAGE)  # Отложенное переключение в состояние получения урона
	else:
		alive = false
		velocity.x = 0
		anim.play("Idle")
