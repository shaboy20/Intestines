extends CharacterBody2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var timer_allready_set = false

func _ready() -> void:
	sprite.play("default")

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO


func _process(delta: float) -> void:
	if not timer_allready_set:
		timer_allready_set =  true
		await get_tree().create_timer(5).timeout
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("player_take_damage"):
		body.player_take_damage(10)
		queue_free()

