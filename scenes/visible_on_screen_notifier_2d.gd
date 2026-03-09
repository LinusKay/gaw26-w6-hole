extends VisibleOnScreenNotifier2D

@onready var hole_indicator: Sprite2D = $HoleIndicator

var player

func  _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _on_screen_exited() -> void:
	hole_indicator.show()
	pass


func _on_screen_entered() -> void:
	hole_indicator.hide()
	pass

# with a little help from: https://inputrandomness.com/figuring-out-godot-2d-screen-edge-pointers-and-bonus-picture-in-picture/
func _process(_delta: float) -> void:
	var inverse_canvas_transform: Transform2D = get_tree().root.canvas_transform.affine_inverse()
	var viewport_rect: Rect2 = get_viewport_rect()
	var upper_left: Vector2 = inverse_canvas_transform * Vector2.ZERO
	var lower_right: Vector2 = inverse_canvas_transform * viewport_rect.size
	var offset: Vector2 = Vector2(8, 8)
	
	var clamped_position: Vector2 = global_position.clamp(upper_left + offset, lower_right - offset)
	if clamped_position != hole_indicator.global_position:
		hole_indicator.global_position = clamped_position
	
	if hole_indicator.visible and player:
		var dir: Vector2 = player.global_position - hole_indicator.global_position
		var angle_step: float = PI / 4.0
		var angle_snapped: float = round(dir.angle() / angle_step) * angle_step
		hole_indicator.rotation = lerp_angle(hole_indicator.rotation, angle_snapped, 0.15)
		
