extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var alive = true
var chase = false
var SPEED = 150
@onready var anim = $Skeleton_Anim

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	var player = $"../../Player/Player"
	var direction = (player.position - self.position).normalized()
	if alive == true:
		if chase == true:
			velocity.x = direction.x * SPEED
			anim.play("Run")
		else:
			velocity.x = 0
			anim.play("Idle")
			
		if direction.x < 0:
			$Skeleton_Anim.flip_h = true
		else:
			$Skeleton_Anim.flip_h = false
		move_and_slide()

func _on_skeleton_agro_area_body_entered(body):
	if body.name == "Player":
		chase = true

func _on_skeleton_agro_area_body_exited(body):
	if body.name == "Player":
		chase = false

func death():
	alive = false
	anim.play("Death")
	await anim.animation_finished
	queue_free()
