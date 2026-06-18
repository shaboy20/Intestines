extends CharacterBody2D
@export var speed = 10000.0
var player: CharacterBody2D  = null# Drag your player node here
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var progress_bar : ProgressBar = $ProgressBar
var is_dying : bool = false
var health : int = 50
var is_stunned : bool = false
var player_in_collider = null
var is_reatreating = false
var is_taking_knockback : bool = false
var is_attacking = false
var paused_movment = false
func _physics_process(delta):
	if is_dying:
		pass
	else:
		var roll = randf_range(0,1)
		if is_attacking:
			sprite.play("attack")
		else:
			sprite.play("default")
		player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D
		if player && global_position.distance_to(player.global_position) < 750:
			var direction = (player.global_position - global_position).normalized()
			if roll < 0.002:
				is_reatreating = true
				await get_tree().create_timer(2).timeout
				is_reatreating = false
			if is_reatreating:
				velocity = direction * speed * -1 * delta
				if not is_stunned and not paused_movment:
					move_and_slide()
			else:
				velocity = direction * speed * delta
				if not is_stunned and not paused_movment:
					move_and_slide()
		
			if is_taking_knockback:
				velocity = -direction * speed * 10 * delta
				move_and_slide()

			if paused_movment:
				pass

		if global_position.distance_to(player.global_position) < 50 and not is_stunned:
			sprite.play("attack")


func _process(delta: float) -> void:
	if health <= 0 and not is_dying:
		player.health += 1
		is_dying = true
		sprite.play("death")
		await get_tree().create_timer(1).timeout
		queue_free()

func take_damage(num : int):
	health -= num
	progress_bar.value = health
	is_stunned = true
	print("enemy health " , health)
	await get_tree().create_timer(1).timeout
	is_stunned = false
	
func take_knockback() -> void:
	is_taking_knockback = true
	await get_tree().create_timer(0.2).timeout
	is_taking_knockback = false
	
func pause_move_and_slide():
	paused_movment = true
	await get_tree().create_timer(0.5).timeout
	paused_movment = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	sprite.play("attack")
	if body.has_method("player_take_damage") and not is_stunned && not is_dying:
		body.player_take_damage(10)
		pause_move_and_slide()
		is_attacking = true
		await get_tree().create_timer(1.0).timeout
		is_attacking = false
