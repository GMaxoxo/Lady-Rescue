extends Control


func _ready():
	ready

func _on_settings_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Main_menu/Main.tscn")


func _on_display_mode_1_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)


func _on_display_mode_2_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_display_mode_3_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_sound_yes_pressed() -> void:
	ready


func _on_sound_no_pressed() -> void:
	ready
