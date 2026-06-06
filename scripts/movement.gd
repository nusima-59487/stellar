extends CharacterBody2D


const SPEED = 15.0
const DECELERATION_RATE = 4.5

@export var xp: int = 0

const BULLET = preload("res://scenes/bullet.tscn")

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
		
	var joy_dir := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	# Check if the stick is being pushed past a small deadzone threshold
	if joy_dir.length() > 0.2:
		rotation = joy_dir.angle()
	elif Input.get_last_mouse_velocity().length() > 0.2: 
		look_at(get_global_mouse_position())

	move_and_slide()

	if Input.is_action_just_pressed("fire"): 
		if GameInstance.bullet_sterams_count == 2:
			self._fire_bullet(Vector2(0, 10))
			self._fire_bullet(Vector2(0, -10)) 
		elif GameInstance.bullet_sterams_count == 3: 
			self._fire_bullet(Vector2(0, 20))
			self._fire_bullet(Vector2.ZERO)
			self._fire_bullet(Vector2(0, -20)) 
		else: # 1 or fallback
			self._fire_bullet(Vector2.ZERO)

func pause_object_temporarily():
	set_process(false)
	await get_tree().create_timer(2.0).timeout
	set_process(true)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		pause_object_temporarily()
		velocity.x = -0.5 * velocity.x
		velocity.y = -0.5 * velocity.y


func _fire_bullet(pos_diff: Vector2) -> void: 
	var bullet_instance = BULLET.instantiate()
	bullet_instance.position = self.position + pos_diff.rotated(self.rotation)
	bullet_instance.rotation = self.rotation
	add_sibling(bullet_instance)
