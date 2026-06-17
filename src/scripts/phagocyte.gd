extends CharacterBody2D
var health : int = 100
var player : CharacterBody2D = null
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var progress_bar : ProgressBar = $ProgressBar
var is_retreating : bool = false
var is_attacking = false
var is_taking_knockback = false
var is_stunned = false
func _ready() -> void:

	player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D




func take_damage(num : int):
	health -= num
	progress_bar.value = health
	print("enemy health " , health)
	take_knockback()

	
func take_knockback() -> void:
	is_taking_knockback = true
	print(is_taking_knockback)
	await get_tree().create_timer(0.2).timeout
	is_taking_knockback = false
	print(is_taking_knockback)
	is_stunned = true
	sprite.play("damaged")
	await get_tree().create_timer(1).timeout
	is_stunned = false
	





func _physics_process(delta: float) -> void:
	if not is_stunned:
		look_at(player.global_position)
	var roll = randf_range(0,1)
	if player == null:
		return
	
	if sprite.is_playing() and sprite.animation == "attack" and not is_attacking and not is_stunned:
		pass
	elif not is_stunned:
		sprite.play("default")
	
	
		
		var direction_to_player = (player.global_position - global_position).normalized()
		if roll < 0.002:
			is_retreating = true
			await get_tree().create_timer(3).timeout
			is_retreating = false
		if not is_retreating and not is_taking_knockback and global_position.distance_to(player.global_position) < 750 and not is_stunned:
			velocity = direction_to_player * randi_range(1000,1100) * delta * 10
		elif is_taking_knockback:
			velocity = direction_to_player * 1000 * -100 * delta
		elif is_retreating:
			velocity = direction_to_player * randi_range(1000,1200) * -10 * delta
		else:
			return
	
		move_and_slide()

	
func _process(delta: float) -> void:
	if health <= 0:
		queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player_take_damage") and not is_stunned:
		is_attacking = true
		sprite.play("attack")
		await get_tree().create_timer(0.05).timeout
		body.player_take_damage(10)
		await get_tree().create_timer(1.0).timeout
		is_attacking = false
