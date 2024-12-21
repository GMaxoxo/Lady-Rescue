extends Node2D  # Наследуем от Node2D, так как этот объект должен быть двухмерным

# Экспортируем переменные, чтобы они были доступны для настройки в редакторе
@export var messageText: String  # Текст, который будет отображаться в элементе
@export var texture: Texture  # Текстура, которая будет отображаться, если нет текста

# Используем @onready для автоматической загрузки узлов, когда сцена будет готова
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

	if messageText:  # Если есть текст, показываем его
		label.text = messageText  # Устанавливаем текст на метке
		textureRect.visible = false  # Скрываем текстуру
	elif texture:  # Если текстуры нет, но она есть, показываем её
		label.visible = false  # Скрываем текст
		textureRect.texture = texture  # Устанавливаем текстуру
		textureRect.visible = true  # Показываем текстуру

func show_element():
	$NinePatchRect.visible = true  # Показываем контейнер (NinePatchRect), если он был скрыт
	if messageText:  # Если есть текст
		label.visible = true  # Показываем метку с текстом
		textureRect.visible = false  # Скрываем текстуру
	elif texture:  # Если текстуры нет, но она есть
		label.visible = false  # Скрываем метку с текстом
		textureRect.visible = true  # Показываем текстуру

func hide_element():
	$NinePatchRect.visible = false  # Скрываем NinePatchRect
	label.visible = false  # Скрываем метку с текстом
	textureRect.visible = false  # Скрываем текстуру

# Обработчик входа
func _on_area_entered(body):
	if body == player:  # Проверяем, что это игрок
		is_player_near = true  # Игрок находится рядом
		show_element()  # Показываем элемент

# Обработчик выхода
func _on_area_exited(body):
	if body == player:  # Проверяем, что это игрок
		is_player_near = false  # Игрок покидает зону
		hide_element()  # Скрываем элемент
