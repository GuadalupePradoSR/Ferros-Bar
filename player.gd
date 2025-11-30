extends CharacterBody2D

var speed = 200
var is_attacking = false
var attack_damage = 10

@onready var attack_area = $AttackArea
@onready var anim = $AnimationPlayer

# última direção usada
var last_dir := Vector2.DOWN


func _physics_process(delta):
	movement()

	# Ataque
	if Input.is_action_just_pressed("attack"):
		attack()

	# Animação de movimento (sem idle)
	if not is_attacking:
		update_walk_animation()


# =====================================================
# MOVIMENTO
# =====================================================
func movement():
	var dir = Vector2.ZERO

	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity = dir.normalized() * speed

	if dir != Vector2.ZERO:
		last_dir = dir  # salva direção

	move_and_slide()


# =====================================================
# ANIMAÇÃO DE WALK (quando parado não toca nada)
# =====================================================
func update_walk_animation():
	# Se parado, não toca idle, apenas congela no frame
	if velocity == Vector2.ZERO:
		return

	# Movimento horizontal
	if abs(last_dir.x) > abs(last_dir.y):
		if last_dir.x > 0:
			anim.play("walk_right")
		else:
			anim.play("walk_left")
	else:
		# Movimento vertical
		if last_dir.y > 0:
			anim.play("walk_down")
		else:
			anim.play("walk_up")


# =====================================================
# ATAQUE DIRECIONAL
# =====================================================
func attack():
	if is_attacking:
		return

	is_attacking = true
	attack_area.monitoring = true

	anim.play(get_attack_animation())

	await anim.animation_finished

	attack_area.monitoring = false
	is_attacking = false


func get_attack_animation() -> String:
	if abs(last_dir.x) > abs(last_dir.y):
		if last_dir.x > 0:
			return "attack_right"
		else:
			return "attack_left"
	else:
		if last_dir.y > 0:
			return "attack_down"
		else:
			return "attack_up"


func add_star_to_hud():
	var hud = get_tree().current_scene.get_node("Hud")
	if hud:
		hud.add_star()
	else:
		push_error("HUD não encontrada!")
		
func _ready():
	print(get_tree().current_scene.get_children())
