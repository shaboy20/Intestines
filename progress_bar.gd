
extends ProgressBar # Or TextureProgressBar / Control

@onready var player = get_node("../Player") # Update this path to match your scene

# Add this offset to make the bar appear above or below the player
@export var offset = Vector2(0, -50) 

func _process(_delta):
	global_position = player.global_position + offset
