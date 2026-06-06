extends CanvasLayer
# Passive space backdrop: gradient sky, a few soft nebula tints and a
# parallax pixel starfield. Spawned by GameInstance; draws behind everything.

func _ready() -> void:
	layer = -100
	add_child(Backdrop.new())


class Backdrop extends Node2D:
	var stars := []
	var nebulae := []
	var time := 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 20260606
		var area := Vector2(1920, 1080)

		# parallax star layers: {factor, size, bright}
		var defs := [
			{"count": 110, "factor": 0.04, "size": 1.0, "bright": 0.40},
			{"count": 70, "factor": 0.09, "size": 2.0, "bright": 0.70},
			{"count": 36, "factor": 0.17, "size": 3.0, "bright": 1.00},
		]
		for d in defs:
			var pts := []
			for i in range(d["count"]):
				pts.append(Vector2(rng.randf() * area.x, rng.randf() * area.y))
			stars.append({"pts": pts, "factor": d["factor"], "size": d["size"], "bright": d["bright"]})

		# just a couple of soft colour tints — kept subtle
		var ncols := [
			Color(0.34, 0.14, 0.46),  # violet
			Color(0.10, 0.30, 0.48),  # teal-blue
			Color(0.16, 0.16, 0.40),  # indigo
		]
		for i in range(3):
			nebulae.append({
				"pos": Vector2(rng.randf() * area.x, rng.randf() * area.y),
				"r": rng.randf_range(260.0, 420.0),
				"col": ncols[i % ncols.size()],
				"factor": 0.025,
			})
		set_process(true)

	func _process(delta: float) -> void:
		time += delta
		queue_redraw()

	func _cam() -> Vector2:
		var c := get_viewport().get_camera_2d()
		if c:
			return c.get_screen_center_position()
		return Vector2.ZERO

	func _draw() -> void:
		var vp := get_viewport_rect().size
		var cam := _cam()

		# gradient sky (per-corner colours)
		var c_top := Color(0.035, 0.05, 0.13)
		var c_bot := Color(0.06, 0.035, 0.11)
		var quad := PackedVector2Array([Vector2.ZERO, Vector2(vp.x, 0), vp, Vector2(0, vp.y)])
		var cols := PackedColorArray([c_top, c_top, c_bot, c_bot])
		draw_polygon(quad, cols)

		# a few soft nebula tints (chunky / pixely — only two stacked discs each)
		for n in nebulae:
			var r: float = n["r"]
			var off := -cam * float(n["factor"])
			var base: Vector2 = n["pos"]
			base += off
			base.x = fposmod(base.x, vp.x + r * 2.0) - r
			base.y = fposmod(base.y, vp.y + r * 2.0) - r
			base = base.round()
			var col: Color = n["col"]
			draw_circle(base, r, Color(col.r, col.g, col.b, 0.05))
			draw_circle(base, r * 0.5, Color(col.r, col.g, col.b, 0.07))

		# parallax stars drawn as little squares for a pixel feel
		for layer_s in stars:
			var off := -cam * float(layer_s["factor"])
			var b: float = layer_s["bright"]
			var size: float = layer_s["size"]
			var idx := 0
			for s in layer_s["pts"]:
				var pos: Vector2 = s
				pos += off
				pos.x = fposmod(pos.x, vp.x)
				pos.y = fposmod(pos.y, vp.y)
				pos = pos.round()
				var tw := 0.6 + 0.4 * sin(time * 2.2 + idx * 1.7)
				var v := b * tw
				var half := floorf(size / 2.0)
				draw_rect(Rect2(pos - Vector2(half, half), Vector2(size, size)), Color(v, v, v * 1.05, 1.0))
				idx += 1
