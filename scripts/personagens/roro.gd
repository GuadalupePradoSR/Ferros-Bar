# mulher_um.gd
extends CharacterBody2D
class_name Player
const SPEED = 130
@onready var anim = $AnimatedSprite2D   # nó de animação do personagem

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	# Captura direções
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	
	# Normaliza para não andar mais rápido na diagonal
	input_vector = input_vector.normalized() 
	
	# Aplica movimento
	velocity = input_vector * SPEED
	move_and_slide()
	
	# Escolhe animação
	if input_vector != Vector2.ZERO:
		if abs(input_vector.x) > abs(input_vector.y):
			if input_vector.x > 0:
				anim.play("walk_right")
			else:
				anim.play("walk_left")
		else:
			if input_vector.y > 0:
				anim.play("walk_down")
			else:
				anim.play("walk_up")
	else:
		anim.stop()
