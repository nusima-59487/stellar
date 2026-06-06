extends CharacterBody2D

const MAX_SPEED := 470.0
const ACCEL := 8.0
const DECEL := 6.0

@export var xp: int = 0  # kept for compatibility; xp now lives in GameManager

const BULLET := preload("res://scenes/bullet.tscn")

const TRAUMA_DECAY := 1.5
var trauma := 0.0

var _cam: Camera2D
var _thruster: CPUParticles2D
var _fire_cd := 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1   # Player
	collision_mask = 0    # passes through everything; defence is Earth's job
	_cam = get_node_or_null("Camera2D") as Camera2D
	_make_thruster()


func _make_thruster() -> void:
	_thruster = CPUParticles2D.new()
	_thruster.amount = 36
	_thruster.lifetime = 0.45
	_thruster.local_coords = false
	_thruster.emitting = false
	_thruster.spread = 14.0
	_thruster.gravity = Vector2.ZERO
	_thruster.initial_velocity_min = 70.0
	_thruster.initial_velocity_max = 140.0
	_thruster.scale_amount_min = 1.5
	_thruster.scale_amount_max = 3.5
	_thruster.z_index = -1
	var g := Gradient.new()
	g.set_color(0, Color(1.6, 2.2, 3.0, 1.0))
	g.set_color(1, Color(0.3, 0.7, 2.0, 0.0))
	_thruster.color_ramp = g
	add_child(_thruster)


func _physics_process(delta: float) -> void:
	_fire_cd = maxf(0.0, _fire_cd - delta)

	var input := Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	)
	if input.length() > 1.0:
		input = input.normalized()

	var target := input * MAX_SPEED
	var rate := ACCEL if input != Vector2.ZERO else DECEL
	velocity = velocity.move_toward(target, MAX_SPEED * rate * delta)

	var joy := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if joy.length() > 0.2:
		rotation = lerp_angle(rotation, joy.angle(), 0.35)
	elif Input.get_last_mouse_velocity().length() > 0.2:
		var aim := (get_global_mouse_position() - global_position).angle()
		rotation = lerp_angle(rotation, aim, 0.4)

	move_and_slide()

	var moving := velocity.length() > 40.0
	_thruster.emitting = moving
	if moving:
		var back := -Vector2.RIGHT.rotated(rotation)
		_thruster.global_position = global_position + back * 18.0
		_thruster.direction = back

	if Input.is_action_pressed("fire") and _fire_cd <= 0.0:
		_fire()


func _fire() -> void:
	_fire_cd = GameManager.bullet_fire_cooldown
	var streams := maxi(1, GameManager.bullet_streams_count)
	var spread := deg_to_rad(8.0)
	var start := -spread * (streams - 1) / 2.0
	var muzzle := global_position + Vector2.RIGHT.rotated(rotation) * 24.0
	for i in range(streams):
		var b = BULLET.instantiate()
		b.global_position = muzzle
		b.rotation = rotation + start + spread * i
		b.damage = GameManager.bullet_damage
		b.speed = GameManager.bullet_speed
		get_parent().add_child(b)
	# muzzle juice
	FX.ring(get_parent(), muzzle, FX.C_BULLET, 18.0, 0.15, 3.0, true)
	FX.burst(get_parent(), muzzle, FX.C_BULLET, 6, 130.0, 0.22, 3.0)
	velocity -= Vector2.RIGHT.rotated(rotation) * 55.0  # recoil kick
	add_trauma(0.1)


func _process(delta: float) -> void:
	if _cam == null:
		return
	if trauma > 0.0:
		trauma = maxf(0.0, trauma - TRAUMA_DECAY * delta)
		var amt := trauma * trauma  # quadratic falloff feels punchier
		# offset shake (Camera2D.ignore_rotation defaults true, so we don't rotate it)
		_cam.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * amt * 26.0
	elif _cam.offset != Vector2.ZERO:
		_cam.offset = Vector2.ZERO


func add_trauma(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)
