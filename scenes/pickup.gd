@tool
class_name PickUpObject extends Node2D

@export var sound_pickup: AudioStream
@export var sprite_texture: CompressedTexture2D
@export var weight: int = 10
@export var held: bool = false
var throwing: bool = false
var hole: Hole = null
var throw_speed: float = .3

@onready var weight_label: RichTextLabel = $WeightLabel
@onready var sprite_2d: Sprite2D = $Sprite
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sound_pickup:
		audio_stream_player_2d.stream = sound_pickup
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
		remove_from_group("pickup")
		print(get_tree().get_nodes_in_group("pickup").size())
		if get_tree().get_nodes_in_group("pickup").size() == 0:
			Player.youdoneit.emit()
			Player.alldone = true
		if scale.x <= 0.2:
			Player.weight_capacity += weight
			queue_free()
		
func play_sound() -> void:
	if audio_stream_player_2d.stream:
		audio_stream_player_2d.pitch_scale = randf_range(0.8,1.2)
		audio_stream_player_2d.play()
