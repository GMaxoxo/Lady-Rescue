extends Control

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Level_1/level.tscn")


func _on_load_game_pressed() -> void:
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Main_menu/settings_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Main_menu/Sure.tscn")
