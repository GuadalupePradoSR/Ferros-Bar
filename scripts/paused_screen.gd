extends CanvasLayer

func _ready() -> void:
	visible = false

func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
	

func _on_bnt_continue_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_bnt_options_pressed() -> void:
	#Criar as opções
	pass # Replace with function body.


func _on_bnt_quit_pressed() -> void:
	get_tree().quit()
