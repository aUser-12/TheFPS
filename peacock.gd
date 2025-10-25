class_name Gun
extends Node3D

@export var shooting_range: float = 100.0
@export var gun_damage: float = 1

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"


@onready var player_camera: Camera3D = $".."

func _ready() -> void:
	pass


	

#func shoot() -> void:
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		_shoot()
		
func _shoot() -> void:
	if not animation_player.is_playing():
		
		animation_player.play("shoot")
		var space_state:PhysicsDirectSpaceState3D = player_camera.get_world_3d().direct_space_state
		var ray_start: Vector3 = player_camera.global_position
	
		var ray_direction: Vector3 = -player_camera.global_basis.z
		var ray_end:Vector3 = ray_start + ray_direction.normalized() * shooting_range
	
		var query := PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.collide_with_bodies = true
		var result: Dictionary = space_state.intersect_ray(query)
	
		print(result)
	
		if not result.is_empty():
			_hit_the_target(result, ray_direction)
	
		
func _hit_the_target(result: Dictionary, impact_direction: Vector3) -> void:
	var target = result["collider"]
	if target is CharacterBody3D:
		target._take_damage(gun_damage)

	
