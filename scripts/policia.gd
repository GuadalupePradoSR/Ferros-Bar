extends CharacterBody2D

var speed = 55
var player_chase = false
var Player = null

var health = 100
var player_inattack_zone =  false

func _physics_process(delta):
	deal_with_damage()
	if player_chase:
		position += (Player.position - position)/speed
		
		$AnimatedSprite2D.play("combat")
		if(Player.position.x - position.x) < 0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("idle")


func _on_detection_area_body_entered(body: Node2D) -> void:
	Player = body
	player_chase = true


func _on_detection_area_body_exited(body: Node2D) -> void:
	Player = null
	player_chase = false


func _on_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("palyer"):
		player_inattack_zone = true


func _on_enemy_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("palyer"):
		player_inattack_zone = false


func deal_with_damage():
	if player_inattack_zone and global.player_current_attack == true:
		health = health - 20
		print("policia vida", health)
		if health <= 0:
			self.queue_free()
