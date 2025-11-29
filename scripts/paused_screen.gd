extends CanvasLayer

<<<<<<< HEAD
func _ready() -> void:
	visible = false
=======
@onready var menu = $Menu
@onready var options = $Options
@onready var video = $Video
@onready var audio = $Audio
@onready var full_screen_check = $Video/MarginContainer/HBoxContainer/Checks/FullScreen
@onready var borderless_check = $Video/MarginContainer/HBoxContainer/Checks/BorderLess
@onready var vsync_check = $Video/MarginContainer/HBoxContainer/Checks/VSync


func _ready() -> void:
	visible = false
	# Atualiza o estado inicial dos botões conforme a janela atual
	var window := get_window()
	full_screen_check.button_pressed = window.mode == Window.MODE_FULLSCREEN
	borderless_check.button_pressed = window.borderless
	vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
>>>>>>> livia

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
	

func _on_bnt_continue_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_bnt_options_pressed() -> void:
<<<<<<< HEAD
	#Criar as opções
	pass # Replace with function body.


func _on_bnt_quit_pressed() -> void:
	get_tree().quit()
=======
	show_and_hide(options, menu)

func show_and_hide(frist, second) -> void:
	frist.show()
	second.hide()

func _on_bnt_quit_pressed() -> void:
	get_tree().quit()


func _on_bnt_video_pressed() -> void:
	show_and_hide(video, options)


func _on_bnt_audio_pressed() -> void:
	
	show_and_hide(audio, options)


func _on_bnt_back_options_pressed() -> void:
	show_and_hide(menu, options)


func _on_bnt_back_video_pressed() -> void:
	show_and_hide(options, video)


func _on_bnt_back_audio_pressed() -> void:
	show_and_hide(options, audio)

func _on_full_screen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_border_less_toggled(toggled_on):
	var window := get_window()
	window.borderless = toggled_on


func _on_v_sync_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
>>>>>>> livia
