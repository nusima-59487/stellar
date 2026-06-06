extends Marker2D

@export var junk_scene: PackedScene
var timer: Timer


func _ready() -> void:
	timer = get_node_or_null("../Timer") as Timer
	if timer:
		timer.timeout.connect(_on_timeout)


func _on_timeout() -> void:
	for i in range(GameManager.spawn_count):
		_spawn()


func _spawn() -> void:
	if junk_scene == null:
		return
	var junk = junk_scene.instantiate()
	var jitter := Vector2(randf_range(-70.0, 70.0), randf_range(-70.0, 70.0))
	junk.global_position = global_position + jitter
	junk.dir = randf() < 0.5
	get_parent().add_child(junk)
	# Spawn telegraph so debris doesn't just blink into existence.
	FX.ring(get_parent(), junk.global_position, FX.C_SPAWN, 44.0, 0.5, 4.0)
	FX.burst(get_parent(), junk.global_position, FX.C_SPAWN, 10, 130.0, 0.4, 3.0)
