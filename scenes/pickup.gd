@tool
class_name PickUpObject extends Node2D

@export var sprite_texture: CompressedTexture2D
@export var weight: int = 10
@export var held: bool = false
var throwing: bool = false
var hole: Hole = null
var throw_speed: float = .3

@onready var weight_label: Label = $WeightLabel
@onready var sprite_2d: Sprite2D = $Sprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WeightLabel.text = str(weight)
	$Sprite.texture = sprite_texture
	$Sprite.offset.x = -$Sprite.get_rect().size.x/2
	$Sprite.offset.y = -$Sprite.get_rect().size.y


func _physics_process(delta: float) -> void:
	$WeightLabel.text = str(weight)
	$Sprite.texture = sprite_texture
	$Sprite.offset.x = -$Sprite.get_rect().size.x/2
	$Sprite.offset.y = -$Sprite.get_rect().size.y
	
	if throwing:
		if not hole:
			hole = get_tree().get_first_node_in_group("hole")
		global_position = lerp(global_position, hole.global_position, throw_speed)
		scale.x = lerp(scale.x, 0.0, 0.1)
		scale.y = lerp(scale.y, 0.0, 0.1)
		if scale.x <= 0.2:
			Player.weight_capacity += weight
			queue_free()
		
