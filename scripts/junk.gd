extends CharacterBody2D
class_name Junk

var all_stage := ["big", "med", "smol"]
var all_hp := [10, 5, 2]
var stage_scale := [1.25, 0.95, 0.65]
var stage_colors := [Color(1.4, 1.05, 0.7), Color(1.2, 1.1, 0.95), Color(0.95, 1.2, 1.35)]

var hitbox_ready := false
var _dead := false

@export var health: int = 10
@export var stage: int = 0
@export var dir := true
@export var C_SPEED := 40.0
@export var T_SPEED := 130.0

var launch := Vector2.ZERO  # transient outward impulse from a cascade split
var spin := 0.0
var _sprite: AnimatedSprite2D

const JUNK := preload("res://scenes/junk.tscn")


func _ready() -> void:
	collision_layer = 8          # Junk
	collision_mask = 0
	var area = get_node_or_null("Area2D")
	if area:
		area.collision_layer = 8
		area.collision_mask = 8  # detect other Junk for the cascade chain
	_sprite = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if _sprite:
		_sprite.animation = all_stage[stage]
		_sprite.modulate = stage_colors[stage]
	health = all_hp[stage]
	var mult: float = GameManager.junk_speed_multiplier
	C_SPEED *= mult
	T_SPEED *= mult
	spin = randf_range(-2.5, 2.5)

	# Pop-in: scale the whole body (so the hitbox grows with it) from 0 with overshoot.
	var tgt := Vector2(stage_scale[stage], stage_scale[stage])
	scale = Vector2.ZERO
	var tw := create_tween()
	tw.tween_property(self, "scale", tgt, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(0.3).timeout  # brief spawn invincibility
	hitbox_ready = true


func _physics_process(delta: float) -> void:
	if _dead:
		return
	if _sprite:
		_sprite.rotation += spin * delta

	# Curved orbital approach: speed toward Earth plus a tangential component.
	var to_center := -position
	var ang := to_center.angle()
	var perp := ang + PI / 2.0
	var base := Vector2.ZERO
	if dir:
		base.x = C_SPEED * cos(ang) + T_SPEED * cos(perp)
		base.y = C_SPEED * sin(ang) + T_SPEED * sin(perp)
	else:
		base.x = C_SPEED * cos(ang) - T_SPEED * cos(perp)
		base.y = C_SPEED * sin(ang) - T_SPEED * sin(perp)
	velocity = base + launch
	launch = launch.move_toward(Vector2.ZERO, 700.0 * delta)
	move_and_slide()


func take_damage(amount: int) -> void:
	if _dead:
		return
	health -= amount
	_flash()
	if health <= 0:
		break_junk()


func _flash() -> void:
	if _sprite == null:
		return
	_sprite.modulate = Color(4.0, 4.0, 4.0)
	var tw := create_tween()
	tw.tween_property(_sprite, "modulate", stage_colors[stage], 0.18)


func break_junk() -> void:
	if _dead:
		return
	_dead = true
	var scene := get_tree().current_scene
	var amt := 28 - stage * 6
	FX.burst(scene, global_position, FX.C_EXPLODE, amt, 250.0 - stage * 40.0, 0.6, 7.0 - stage * 1.5)
	FX.burst(scene, global_position, Color(3.0, 3.0, 3.0), int(amt / 2), 330.0, 0.28, 3.0)
	FX.ring(scene, global_position, FX.C_EXPLODE, 70.0 - stage * 15.0, 0.4, 5.0)
	GameManager.request_shake(0.18 - stage * 0.04)
	if stage < 2:
		_spawn_children(scene)
	queue_free()


func _spawn_children(scene: Node) -> void:
	var child_stage := stage + 1
	var out := position.normalized()
	for s in [1.0, -1.0]:
		var inst = JUNK.instantiate()
		inst.position = position + Vector2(3, 3) * s
		inst.stage = child_stage
		inst.dir = s > 0.0
		inst.launch = out.rotated(PI / 2.0 * s) * 230.0  # burst the halves apart
		scene.call_deferred("add_child", inst)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _dead:
		return
	if body is Junk and hitbox_ready and body.hitbox_ready:
		break_junk()
