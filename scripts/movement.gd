extends CharacterBody2D


const SPEED = 15.0
const DECELERATION_RATE = 4.5

const BULLET = preload("res://bullet.tscn")

func _physics_process(delta: float) -> void:
	
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("player_left", "player_right")
	var direction_y := Input.get_axis("player_up", "player_down")
	if direction_x:
		velocity.x += direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/DECELERATION_RATE)
	if direction_y:
		velocity.y += direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED/DECELERATION_RATE)
		
	look_at(get_global_mouse_position())
	rotation_degrees += (90)

	move_and_slide()

	if Input.is_action_just_pressed("fire"): 
		var bullet_instance = BULLET.instantiate()
		bullet_instance.position = self.position
		bullet_instance.rotation = self.rotation - PI/2
		add_sibling(bullet_instance)
		
