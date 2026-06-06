extends Node
# Autoload singleton "GameManager" (registered in project.godot).
# Central director: combat/upgrade stats, wave progression, xp/leveling,
# screen-shake routing, the global glow environment, parallax starfield,
# and restart-on-death.

signal wave_changed(wave)
signal xp_changed(xp, xp_to_next)
signal level_up(level)

# --- combat / upgrade stats (read by the player + bullets) ---
var bullet_speed: int = 300
var bullet_damage: int = 10
var bullet_streams_count: int = 1
var bullet_fire_cooldown: float = 0.18
var earth_health: int = 80
var lazer_unlocked: bool = false
var damage_reduction_multiplier: float = 1.0
var junk_speed_multiplier: float = 1.0

# --- wave / progression state ---
var wave: int = 1
var level: int = 1
var xp: int = 0
var xp_to_next: int = 50
var wave_interval: float = 16.0
var base_spawn_interval: float = 3.3
var spawn_count: int = 1
var _wave_time: float = 0.0

var _starfield: CanvasLayer


func _ready() -> void:
	# ALWAYS so we can still read the "restart" input while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_environment()
	_build_starfield()
	call_deferred("_late_init")


func _late_init() -> void:
	_apply_wave()
	_update_xp_bar()
	var hb = _scene_node("UI/CanvasLayer/HealthBar")
	if hb:
		hb.tint_progress = Color(1.4, 0.6, 2.2)
	var xb = _scene_node("UI/CanvasLayer/ExperienceBar")
	if xb:
		xb.tint_progress = Color(0.6, 1.6, 2.0)
		xb.max_value = xp_to_next


func _process(delta: float) -> void:
	if get_tree().paused:
		if Input.is_action_just_pressed("fire") or Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_SPACE):
			restart()
		return
	_wave_time += delta
	if _wave_time >= wave_interval:
		_wave_time = 0.0
		next_wave()
	# Re-purpose the spare HealthBar as a "time until next wave" meter.
	var hb = _scene_node("UI/CanvasLayer/HealthBar")
	if hb:
		hb.max_value = wave_interval
		hb.value = _wave_time


# --- waves -------------------------------------------------------
func next_wave() -> void:
	wave += 1
	junk_speed_multiplier = 1.0 + (wave - 1) * 0.07
	spawn_count = clampi(1 + int((wave - 1) / 3.0), 1, 2)
	_apply_wave()
	wave_changed.emit(wave)
	request_shake(0.25)


func _apply_wave() -> void:
	var t = _scene_node("Spawners/Timer")
	if t:
		t.wait_time = clampf(base_spawn_interval - (wave - 1) * 0.16, 1.1, base_spawn_interval)


# --- xp / leveling ----------------------------------------------
func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next:
		xp -= xp_to_next
		_do_level_up()
	_update_xp_bar()


func _do_level_up() -> void:
	level += 1
	xp_to_next = int(xp_to_next * 1.25)
	# Rotating upgrade each level — wires up the planned stat system.
	match level % 4:
		0:
			bullet_damage += 4
		1:
			bullet_streams_count = mini(bullet_streams_count + 1, 5)
		2:
			bullet_fire_cooldown = maxf(0.06, bullet_fire_cooldown * 0.85)
		3:
			bullet_speed += 30
	level_up.emit(level)
	request_shake(0.3)


func _update_xp_bar() -> void:
	xp_changed.emit(xp, xp_to_next)
	var b = _scene_node("UI/CanvasLayer/ExperienceBar")
	if b:
		b.max_value = xp_to_next
		var tw := b.create_tween()
		tw.tween_property(b, "value", float(xp), 0.2)


# --- screen shake ------------------------------------------------
func request_shake(amount: float) -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p and p.has_method("add_trauma"):
		p.add_trauma(amount)


# --- restart -----------------------------------------------------
func restart() -> void:
	get_tree().paused = false
	_reset()
	get_tree().reload_current_scene()
	await get_tree().process_frame
	await get_tree().process_frame
	_late_init()


func _reset() -> void:
	bullet_speed = 300
	bullet_damage = 10
	bullet_streams_count = 1
	bullet_fire_cooldown = 0.18
	junk_speed_multiplier = 1.0
	wave = 1
	level = 1
	xp = 0
	xp_to_next = 50
	spawn_count = 1
	_wave_time = 0.0


# --- helpers -----------------------------------------------------
func _scene_node(path: String) -> Node:
	var s := get_tree().current_scene
	if s == null:
		return null
	return s.get_node_or_null(path)


func _build_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.85
	env.glow_strength = 1.1
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	env.glow_hdr_threshold = 1.0
	env.glow_hdr_scale = 2.0
	for i in range(7):
		env.set_glow_level(i, 0.0)
	env.set_glow_level(1, 1.0)
	env.set_glow_level(2, 1.0)
	env.set_glow_level(3, 1.0)
	env.set_glow_level(4, 0.8)
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)


func _build_starfield() -> void:
	_starfield = CanvasLayer.new()
	_starfield.layer = -100
	_starfield.add_child(Starfield.new())
	add_child(_starfield)


# Procedural parallax starfield + soft nebulae, drawn in screen space and
# scrolled against the player camera for an infinite deep-space backdrop.
class Starfield extends Node2D:
	var layers := []
	var nebulae := []
	var time := 0.0

	func _ready() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 9001
		var defs := [
			{"count": 90, "factor": 0.04, "size": 1.1, "bright": 0.45},
			{"count": 60, "factor": 0.10, "size": 1.7, "bright": 0.8},
			{"count": 32, "factor": 0.22, "size": 2.6, "bright": 1.35},
		]
		var area := Vector2(1920, 1080)
		for d in defs:
			var stars := []
			for i in range(d["count"]):
				stars.append(Vector2(rng.randf() * area.x, rng.randf() * area.y))
			layers.append({"stars": stars, "factor": d["factor"], "size": d["size"], "bright": d["bright"]})
		var ncols := [Color(0.22, 0.10, 0.45), Color(0.06, 0.16, 0.40), Color(0.35, 0.08, 0.25)]
		for i in range(5):
			nebulae.append({
				"pos": Vector2(rng.randf() * area.x, rng.randf() * area.y),
				"r": rng.randf_range(260.0, 460.0),
				"col": ncols[i % ncols.size()],
				"factor": 0.03,
			})

	func _process(delta: float) -> void:
		time += delta
		queue_redraw()

	func _cam_pos() -> Vector2:
		var p = get_tree().get_first_node_in_group("player")
		if p:
			return p.global_position
		return Vector2.ZERO

	func _draw() -> void:
		var vp := get_viewport_rect().size
		var cam := _cam_pos()
		# deep-space backdrop
		draw_rect(Rect2(Vector2.ZERO, vp), Color(0.015, 0.02, 0.045))
		# soft nebula clouds (faked with stacked translucent circles)
		for n in nebulae:
			var r: float = n["r"]
			var off := -cam * float(n["factor"])
			var base: Vector2 = n["pos"]
			base += off
			base.x = fposmod(base.x, vp.x + r * 2.0) - r
			base.y = fposmod(base.y, vp.y + r * 2.0) - r
			var col: Color = n["col"]
			draw_circle(base, r, Color(col.r, col.g, col.b, 0.05))
			draw_circle(base, r * 0.65, Color(col.r, col.g, col.b, 0.06))
			draw_circle(base, r * 0.35, Color(col.r, col.g, col.b, 0.08))
		# parallax stars with twinkle
		for layer in layers:
			var off := -cam * float(layer["factor"])
			var b: float = layer["bright"]
			var size: float = layer["size"]
			var idx := 0
			for s in layer["stars"]:
				var pos: Vector2 = s
				pos += off
				pos.x = fposmod(pos.x, vp.x)
				pos.y = fposmod(pos.y, vp.y)
				var tw := 0.65 + 0.35 * sin(time * 2.5 + idx * 1.3)
				draw_circle(pos, size, Color(b * tw, b * tw, b * tw * 1.05, 1.0))
				idx += 1
