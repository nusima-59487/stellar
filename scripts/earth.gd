extends StaticBody2D
class_name Earth

@export var hp: int = 80
var max_hp := 80
var _dead := false
var _sprite: Sprite2D

@onready var hp_overlay = $"../HpOverlay"


func _ready() -> void:
	collision_layer = 4          # Earth
	collision_mask = 0
	var area = get_node_or_null("Area2D")
	if area:
		area.collision_layer = 4
		area.collision_mask = 8  # detect Junk
	max_hp = hp
	GameManager.earth_health = hp
	_sprite = get_node_or_null("Sprite2D") as Sprite2D
	await hp_overlay.ready
	hp_overlay.update(hp, max_hp)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _dead:
		return
	if body is Junk:
		var jpos: Vector2 = body.global_position
		hp = maxi(0, hp - body.health)
		hp_overlay.update(hp, max_hp)
		_impact(jpos)
		# Consume the junk (no split into Earth — keeps damage fair).
		FX.burst(get_tree().current_scene, jpos, FX.C_EXPLODE, 16, 200.0, 0.5, 5.0)
		body.queue_free()
		if hp <= 0:
			_destroy()


func _impact(pos: Vector2) -> void:
	GameManager.request_shake(0.35)
	var scene := get_tree().current_scene
	FX.burst(scene, pos, FX.C_EARTH, 22, 260.0, 0.6, 6.0)
	FX.ring(scene, pos, FX.C_EARTH, 80.0, 0.45, 5.0)
	FX.ring(scene, global_position, FX.C_SHIELD, 230.0, 0.5, 5.0)  # shield ripple
	if _sprite:
		_sprite.modulate = Color(3.0, 1.2, 0.9)
		var tw := create_tween()
		tw.tween_property(_sprite, "modulate", Color(1, 1, 1), 0.3)


func _destroy() -> void:
	if _dead:
		return
	_dead = true
	var scene := get_tree().current_scene
	# Staggered death blast.
	for i in range(6):
		var off := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * 130.0
		FX.burst(scene, global_position + off, FX.C_EXPLODE, 40, 360.0, 1.0, 9.0)
	FX.ring(scene, global_position, Color(3.0, 2.0, 1.0), 420.0, 0.8, 12.0)
	GameManager.request_shake(1.0)
	visible = false
	var area = get_node_or_null("Area2D")
	if area:
		area.set_deferred("monitoring", false)
	await get_tree().create_timer(0.85).timeout
	_show_end()
	get_tree().paused = true


func _show_end() -> void:
	var end_scene = get_node_or_null("../EndScene/CanvasLayer")
	if end_scene == null:
		return
	end_scene.visible = true
	var label = get_node_or_null("../EndScene/CanvasLayer/CenterContainer/VBoxContainer/Label")
	if label:
		label.modulate = Color(3.0, 2.2, 1.2)
	var hint := Label.new()
	hint.text = "PRESS FIRE TO RESTART"
	hint.add_theme_font_size_override("font_size", 18)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hint.offset_top = -80.0
	hint.offset_left = -150.0
	hint.offset_right = 150.0
	hint.process_mode = Node.PROCESS_MODE_ALWAYS  # animate while the tree is paused
	end_scene.add_child(hint)
	var tw := hint.create_tween().set_loops()
	tw.tween_property(hint, "modulate:a", 0.3, 0.6)
	tw.tween_property(hint, "modulate:a", 1.0, 0.6)
