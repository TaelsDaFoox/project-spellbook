extends CharacterBody3D
@export var topSpeed: float
@export var camSensitivity: float
@export var camLimitLower: float
@export var camLimitUpper: float
@onready var camPivot=$SpringArm3D
var mouseLocked := false

func _ready() -> void:
	updateMouseLock()

func updateMouseLock():
	if mouseLocked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("unlock mouse"):
		mouseLocked=false
		updateMouseLock()
	if event.is_action_pressed("lock mouse"):
		mouseLocked=true
		updateMouseLock()
	if event is InputEventMouseMotion and mouseLocked:
		camPivot.rotation.y-=event.relative.x*camSensitivity
		camPivot.rotation.x-=event.relative.y*camSensitivity
		camPivot.rotation.x=clampf(camPivot.rotation.x,camLimitLower,camLimitUpper)

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left","right","forward","backward")
	var move_dir = (transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized().rotated(Vector3.UP,camPivot.rotation.y)
	velocity=move_dir*topSpeed
	move_and_slide()
