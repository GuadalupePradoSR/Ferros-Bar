# mulher_um.gd
extends CharacterBody2D
class_name Player
const SPEED = 130
@onready var anim = $AnimatedSprite2D   # nó de animação do personagem

var policia_inattack_range = false
var policia_attack_cooldown = true
var health = 100
var player_alive = true

var attack_ip = false

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	policia_attack()
	attack()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("palyer morreu")
		self.queue_free()
	
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

func Player():
	pass

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("policia"):
		policia_inattack_range = true


func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("policia"):
		policia_inattack_range = false

func policia_attack():
	if policia_inattack_range and policia_attack_cooldown == true:
		health = health - 20
		policia_attack_cooldown = false
		$attack_cooldown.start()
		print(health)


func _on_attack_cooldown_timeout() -> void:
	policia_attack_cooldown = true

func attack():
	
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("combate")
