extends CharacterBody2D


var SPEED = 20300.0
const JUMP_VELOCITY = -400.0
var is_taking_knockback = false
var is_in_cooldown : bool = false
var attack_count : int = 0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var progress_bar : TextureProgressBar = $CanvasLayer/TextureProgressBar
@onready var area_2d : CollisionShape2D = $Area2D/CollisionShape2D
@onready var cooldown_bar : ProgressBar = $CanvasLayer/ProgressBar
var entered_body = null
var timer_not_allready_created : bool = false
var is_attacking = false;
var health = 100
var is_dashing = false
var iframes = false
func _ready():
	var screen_height = get_viewport().get_visible_rect().size.x
	var screen_base = get_viewport().get_visible_rect().size.y


func player_take_damage(damage:int):
	if not is_attacking && not is_taking_knockback and not iframes:
		is_taking_knockback = true
		health -= damage
		progress_bar.value = health
		print(health)
		await get_tree().create_timer(0.5).timeout
		is_taking_knockback = false
	else:
		return
		
func set_attack_cooldown():
	if attack_count % 2 == 0:
		cooldown_bar.value = 100
		is_in_cooldown = true
		var tween = create_tween()
		tween.tween_property(cooldown_bar , "value",0.0,1.0)
		await get_tree().create_timer(1.0).timeout
		is_in_cooldown = false
	else:
		cooldown_bar.value = 100
		is_in_cooldown = true
		var tween = create_tween()
		tween.tween_property(cooldown_bar , "value",0.0,0.2)
		await get_tree().create_timer(0.2).timeout
		is_in_cooldown = false
		
func set_iframes(time : float):
	iframes = true
	await get_tree().create_timer(time).timeout
	iframes = false

func _physics_process(delta: float) -> void:
	progress_bar.value = health
	if Input.is_action_pressed("rotate_left") and not is_attacking:
		rotation_degrees -= 180 * delta;
	if Input.is_action_pressed("rotate_right") and not is_attacking:
		rotation_degrees += 180 * delta;
	var forward_vector = Vector2.RIGHT.rotated(rotation)
	if Input.is_action_pressed("move_forward") and not is_attacking:
		velocity = forward_vector * SPEED * delta
	else:
		velocity = Vector2.ZERO
		

	if is_taking_knockback:
		velocity = -forward_vector * SPEED * 2 * delta
	if is_dashing and not is_taking_knockback:
		velocity = forward_vector * SPEED * 2 * delta
	
	
	if health <= 0:
		queue_free()
		
	move_and_slide()



func _process(_delta: float) -> void:
	if not health >= 100 &&  not timer_not_allready_created:
		timer_not_allready_created = true
		await get_tree().create_timer(10).timeout
		timer_not_allready_created = false
		health += 10

	if Input.is_action_just_pressed("attack"):
		if is_in_cooldown:
			return
		else:
			attack_count += 1
			set_attack()
			dash()

			set_attack_cooldown()
	if is_attacking:
		sprite.play("attack")
	else:
		sprite.play("default")

func set_attack():
	is_attacking = true
	area_2d.scale = Vector2(1,1)	
	await get_tree().create_timer(0.5).timeout
	area_2d.scale = Vector2(0.2,0.2)
	is_attacking = false
	set_iframes(0.3)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body.has_method("take_damage") && is_attacking:
		body.take_damage(20)
	if body.has_method("take_knockback") && is_attacking:
		body.take_knockback()

	
func dash():
	is_dashing = true
	await get_tree().create_timer(0.3).timeout
	is_dashing = false

func _on_area_2d_body_exited(body: Node2D) -> void:
	pass
