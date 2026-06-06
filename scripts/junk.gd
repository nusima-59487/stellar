extends CharacterBody2D
class_name Junk


var all_stage = ["big","med","smol"]

@export var health: int = 10
@export var stage: int = 0
@export var C_SPEED = 100.0
@export var T_SPEED = 200.0

func _physics_process(_shit) -> void:
	$AnimatedSprite2D.animation = all_stage[stage]
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
		break_junk()
		health = 10
	if health <= 0 && stage ==2:
		queue_free()

func break_junk() -> void:
	var JUNK = preload("res://scenes/junk.tscn")
	var junk_instance = JUNK.instantiate()
	junk_instance.position = self.position
	junk_instance.rotation = self.rotation - PI/2
	if junk_instance.stage + 1 < 3:
		junk_instance.stage += 1
	if stage + 1 < 3:
		stage += 1
	call_deferred("add_sibling", junk_instance)
	




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("break"):
		body.break_junk()
		
		
