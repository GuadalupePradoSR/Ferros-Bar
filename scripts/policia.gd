extends CharacterBody2D

var life = 50

@export var star_scene: PackedScene
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func take_damage(amount):
	life -= amount
	print("Policial tomou dano! Vida:", life)

	if life <= 0:
		dead()


func dead():
	velocity = Vector2.ZERO
	$CollisionShape2D.disabled = true
	anim.play("dead")

	# DAR +1 ESTRELA PARA O PLAYER
	give_star_to_player()

	# se quiser soltar estrela física, deixe esta função ativada
	# drop_star()

	await anim.animation_finished
	queue_free()


# ============================================
# DAR ESTRELA DIRETAMENTE PARA HUD
# ============================================
func give_star_to_player():
	var player = get_tree().current_scene.get_node("Player")
	if player:
		player.add_star_to_hud()
	else:
		push_error("Player não encontrado!")


# ============================================
# TOMAR DANO AO ENTRAR NO HITBOX
# ============================================
func _on_hurt_area_area_entered(area: Area2D) -> void:
	if area.name == "AttackArea":
		var damage = area.get_parent().attack_damage
		take_damage(damage)
