extends Control


func _ready():
	ready

func _on_settings_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Main_menu/Main.tscn") #Переход на главное менюФ


func _on_display_mode_1_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN) # Меняем режим отображения на полный экран

func _on_display_mode_2_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) # Меняем режим отображения на оконный


func _on_display_mode_3_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN) # Меняем режим отображения на окно без рамки	


func _on_sound_yes_pressed() -> void:
	ready


func _on_sound_no_pressed() -> void:
	ready


func center_window(new_resolution: Vector2):
	var screen_size: Vector2 = DisplayServer.screen_get_size(0)  # Получаем размер экрана как Vector2
	print("Screen size: ", screen_size)
	var new_position: Vector2 = (screen_size - new_resolution) / 2  # Выполняем вычитание для центрирования окна
	DisplayServer.window_set_position(new_position)  # Устанавливаем новую позицию окна


func _on_resolution_1_pressed() -> void:
	var new_resolution: Vector2 = Vector2(1280, 720)  # Устанавливаем новое разрешение
	DisplayServer.window_set_size(new_resolution)  # Изменяем размер окна
	await get_tree().create_timer(0.1).timeout  # Ждем немного, чтобы изменения вступили в силу
	center_window(new_resolution)  # Центрируем окно


func _on_resolution_2_pressed() -> void:
	var new_resolution: Vector2 = Vector2(1920, 1080)  # Устанавливаем новое разрешение
	DisplayServer.window_set_size(new_resolution)  # Изменяем размер окна
	await get_tree().create_timer(0.1).timeout  # Ждем немного, чтобы изменения вступили в силу
	center_window(new_resolution)  # Центрируем окно


func _on_resolution_3_pressed() -> void:
	var new_resolution: Vector2 = Vector2(2560, 1440)  # Устанавливаем новое разрешение
	DisplayServer.window_set_size(new_resolution)  # Изменяем размер окна
	await get_tree().create_timer(0.1).timeout  # Ждем немного, чтобы изменения вступили в силу
	center_window(new_resolution)  # Центрируем окно
