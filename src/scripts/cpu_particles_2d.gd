
extends CPUParticles2D

func _ready() -> void:
	# Start emitting immediately when spawned
	emitting = true
	
	# Wait for the particles to finish, then delete the whole system
	# 'owner' refers to the root "Particles" Node2D scene
	await get_tree().create_timer(lifetime + 0.2).timeout
	
	if owner:
		owner.queue_free() # Deletes the whole scene structure
	else:
		queue_free() # Fallback backup
