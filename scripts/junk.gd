extends CharacterBody2D
class_name Junk

@export var health: int = 10
@export var C_SPEED = 100.0
@export var T_SPEED = 200.0

func _physics_process(_shit) -> void:
	var target_pos := Vector2.ZERO; 
	var my_pos = self.position; 
	var direction = target_pos - my_pos
	# Calculate angle to target
	var angle_to_target := atan2(direction.y, direction.x)
	var perpendicular_angle := atan2(direction.y, direction.x) + PI/2
	# Set velocity based on angle
	
	velocity.x = C_SPEED * cos(angle_to_target) + T_SPEED * cos(perpendicular_angle)
	velocity.y = C_SPEED * sin(angle_to_target) + T_SPEED * sin(perpendicular_angle)

	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
