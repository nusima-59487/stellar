extends CanvasLayer
# Self-contained cinematic space backdrop: gradient sky, soft nebulae,
# parallax twinkling stars and a couple of shaded planets.
# Spawned by the GameInstance autoload; draws behind everything (layer -100).

func _ready() -> void:
	layer = -100
	add_child(Backdrop.new())


class Backdrop extends Node2D:
	var stars := []
	var nebulae := []
	var planets := []
	var time := 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 20260606
		var area := Vector2(1920, 1080)

		# parallax star layers: {factor, size, bright}
		var defs := [
			{"count": 110, "factor": 0.04, "size": 1.0, "bright": 0.40},
			{"count": 70, "factor": 0.09, "size": 1.6, "bright": 0.70},
			{"count": 36, "factor": 0.17, "size": 2.4, "bright": 1.00},
		]
		for d in defs:
			var pts := []
			for i in range(d["count"]):
				pts.append(Vector2(rng.randf() * area.x, rng.randf() * area.y))
			stars.append({"pts": pts, "factor": d["factor"], "size": d["size"], "bright": d["bright"]})

		# soft colourful nebula clouds
		var ncols := [
			Color(0.42, 0.14, 0.52),  # magenta-violet
			Color(0.10, 0.34, 0.52),  # teal-blue
			Color(0.30, 0.10, 0.34),  # deep violet
			Color(0.14, 0.24, 0.56),  # indigo
		]
		for i in range(5):
			nebulae.append({
				"pos": Vector2(rng.randf() * area.x, rng.randf() * area.y),
				"r": rng.randf_range(280.0, 520.0),
				"col": ncols[i % ncols.size()],
				"factor": 0.025,
			})

		# planets — kept sparse so it stays elegant, not busy
		planets = [
			{   # large ringed gas giant, partly off-screen bottom-left for scale
				"anchor": Vector2(0.16, 0.86), "r": 190.0, "factor": 0.03,
				"body": Color(0.86, 0.56, 0.34),
				"atmo": Color(1.0, 0.78, 0.55),
				"light": Vector2(0.7, -0.7),
				"bands": [Color(0.95, 0.72, 0.45), Color(0.72, 0.42, 0.26), Color(0.92, 0.66, 0.42), Color(0.66, 0.36, 0.24)],
				"ring": true, "ring_col": Color(0.92, 0.82, 0.66),
			},
			{   # smaller banded blue world, upper-right
				"anchor": Vector2(0.82, 0.20), "r": 78.0, "factor": 0.05,
				"body": Color(0.34, 0.52, 0.74),
				"atmo": Color(0.6, 0.82, 1.0),
				"light": Vector2(-0.6, 0.8),
				"bands": [Color(0.46, 0.62, 0.82), Color(0.26, 0.42, 0.66)],
				"ring": false, "ring_col": Color(1, 1, 1),
			},
			{   # distant pale moon
				"anchor": Vector2(0.62, 0.74), "r": 26.0, "factor": 0.07,
				"body": Color(0.62, 0.64, 0.72),
				"atmo": Color(0.8, 0.84, 0.95),
				"light": Vector2(0.8, -0.5),
				"bands": [],
				"ring": false, "ring_col": Color(1, 1, 1),
			},
		]
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

		# 1) gradient sky (per-corner colours)
		var c_top := Color(0.035, 0.05, 0.13)
		var c_bot := Color(0.07, 0.035, 0.12)
		var quad := PackedVector2Array([Vector2.ZERO, Vector2(vp.x, 0), vp, Vector2(0, vp.y)])
		var cols := PackedColorArray([c_top, c_top, c_bot, c_bot])
		draw_polygon(quad, cols)

		# 2) nebula clouds (stacked translucent discs => soft falloff)
		for n in nebulae:
			var r: float = n["r"]
			var off := -cam * float(n["factor"])
			var base: Vector2 = n["pos"]
			base += off
			base.x = fposmod(base.x, vp.x + r * 2.0) - r
			base.y = fposmod(base.y, vp.y + r * 2.0) - r
			var col: Color = n["col"]
			draw_circle(base, r, Color(col.r, col.g, col.b, 0.045))
			draw_circle(base, r * 0.7, Color(col.r, col.g, col.b, 0.055))
			draw_circle(base, r * 0.45, Color(col.r, col.g, col.b, 0.07))
			draw_circle(base, r * 0.22, Color(col.r, col.g, col.b, 0.09))

		# 3) planets
		for p in planets:
			var anchor: Vector2 = p["anchor"]
			var center := Vector2(anchor.x * vp.x, anchor.y * vp.y) - cam * float(p["factor"])
			_draw_planet(center, p["r"], p["body"], p["atmo"], p["light"], p["bands"], p["ring"], p["ring_col"])

		# 4) parallax stars with gentle twinkle
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
				var tw := 0.6 + 0.4 * sin(time * 2.2 + idx * 1.7)
				var v := b * tw
				if size >= 2.0 and (idx % 5) == 0:
					# occasional brighter star gets a soft halo
					draw_circle(pos, size * 2.2, Color(0.7, 0.8, 1.0, 0.06))
				draw_circle(pos, size, Color(v, v, v * 1.05, 1.0))
				idx += 1

	func _draw_planet(c: Vector2, r: float, body: Color, atmo: Color, light_dir: Vector2, bands: Array, ring: bool, ring_col: Color) -> void:
		var light := light_dir.normalized()
		# atmosphere halo
		draw_circle(c, r * 1.16, Color(atmo.r, atmo.g, atmo.b, 0.08))
		draw_circle(c, r * 1.07, Color(atmo.r, atmo.g, atmo.b, 0.13))
		# ring behind the body (tilted ellipse)
		if ring:
			draw_set_transform(c, 0.5, Vector2(1.0, 0.34))
			var mid := r * 1.62
			draw_arc(Vector2.ZERO, mid, 0.0, TAU, 72, Color(ring_col.r, ring_col.g, ring_col.b, 0.45), r * 0.55, true)
			draw_arc(Vector2.ZERO, mid, 0.0, TAU, 72, Color(ring_col.r, ring_col.g, ring_col.b, 0.18), r * 0.95, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# body
		draw_circle(c, r, body)
		# horizontal bands (gas giants) as squashed translucent ellipses
		var n := bands.size()
		for i in range(n):
			var bc: Color = bands[i]
			var yoff := lerpf(-r * 0.62, r * 0.62, float(i) / maxf(1.0, float(n - 1)))
			draw_set_transform(c + Vector2(0, yoff), 0.0, Vector2(1.0, 0.16))
			draw_circle(Vector2.ZERO, r * 0.94, Color(bc.r, bc.g, bc.b, 0.30))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		# night-side shadow: a same-size dark disc offset away from the light
		draw_circle(c - light * r * 0.45, r, Color(0.015, 0.02, 0.05, 0.55))
		# lit-limb rim highlight
		draw_arc(c, r * 0.98, light.angle() - 1.15, light.angle() + 1.15, 40, Color(atmo.r, atmo.g, atmo.b, 0.45), 2.0, true)
