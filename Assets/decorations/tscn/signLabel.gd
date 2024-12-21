<<<<<<< HEAD
extends Node2D

@export var messageText: String
@export var texture: Texture

@onready var marginContainer = $NinePatchRect/MarginContainer
@onready var label = $NinePatchRect/MarginContainer/Label
@onready var textureRect = $NinePatchRect/MarginContainer/TextureRect

func _ready():
	#hide()
	if messageText:
		label.visible = true
		label.text = messageText
		textureRect.visible = false
	elif texture:
		label.visible = false
		textureRect.visible = true
		textureRect.texture = texture
	else:
		label.visible = false
		textureRect.visible = false
	update_size()

func _process(delta):
	update_size()

func update_size():
	var marginSide = (marginContainer.get_theme_constant("margin_left")
					+ marginContainer.get_theme_constant("margin_right"))
	if label.visible:
		$NinePatchRect.size.x = label.size.x + marginSide
	elif textureRect.visible:
		$NinePatchRect.size.x = textureRect.texture.get_size().x + marginSide
#
#func _on_show_message_box():
	#show()
#func _on_hide_message_box():
	#hide()
=======
extends Node2D 

@export var messageText: String  # Текст, который будет отображаться в элементе
@export var texture: Texture  # Текстура, которая будет отображаться, если нет текста

@onready var marginContainer = $NinePatchRect/MarginContainer  # Контейнер для управления отступами
@onready var label = $NinePatchRect/MarginContainer/Label  # Текстовая метка для отображения сообщения
@onready var textureRect = $NinePatchRect/MarginContainer/TextureRect  # Прямоугольник для отображения текстуры
@onready var area = $Player_detecter  # Область (Area2D), которая будет отслеживать, когда игрок входит в зону
@onready var player = get_node("../../Player/Player")  # Узел игрока, на основе которого мы будем отслеживать его позицию

var is_player_near = false  # Флаг для проверки, находится ли игрок рядом с элементом

func _ready():
	# Скрываем элемент изначально
	hide_element()

	# Подключаем сигналы для отслеживания входа и выхода игрока из зоны
	area.connect("body_entered", Callable(self, "_on_area_entered"))  # Когда игрок входит в зону
	area.connect("body_exited", Callable(self, "_on_area_exited"))  # Когда игрок выходит из зоны

	# Настройка отображаемого содержимого в зависимости от переменных
	if messageText:  # Если есть текст, показываем его
		label.text = messageText  # Устанавливаем текст на метке
		textureRect.visible = false  # Скрываем текстуру
	elif texture:  # Если текстуры нет, но она есть, показываем её
		label.visible = false  # Скрываем текст
		textureRect.texture = texture  # Устанавливаем текстуру
		textureRect.visible = true  # Показываем текстуру

# Функция для отображения
func show_element():
	$NinePatchRect.visible = true  # Показываем контейнер (NinePatchRect), если он был скрыт
	if messageText:
		label.visible = true  # Показываем метку с текстом
		textureRect.visible = false  # Скрываем текстуру
	elif texture:
		label.visible = false  # Скрываем метку с текстом
		textureRect.visible = true  # Показываем текстуру

# Скрытие элемента
func hide_element():
	$NinePatchRect.visible = false  # Скрываем NinePatchRect
	label.visible = false  # Скрываем метку с текстом
	textureRect.visible = false  # Скрываем текстуру

# Обработчик входа в область
func _on_area_entered(body):
	if body == player:  # Проверяем, что это игрок
		is_player_near = true  # Игрок находится рядом
		show_element()  # Показываем элемент

# Обработка выхода из области
func _on_area_exited(body):
	if body == player:  # Проверяем, что это игрок
		is_player_near = false  # Игрок покидает зону
		hide_element()  # Скрываем элемент
>>>>>>> Master
