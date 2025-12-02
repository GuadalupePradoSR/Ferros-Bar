extends CharacterBody2D

var last_hit_time: float = 0.0
var speed = 150
var is_attacking = false
var attack_damage = 20
var out_of_combat_time = 10.0
var life_max = 100
var dead := false

@onready var attack_area: Area2D = $AttackArea
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var last_dir := Vector2.DOWN

func is_dead(): 
	return dead

func _ready():
	attack_area.monitoring = false

func _physics_process(delta):
	if dead:
		velocity = Vector2.ZERO
		return

	movement()

	if Input.is_action_just_pressed("attack"):
		attack()

	if not is_attacking:
		update_walk_or_idle_animation()

	# regen
	if Time.get_ticks_msec() / 1000.0 - last_hit_time >= out_of_combat_time:
		recover_health(20)
		last_hit_time = Time.get_ticks_msec() / 1000.0

# =====================================================
# ATAQUE
# =====================================================
func attack() -> void:
	if is_attacking or dead:
		return

	is_attacking = true
	attack_area.monitoring = true

	anim.play(get_attack_animation())
	await anim.animation_finished

	var bodies = attack_area.get_overlapping_bodies()

	for b in bodies:
		if b.is_in_group("enemy") and b.has_method("take_damage"):
			b.take_damage(attack_damage)

	attack_area.monitoring = false
	is_attacking = false

func get_attack_animation() -> String:
	if abs(last_dir.x) > abs(last_dir.y):
		return "attack_right" if last_dir.x > 0 else "attack_left"
	else:
		return "attack_down" if last_dir.y > 0 else "attack_up"

# =====================================================
# MOVIMENTO
# =====================================================
func movement() -> void:
	if dead:
		return

	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	velocity = dir.normalized() * speed

	if dir != Vector2.ZERO:
		last_dir = dir

	move_and_slide()

# =====================================================
# ANIMAÇÃO WALK / IDLE
# =====================================================
func update_walk_or_idle_animation() -> void:
	if velocity != Vector2.ZERO:
		if abs(last_dir.x) > abs(last_dir.y):
			anim.play("walk_right" if last_dir.x > 0 else "walk_left")
		else:
			anim.play("walk_down" if last_dir.y > 0 else "walk_up")
		return

	if anim.animation != "idle":
		anim.play("idle")

# =====================================================
# VIDA / DANO / MORTE
# =====================================================
func take_damage(amount: int) -> void:
	if dead:
		return

	var hud = get_tree().get_current_scene().find_child("Hud", true)
	hud.update_life(hud.current_life - amount)

	last_hit_time = Time.get_ticks_msec() / 1000.0

	if hud.current_life <= 0:
		die()

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	anim.play("dead")
	await anim.animation_finished

	var hud = get_tree().get_current_scene().find_child("Hud", true)
	if hud:
		hud.show_retry()

func recover_health(amount: int) -> void:
	if dead:
		return
		
	var hud = get_tree().get_current_scene().find_child("Hud", true)
	hud.update_life(hud.current_life + amount)

# ======================
# ADD STAR
# ======================
func add_star_to_hud() -> void:
	var hud = get_tree().get_current_scene().find_child("Hud", true)
	if hud:
		hud.add_star()
