extends CanvasLayer

@onready var grid_container: GridContainer = $Control/GridContainer

var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_objects() -> void:
	for object in player.holed_objects:
		var texturerect = TextureRect.new()
		texturerect.texture = object.sprite_texture
		grid_container.add_child(texturerect)
