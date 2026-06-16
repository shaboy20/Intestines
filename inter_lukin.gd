extends CharacterBody2D
@export var enemy_spawn_scene : PackedScene
var player : CharacterBody2D = null
var timer_allready_set = false
var direction_allready_set = false
var bullet_age = 0.0
func _physics_process(delta: float) -> void:
	player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D
	if not direction_allready_set:
		look_at(player.global_position)
		rotation_degrees += 270	
		direction_allready_set = true
		var direction_to_player = (player.global_position - global_position).normalized()
		velocity = direction_to_player * 30000 * delta
	else:
		velocity = velocity
	move_and_slide()


func _process(delta: float) -> void:
	bullet_age += delta
	if not timer_allready_set:
		timer_allready_set = true
		await get_tree().create_timer(5).timeout
		queue_free()

func spawn_enemy(amount : int):
	for i in range(0,amount):
		var enemy_instance = enemy_spawn_scene.instantiate()
		enemy_instance.global_position = player.global_position + Vector2(randf() * 200, randf() * 200) # Random position within a 800x600 area
		get_tree().current_scene.add_child.call_deferred(enemy_instance)




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player_take_damage"):
		body.player_take_damage(10)
		spawn_enemy(randi_range(1,2))
		queue_free()
	if bullet_age >= 1.0:
		queue_free()

