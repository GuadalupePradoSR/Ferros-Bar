extends Control


func _on_bnt_start_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/cutscenes/rua_do_bar.tscn")


func _on_bnt_credits_pressed() -> void:
	#cria cena de creditos
	pass # Replace with function body.


func _on_bnt_quit_pressed() -> void:
	get_tree().quit()
