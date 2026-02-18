extends CharacterBody2D

@export var speed = 200
@export var pickup_point: Node2D


@onready var pickup_range: Area2D = $PickupRange
@onready var pickup_collision: CollisionShape2D = $PickupRange/CollisionShape2D

var sprite_normal: CompressedTexture2D = preload("res://sprites/char1.png")
var sprite_carry: Array[CompressedTexture2D] = [
	preload("res://sprites/char1_carry.png"),
	preload("res://sprites/char1_carry2.png"),
	preload("res://sprites/char1_carry3.png")
]

var weight_capacity: int = 5

var held_object: PickUpObject
var held_objects: Array[PickUpObject]

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()
	_update_carry_positions()
	
	if held_objects.size() > 0:
		if $Sprite2D.texture == sprite_normal:
			$Sprite2D.texture = sprite_carry[0]
			sprite_carry.append(sprite_carry[0])
			sprite_carry.pop_front()
	else:
		$Sprite2D.texture = sprite_normal


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup"):
		_pickup()
	if event.is_action_pressed("drop"):
		_drop()
		

func _pickup() -> void:
	var pickup_object = _get_closest_pickup()
	if pickup_object:
		pickup_object.held = true
		held_objects.append(pickup_object)
		print("i am now holding " + str(get_current_weight()))


func _drop() -> void:
	if held_objects.size() > 0:
		var areas = pickup_range.get_overlapping_areas()
		for area in areas:
			if area is Hole:
				for object in held_objects:
					object.held = false
					object.throwing = true
				held_objects.clear()
				return
		held_objects[0].held = false
		held_objects.pop_front()
	
		


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
					continue
				if not target_object:
					target_object = pickup_object
					continue
				if position.distance_to(pickup_object.position) < position.distance_to(target_object.position):
					target_object = pickup_object
	return target_object
