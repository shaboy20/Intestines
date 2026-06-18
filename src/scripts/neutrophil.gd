extends CharacterBody2D
@export var enemy_spawn_scene : PackedScene
var player : CharacterBody2D = null
var speed = 10000
var spawn_cooldown = false;
var health : int = 100;
var bullet_cooldown = false
var is_taking_knockback = false
var paused_movment = false
var is_stunned = false
@onready var collider = $Area2D/CollisionShape2D
@onready var bullet_spawn_scene : PackedScene = preload("res://src/scenes/inter_lukin.tscn")
@onready var progress_bar : ProgressBar = $ProgressBar
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("default")

func _physics_process(delta: float) -> void:
	player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D
	var direction_to_player = (player.global_position - global_position).normalized()
	look_at(player.global_position)
	if paused_movment or is_stunned:
		velocity = Vector2.ZERO	
	if not is_taking_knockback and global_position.distance_to(player.global_position) <= 800 :
		velocity = direction_to_player * speed * delta
	elif is_taking_knockback:
		velocity = direction_to_player * speed * delta * -10
	if global_position.distance_to(player.global_position) < 200 && not spawn_cooldown:
		spawn_enemy(3)
		spawn_cooldown = true
		await get_tree().create_timer(4).timeout
		spawn_cooldown = false
	if global_position.distance_to(player.global_position) <= 740  and global_position.distance_to(player.global_position) >= 200 and not bullet_cooldown:
		bullet_cooldown = true
		pause_movment()
		await get_tree().create_timer(0.1).timeout
		spawn_bullet(1)
		await get_tree().create_timer(3).timeout
		bullet_cooldown = false
		

	move_and_slide()
	


func _process(delta: float) -> void:
	if health <= 0:
		queue_free()
	collider.scale = Vector2(0.2,0.2)
	await get_tree().create_timer(0.01).timeout
	collider.scale = Vector2(1.2,1.2)


func pause_movment():
	is_taking_knockback = true
	await get_tree().create_timer(0.1).timeout
	is_taking_knockback = false
	
func take_damage(num : int):
	health -= num
	progress_bar.value = health
	print("enemy health " , health)
	take_knockback()
	await get_tree().create_timer(1).timeout
	
func take_knockback() -> void:
	sprite.play("damaged")
	is_taking_knockback = true
	print(is_taking_knockback)
	await get_tree().create_timer(0.2).timeout
	is_taking_knockback = false
	sprite.play("default")
	is_stunned = true
	await get_tree().create_timer(1.0).timeout
	is_stunned = false
	print(is_taking_knockback)
	

func spawn_enemy(amount : int):
	for i in range(0,amount):
		var enemy_instance = enemy_spawn_scene.instantiate()
		enemy_instance.global_position = player.global_position + Vector2(randf() * -200, randf() * -200) # Random position within a 800x600 area
		get_tree().current_scene.add_child.call_deferred(enemy_instance)

func spawn_bullet(amount : int):
	for i in range(0,amount):
		var bullet_instance = bullet_spawn_scene.instantiate()
		bullet_instance.global_position = global_position + Vector2(-40,0)
		get_tree().current_scene.add_child.call_deferred(bullet_instance)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player_take_damage"):
		body.player_take_damage(10)
