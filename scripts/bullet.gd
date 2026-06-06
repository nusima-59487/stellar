extends CharacterBody2D
class_name Bullet

@export var damage: int = 10
@export var speed := 300

const MAX_POINTS := 14

var _life := 1.6
var _dead := false
var _trail: Line2D
var _points := PackedVector2Array()


func _ready() -> void:
	collision_layer = 2          # Projectiles
	collision_mask = 0
	var area = get_node_or_null("Detection Area2D")
	if area:
		area.collision_layer = 2
		area.collision_mask = 8  # detect Junk
	var spr = get_node_or_null("Sprite2D")
	if spr:
		spr.modulate = FX.C_BULLET
	_make_trail()
	velocity = Vector2.RIGHT.rotated(rotation) * speed


func _make_trail() -> void:
	_trail = Line2D.new()
	_trail.width = 8.0
	_trail.z_index = 3
	_trail.joint_mode = Line2D.LINE_JOINT_ROUND
	_trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	_trail.end_cap_mode = Line2D.LINE_CAP_ROUND
	var wc := Curve.new()
	wc.add_point(Vector2(0.0, 0.05))
	wc.add_point(Vector2(1.0, 1.0))
	_trail.width_curve = wc
	var g := Gradient.new()
	g.set_color(0, Color(FX.C_BULLET.r, FX.C_BULLET.g, FX.C_BULLET.b, 0.0))
	g.set_color(1, FX.C_BULLET)
	_trail.gradient = g
	get_parent().add_child(_trail)


func _physics_process(delta: float) -> void:
	if _dead:
		return
	_life -= delta
	move_and_slide()
	_update_trail()
	if _life <= 0.0:
		_die()


func _update_trail() -> void:
	if _trail == null:
		return
	_points.append(global_position)
	while _points.size() > MAX_POINTS:
		_points.remove_at(0)
	_trail.points = _points


func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if _dead:
		return
	if body is Junk:
		body.take_damage(damage)
		GameManager.add_xp(damage)
		FX.burst(get_parent(), global_position, FX.C_HIT, 10, 190.0, 0.35, 4.0)
		FX.ring(get_parent(), global_position, FX.C_HIT, 24.0, 0.18, 3.0, true)
		GameManager.request_shake(0.06)
		_die()


func _die() -> void:
	if _dead:
		return
	_dead = true
	_fade_trail()
	queue_free()


# Hand the trail off to its own fade-out tween so it lingers after the bullet dies.
func _fade_trail() -> void:
	if _trail and is_instance_valid(_trail):
		var tw := _trail.create_tween()
		tw.tween_property(_trail, "modulate:a", 0.0, 0.2)
		tw.tween_callback(_trail.queue_free)
		_trail = null
