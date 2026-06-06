extends StaticBody2D
class_name Earth


var max_hp: int = GameInstance.max_earth_health;
var hp: int = max_hp;

@onready var hp_overlay: CanvasLayer = $"../HpOverlay"

var progress_bar: TextureProgressBar; 
var end_scene: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await hp_overlay.ready
	hp_overlay.update(hp, max_hp)
	pass
	# print(hp, max_hp)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# on body enter detection area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		hp -= body.health
		hp_overlay.update(hp, max_hp)
		body.queue_free()
		if hp <= 0:
			self.queue_free() # Earth is destroyed
			end_scene = $"../EndScene/CanvasLayer"
			get_tree().paused = true
			end_scene.visible = true 
			
