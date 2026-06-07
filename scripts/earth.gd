extends StaticBody2D
class_name Earth


var max_hp: int = GameInstance.earth_health;
var hp: int = max_hp;

@onready var hp_overlay: CanvasLayer = $"../HpOverlay"

var progress_bar: TextureProgressBar; 
var end_scene: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameInstance.earth_ref = self
	GameInstance.stats_updated.connect(_on_stats_updated)
	await hp_overlay.ready
	hp_overlay.update(hp, GameInstance.earth_health)
	pass
	# print(hp, GameInstance.earth_health)
	
func _on_stats_updated (): 
	self.max_hp = GameInstance.earth_health
	hp_overlay.update(hp, GameInstance.earth_health)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# on body enter detection area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Junk: 
		hp -= body.health
		hp_overlay.update(hp, GameInstance.earth_health)
		body.queue_free()
		if hp <= 0:
			self.queue_free() # Earth is destroyed
			end_scene = $"../EndScene/CanvasLayer"
			get_tree().paused = true
			end_scene.visible = true 
			
