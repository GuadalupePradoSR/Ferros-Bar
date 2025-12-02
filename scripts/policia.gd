# policia.gd

extends CharacterBody2D

signal on_death
var is_dying = false

var life = 10
var speed = 300
var chase_speed = 100
var attack_damage = 25
var attack_range = 30
var attack_cooldown = 1.0
var can_attack = true
var is_chasing = false

var player: Node = null

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $detection_area

enum CombatDir { TOP, LEFT, RIGHT, DOWN }
var combat_dir = CombatDir.DOWN

func _ready():
	add_to_group("enemy")

	player = get_tree().current_scene.find_child("Player", true)
	


	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

func _physics_process(delta):
	if is_dying:
		return
	if not player or player.is_dead():
		velocity = Vector2.ZERO
		play_idle_animation()
		return

	if is_chasing:
		var dir = (player.position - position).normalized()
		velocity = dir * chase_speed
		move_and_slide()

		combat_dir = get_combat_direction(dir)

		if position.distance_to(player.position) <= attack_range:
			attack_player(player)
	else:
		velocity = Vector2.ZERO
		play_idle_animation()

func _on_detection_area_body_entered(body):
	if body == player:
		is_chasing = true

func _on_detection_area_body_exited(body):
	if body == player:
		is_chasing = false
		velocity = Vector2.ZERO

func get_combat_direction(dir):
	if abs(dir.x) > abs(dir.y):
		return CombatDir.RIGHT if dir.x > 0 else CombatDir.LEFT
	else:
		return CombatDir.DOWN if dir.y > 0 else CombatDir.TOP

func attack_player(player_node: Node):
	if not can_attack:
		return

	can_attack = false
	play_attack_animation()

	if player_node.has_method("take_damage"):
		player_node.take_damage(attack_damage)

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func play_attack_animation():
	match combat_dir:
		CombatDir.TOP: anim.play("combat_top")
		CombatDir.LEFT: anim.play("combat_left")
		CombatDir.RIGHT: anim.play("combat_right")
		CombatDir.DOWN: anim.play("combat_down")

func play_idle_animation():
	if anim.animation != "idle":
		anim.play("idle")

func take_damage(amount):
	life -= amount
	print("[ENEMY] Tomou dano:", amount, " | Vida restante:", life)
	if life <= 0:
		dead()

func dead():
	if is_dying:
		return
	is_dying = true
	velocity = Vector2.ZERO
	#collision.disabled = true
	$CollisionShape2D.set_deferred("disabled", true)
	detection_area.monitoring = false
	detection_area.monitorable = false

	anim.play("dead")
	
	on_death.emit()

	if player:
		# Verifica se a função existe para evitar erro
		if player.has_method("add_star_to_hud"):
			player.add_star_to_hud()

	# 3. Esperamos a animação terminar antes de sumir
	await anim.animation_finished 
	queue_free()
