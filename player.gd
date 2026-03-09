extends CharacterBody2D

signal speech(words: String)
signal youdoneit
var alldone: bool = false

@export var speed = 300
@export var pickup_point: Node2D

@onready var camera_2d: Camera2D = $Camera2D

@onready var pickup_range: Area2D = $PickupRange
@onready var pickup_collision: CollisionShape2D = $PickupRange/CollisionShape2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var footsteps: AudioStreamPlayer = $footsteps

@onready var scene_pickup: PackedScene = preload("res://scenes/pickup_object.tscn")
var world_holed: bool = false
var ui_holed: bool = false
var player_holed: bool = false

var sprite_normal: CompressedTexture2D = preload("res://sprites/char1.png")
var sprite_carry: Array[CompressedTexture2D] = [
	preload("res://sprites/char1_carry.png"),
	preload("res://sprites/char1_carry2.png"),
	preload("res://sprites/char1_carry3.png")
]
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var weight_capacity: int = 2000

var held_object: PickUpObject
var held_objects: Array[PickUpObject]

var holed_objects: Array[PickUpObject] = []

var accept_input: bool = true
var goodbye: bool = false
var hole
var credit
var music

var cannot_just_drop: bool = false

var desired_camera_zoom: float = 2.0

func _ready() -> void:
	await get_tree().process_frame
	hole = get_tree().get_first_node_in_group("hole")
	credit = get_tree().get_first_node_in_group("credit")
	music = get_tree().get_first_node_in_group("music")
	var playerspawn = get_tree().get_first_node_in_group("playerspawn")
	global_position = playerspawn.global_position

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	if input_direction:
		if not footsteps.playing:
			footsteps.play()
	else:
		footsteps.stop()

func _physics_process(_delta):
	if accept_input:
		get_input()
		move_and_slide()
	_update_carry_positions()

	if not goodbye:
		if held_objects.size() > 0:
			if $Sprite2D.texture == sprite_normal:
				$Sprite2D.texture = sprite_carry[0]
				sprite_carry.append(sprite_carry[0])
				sprite_carry.pop_front()
		else:
			$Sprite2D.texture = sprite_normal
	else:
		global_position = lerp(global_position, hole.global_position, .003)
		scale.x = lerp(scale.x, 0.0, 0.003)
		scale.y = lerp(scale.y, 0.0, 0.003)
		print(scale.x)
		if scale.x < 0.2:
			print(hole.scale.x)
			hole.scale.x = lerp(hole.scale.x, 20.0, 0.002)
			hole.scale.y = lerp(hole.scale.y, 20.0, 0.002)
			if hole.scale.x > 10.0:
				if credit.modulate.a < 1:
					credit.modulate.a += 0.01
					music.volume_db -= 0.01
	
	camera_2d.zoom.x = lerp(camera_2d.zoom.x, desired_camera_zoom, 0.1)
	camera_2d.zoom.y = lerp(camera_2d.zoom.y, desired_camera_zoom, 0.1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup"):
		_pickup()
	if event.is_action_pressed("drop"):
		_drop()
	#if event.is_action_pressed("restart"):
		#get_tree().reload_current_scene()
		

func _pickup() -> void:
	var total_pickups = _get_total_pickups()
	if total_pickups > 1:
		var pickup_object = _get_closest_pickup()
		if pickup_object:
			pickup_object.held = true
			pickup_object.play_sound()
			held_objects.append(pickup_object)
			desired_camera_zoom = clamp(2.0 - (0.1 * held_objects.size()), 0.3, 2.0)
			print("i am now holding " + str(get_current_weight()))
	elif total_pickups == 1:
		cannot_just_drop = true
		#pick up da eart	
		if not world_holed:		
			var tilemaplayer: TileMapLayer = get_tree().current_scene.get_node("TileMapLayer")
			tilemaplayer.queue_free()
			var pickup_object: PickUpObject = scene_pickup.instantiate()
			pickup_object.sprite_texture = load("res://sprites/daeart.png")
			pickup_object.sound_pickup = load("res://audio/freesound_community-rock-destroy-6409.mp3")
			get_tree().current_scene.add_child(pickup_object)
			pickup_object.play_sound()
			held_objects.append(pickup_object)
			world_holed = true
	else:
		cannot_just_drop = true
		#pick up da ui
		if not ui_holed:
			Ui.hide()
			get_tree().get_first_node_in_group("background").hide()
			var pickup_object: PickUpObject = scene_pickup.instantiate()
			pickup_object.sprite_texture = load("res://sprites/dagame.png")
			pickup_object.sound_pickup = load("res://audio/freesound_community-rock-destroy-6409.mp3")
			get_tree().current_scene.add_child(pickup_object)
			pickup_object.play_sound()
			held_objects.append(pickup_object)
			ui_holed = true
		else:
			if not player_holed:
				accept_input = false
				goodbye = true
				animation_player.play("wave")
				music.stream = load("res://audio/outro.mp3")
				music.play()

func _drop() -> void:
	if held_objects.size() > 0:
		var areas = pickup_range.get_overlapping_areas()
		for area in areas:
			if area is Hole:
				for object in held_objects:
					object.held = false
					object.throwing = true
					var already_holed: bool = false
					for hobject in holed_objects:
						if object.sprite_texture.load_path == hobject.sprite_texture.load_path:
							already_holed = true
					if not already_holed:
						holed_objects.append(object.duplicate())
				held_objects.clear()
				audio_stream_player.pitch_scale = randf_range(0.8,1.2)
				audio_stream_player.play()
				holed_objects.sort_custom(func(a, b): return a.weight > b.weight)
				desired_camera_zoom = 2.0
				UiHoledObjects.update_objects()
				return
		if not cannot_just_drop:
			held_objects[0].held = false
			held_objects.pop_front()
			desired_camera_zoom = clamp(2.0 - (0.1 * held_objects.size()), 0.3, 2.0)
			
	
		


func get_current_weight() -> int:
	var weight: int = 0
	for obj in held_objects:
		weight += obj.weight
	return weight


func _calc_would_overweight(new_weight: int) -> int:
	return get_current_weight() + new_weight > weight_capacity


func _update_carry_positions() -> void:
	for object_index in held_objects.size():
		if object_index == 0:
			held_objects[object_index].global_position = pickup_point.global_position
		else:
			var prev_object: PickUpObject = held_objects[object_index-1]
			held_objects[object_index].global_position.x = prev_object.global_position.x
			held_objects[object_index].global_position.y = prev_object.global_position.y - prev_object.get_node("Sprite").get_rect().size.y
			

func _get_closest_pickup() -> PickUpObject:
	var areas = pickup_range.get_overlapping_areas()
	var target_object = null
	for area in areas:
		if area.get_parent() is PickUpObject:
			var pickup_object: PickUpObject = area.get_parent()
			if not pickup_object.held:
				if _calc_would_overweight(pickup_object.weight):
					print("object too big i cannot pick htis up")
					speech.emit("this too big i cannot pick htis up")
					continue
				if not target_object:
					target_object = pickup_object
					continue
				if position.distance_to(pickup_object.position) < position.distance_to(target_object.position):
					target_object = pickup_object
	return target_object


func _get_total_pickups() -> int:
	return get_tree().get_node_count_in_group("pickup")
