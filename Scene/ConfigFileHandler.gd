extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		var error = config.save(SETTINGS_FILE_PATH)
		if error != OK:
			print("Ошибка при сохранении файла:", error)
		else:
			print("Файл настроек успешно создан:", SETTINGS_FILE_PATH)
#func _ready():
	#if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		#config.set_value("keybinding", "Left", "A")
		#config.set_value("keybinding", "Left", "Left")
		#config.set_value("keybinding", "Right", "D")
		#config.set_value("keybinding", "Right", "Right")
		#config.set_value("keybinding", "Jump", "space")
		#config.set_value("keybinding", "Jump", "W")
		#config.set_value("keybinding", "Attack", "E")
		#config.set_value("keybinding", "Attack", "mouse_1")
		#config.set_value("keybinding", "Run", "Shift")
		#config.set_value("keybinding", "Block", "Alt")
		#config.set_value("keybinding", "Block", "mouse_2")
		#
		#config.set_value("video", "fullscreen", true)
		#config.set_value("video", "screen_shake", false)
		#
		#config.save(SETTINGS_FILE_PATH)
	#else:
		#config.load(SETTINGS_FILE_PATH)
