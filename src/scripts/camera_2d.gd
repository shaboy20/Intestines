extends Camera2D
var player : CharacterBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player = get_tree().current_scene.find_child("Player", true, false) as CharacterBody2D 
	global_position = global_position.lerp(player.position , delta * 3)
