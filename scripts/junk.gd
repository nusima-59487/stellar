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

func break_junk() -> void:
	if self.stage == 2:
		queue_free()
	else:
		queue_free()
		var JUNK1 = preload("res://scenes/junk.tscn")
		var junk_instance1 = JUNK1.instantiate()
		junk_instance1.position = self.position + Vector2(2, 2)
		junk_instance1.rotation = self.rotation - PI/2
		junk_instance1.stage = self.stage + 1
		get_tree().current_scene.call_deferred("add_child", junk_instance1)
		# add_sibling(junk_instance1)
		# set_deferred("add_sibling", junk_instance1)
		
		var JUNK = preload("res://scenes/junk.tscn")
		var junk_instance = JUNK.instantiate()
		junk_instance.position = self.position + Vector2(-2, -2)
		junk_instance.rotation = self.rotation - PI/2
		junk_instance.stage = self.stage + 1
		get_tree().current_scene.call_deferred("add_child", junk_instance)
		# add_sibling(junk_instance)
		# set_deferred("add_sibling", junk_instance)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		print("I ran into myself!")
	elif body.has_method("break_junk"):
		print(body.stage, self.stage)
		break_junk()
		
