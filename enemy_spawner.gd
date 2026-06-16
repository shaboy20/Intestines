extends Node2D


@export var enemy_spawn_scene: PackedScene
@export var spawn_amount : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_enemy(spawn_amount)


func spawn_enemy(amount : int):
	for i in range(0,amount):
		var enemy_instance = enemy_spawn_scene.instantiate()
		enemy_instance.position = Vector2(randf() * 200, randf() * 20) # Random position within a 800x600 area
		add_child(enemy_instance)
