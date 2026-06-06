extends CharacterBody2D


const SPEED = 300.0


func _physics_process(_shit) -> void:
	var target_pos := Vector2.ZERO; 
	var my_pos = self.position; 
	var direction = target_pos - my_pos

	# Calculate angle to target
	var angle_to_target := atan2(direction.y, direction.x)
	# Set velocity based on angle
	velocity.x = SPEED * cos(angle_to_target)
	velocity.y = SPEED * sin(angle_to_target)

	move_and_slide()
