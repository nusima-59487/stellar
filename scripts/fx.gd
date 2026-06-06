class_name FX
extends Object

# Bright (HDR) palette. Values > 1.0 bloom through the WorldEnvironment glow
# created by the GameManager autoload (requires rendering/viewport/hdr_2d = true).
const C_BULLET := Color(1.1, 2.0, 2.6)
const C_HIT := Color(2.6, 2.2, 1.0)
const C_EXPLODE := Color(2.8, 1.3, 0.4)
const C_EARTH := Color(2.6, 0.8, 0.6)
const C_SHIELD := Color(0.6, 1.0, 2.4)
const C_SPAWN := Color(1.8, 0.6, 2.4)


# Radial one-shot particle burst that frees itself once it's done.
static func burst(parent: Node, gpos: Vector2, color: Color, count := 24, speed := 220.0, life := 0.6, psize := 5.0) -> void:
	if parent == null:
		return
	var p := CPUParticles2D.new()
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = maxi(1, count)
	p.lifetime = life
	p.local_coords = false
	p.direction = Vector2.RIGHT
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = speed * 0.25
	p.initial_velocity_max = speed
	p.damping_min = speed * 0.4
	p.damping_max = speed * 0.9
	p.scale_amount_min = psize * 0.5
	p.scale_amount_max = psize
	p.color = color
	var g := Gradient.new()
	g.set_color(0, color)
	g.set_color(1, Color(color.r, color.g, color.b, 0.0))
	p.color_ramp = g
	p.global_position = gpos
	parent.add_child(p)
	p.emitting = true
	var tree := parent.get_tree()
	if tree:
		var timer := tree.create_timer(life + 0.4)
		var cb := func() -> void:
			if is_instance_valid(p):
				p.queue_free()
		timer.timeout.connect(cb)


# Expanding shockwave ring (or filled flash if filled = true).
static func ring(parent: Node, gpos: Vector2, color: Color, max_radius := 70.0, dur := 0.4, width := 4.0, filled := false) -> void:
	if parent == null:
		return
	var r := ShockRing.new()
	r.col = color
	r.max_radius = max_radius
	r.dur = dur
	r.width = width
	r.filled = filled
	r.start_radius = maxf(2.0, max_radius * 0.12)
	r.global_position = gpos
	parent.add_child(r)


class ShockRing extends Node2D:
	var col := Color(1, 1, 1, 1)
	var max_radius := 70.0
	var start_radius := 6.0
	var width := 4.0
	var dur := 0.4
	var filled := false
	var t := 0.0

	func _ready() -> void:
		z_index = 60

	func _process(delta: float) -> void:
		t += delta
		if t >= dur:
			queue_free()
			return
		queue_redraw()

	func _draw() -> void:
		var k := clampf(t / dur, 0.0, 1.0)
		var a := 1.0 - k
		var c := Color(col.r, col.g, col.b, col.a * a)
		if filled:
			var rad := lerpf(max_radius, max_radius * 0.4, k)
			draw_circle(Vector2.ZERO, rad, c)
		else:
			var ease_k := 1.0 - pow(1.0 - k, 2.0)
			var rad := lerpf(start_radius, max_radius, ease_k)
			draw_arc(Vector2.ZERO, rad, 0.0, TAU, 64, c, width * (1.0 - k * 0.6), true)
