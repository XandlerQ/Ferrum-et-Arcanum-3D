extends Node3D;
class_name EntityMovement;

#region Variables
# Entity
@onready var entity: CharacterBody3D = $"..";

# Gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

# Entity individual kinematic properties
# Max walk speed
@export var walkSpeed: float = 4;
# Max run speed
@export var runSpeed: float = 6;
# Dash speed
@export var dashSpeed: float = 10;
# Jump speed
@export var jumpSpeed: float = 4;
# Terminal fall speed
@export var terminalFallSpeed: float = 20;
# Walk acceleration
@export var walkAcceleration: float = 25;
# Run acceleration
@export var runAcceleration: float = 35;
# Deceleration
@export var friction: float = 25;

# Dash timer
@onready var dashTimer: Timer = $DashTimer;
# Dash cooldown
@export var dashCooldown: float = 1;

# Kinematic properties multiplicative modifiers
@export var speedModifier: float = 1.0;
@export var accelerationModifier: float = 1.0;
@export var airbornAccelerationModifier: float = 0.2;
@export var frictionModifier: float = 1.0;
@export var airbornFrictionModifier: float = 0.2;
#endregion

func _ready() -> void:
	dashTimer.one_shot = true;
	dashTimer.wait_time = dashCooldown;

#region Kinematic properties getters
func get_walk_speed() -> float:
	return walkSpeed * speedModifier;

func get_run_speed() -> float:
	return runSpeed * speedModifier;

func get_dash_speed() -> float:
	return dashSpeed * speedModifier;

func get_walk_acceleration() -> float:
	if entity.is_on_floor():
		return walkAcceleration * accelerationModifier;
	else:
		return walkAcceleration * accelerationModifier * airbornAccelerationModifier;

func get_run_acceleration() -> float:
	if entity.is_on_floor():
		return runAcceleration * accelerationModifier;
	else:
		return runAcceleration * accelerationModifier * airbornAccelerationModifier;

func get_friction() -> float:
	if entity.is_on_floor():
		return friction * frictionModifier;
	else:
		return friction * airbornFrictionModifier;
#endregion

#region Kinematic properties multiplicative modifiers setters
func set_speed_modifier(modifier: float) -> void:
	speedModifier = modifier;

func set_acceleration_modifier(modifier: float) -> void:
	accelerationModifier = modifier;

func set_friction_modifier(modifier: float) -> void:
	frictionModifier = modifier;
#endregion

func convert_velocity_3_2(velocity: Vector3) -> Vector2:
	var rVelocity: Vector2;
	rVelocity.x = velocity.x;
	rVelocity.y = velocity.z;
	return rVelocity;

func convert_velocity_2_3(velocity: Vector2) -> Vector3:
	var rVelocity: Vector3;
	rVelocity.x = velocity.x;
	rVelocity.z = velocity.y;
	return rVelocity;

#region Movement methods
func walk_in_direction(delta: float, direction: Vector2) -> void:
	if (direction == Vector2.ZERO):
		return stop(delta);
	var rVelocity: Vector2 = convert_velocity_3_2(entity.velocity);
	var velocityLength: float = rVelocity.length();
	var limitLengthValue = get_walk_speed();
	if (velocityLength > limitLengthValue):
		limitLengthValue = velocityLength - get_friction() * delta;
	var deltaVelocity: Vector2 = (get_walk_acceleration() * delta) * direction;
	rVelocity += deltaVelocity;
	rVelocity = rVelocity.limit_length(limitLengthValue);
	entity.velocity.x = rVelocity.x;
	entity.velocity.z = rVelocity.y;

func run_in_direction(delta: float, direction: Vector2) -> void:
	if (direction == Vector2.ZERO):
		return stop(delta);
	var rVelocity: Vector2 = convert_velocity_3_2(entity.velocity);
	var velocityLength: float = rVelocity.length();
	var limitLengthValue = get_run_speed();
	if (velocityLength > limitLengthValue):
		limitLengthValue = velocityLength - get_friction() * delta;
	var deltaVelocity: Vector2 = (get_run_acceleration() * delta) * direction;
	rVelocity += deltaVelocity;
	rVelocity = rVelocity.limit_length(limitLengthValue);
	entity.velocity.x = rVelocity.x;
	entity.velocity.z = rVelocity.y;

func dash_in_direction(delta: float, direction: Vector2) -> void:
	if (direction == Vector2.ZERO or !dashTimer.is_stopped()):
		return stop(delta);
	dashTimer.start();
	var rVelocity: Vector2 = convert_velocity_3_2(entity.velocity) / 2;
	rVelocity += get_dash_speed() * direction;
	entity.velocity.x = rVelocity.x;
	entity.velocity.z = rVelocity.y;

func stop(delta: float) -> void:
	var rVelocity: Vector2 = convert_velocity_3_2(entity.velocity);
	if (rVelocity == Vector2.ZERO):
		return;
	var velocityLength: float = rVelocity.length();
	var velocityDirection: Vector2 = rVelocity / velocityLength;
	var decelerationLength: float = get_friction() * delta;
	if (velocityLength > decelerationLength) :
		rVelocity += -decelerationLength * velocityDirection;
	else:
		rVelocity = Vector2.ZERO;
	entity.velocity.x = rVelocity.x;
	entity.velocity.z = rVelocity.y;

func jump() -> void:
	if entity.is_on_floor():
		entity.velocity.y = jumpSpeed;

func fall(delta: float) -> void:
	if not entity.is_on_floor():
		entity.velocity.y -= gravity * delta;
		entity.velocity.y = clamp(entity.velocity.y, -terminalFallSpeed, jumpSpeed);
#endregion
