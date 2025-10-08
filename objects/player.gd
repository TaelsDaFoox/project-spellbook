extends CharacterBody3D
@export var topSpeed: float
@export var camSensitivity: float
@export var camLimitLower: float
@export var camLimitUpper: float
@export var jumpStrength: float
@export var gravityForce: float
@onready var camPivot=$SpringArm3D
@onready var spellBase=$SpellEffectBase
@onready var spellPoint1 = $SpellEffectBase/SpellPointU
@onready var spellPoint2 = $SpellEffectBase/SpellPointR
@onready var spellPoint3 = $SpellEffectBase/SpellPointD
@onready var spellPoint4 = $SpellEffectBase/SpellPointL
@onready var spellStar = $SpellEffectBase/SpellStar
@onready var spellMaterialBase: StandardMaterial3D = load("res://materials/SpellCircleBase.tres")
@onready var spellMaterialOff: StandardMaterial3D = load("res://materials/SpellNodeOff.tres")
@onready var spellMaterialOn: StandardMaterial3D = load("res://materials/SpellNodeOn.tres")
@onready var spellMaterialLine: StandardMaterial3D = load("res://materials/SpellLine.tres")
@onready var spellMaterialStar: StandardMaterial3D = load("res://materials/SpellStar.tres")
@onready var spellLine = $SpellEffectBase/SpellLine
var material:StandardMaterial3D = null
	
var mouseLocked := false

func _ready() -> void:
	spellLine.size.x=0.01
	updateMouseLock()

func updateMouseLock():
	if mouseLocked:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y=jumpStrength
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

func groundSpellTransparency(target:float,delta:float):
	spellMaterialBase.albedo_color.a=lerp(spellMaterialBase.albedo_color.a,target,20*delta)
	spellMaterialOff.albedo_color.a=spellMaterialBase.albedo_color.a
	spellMaterialLine.albedo_color.a=spellMaterialBase.albedo_color.a
	spellMaterialStar.albedo_color.a=spellMaterialBase.albedo_color.a

func _physics_process(delta: float) -> void:
	spellStar.rotation.y+=delta*10
	#spellLine.rotation.y+=delta*2
	spellBase.rotation.y=lerp_angle(spellBase.rotation.y,camPivot.rotation.y,10*delta)
	var input_dir = Input.get_vector("left","right","forward","backward")
	if Input.is_action_pressed("magic"):
		PlayerGlobalManager.casting=true
		if PlayerGlobalManager.spellDirs.size()<0:
			PlayerGlobalManager.spellDirs.append(1)
		groundSpellTransparency(1,delta)
		addSpellDirections()
		input_dir = Vector2.ZERO
	else:
		PlayerGlobalManager.casting=false
		if PlayerGlobalManager.spellDirs.size()>0:
			PlayerGlobalManager.spellDirs.clear()
		groundSpellTransparency(0,delta)
		spellPoint1.material=spellMaterialOff
		spellPoint2.material=spellMaterialOff
		spellPoint3.material=spellMaterialOff
		spellPoint4.material=spellMaterialOff
	var move_dir = (transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized().rotated(Vector3.UP,camPivot.rotation.y)
	velocity.x=move_dir.x*topSpeed
	velocity.z=move_dir.z*topSpeed
	if is_on_floor():
		if velocity.y<0:
			velocity.y=0
	else:
		velocity.y-=gravityForce*delta
	move_and_slide()
	
func addSpellDirections():
	if Input.is_action_just_pressed("forward") and not PlayerGlobalManager.spellDirs.has(1):
		PlayerGlobalManager.spellDirs.append(1)
	if Input.is_action_just_pressed("right") and not PlayerGlobalManager.spellDirs.has(2):
		PlayerGlobalManager.spellDirs.append(2)
	if Input.is_action_just_pressed("backward") and not PlayerGlobalManager.spellDirs.has(3):
		PlayerGlobalManager.spellDirs.append(3)
	if Input.is_action_just_pressed("left") and not PlayerGlobalManager.spellDirs.has(4):
		PlayerGlobalManager.spellDirs.append(4)
	if PlayerGlobalManager.spellDirs.size()>0:
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==1:
			spellPoint1.material=spellMaterialOn
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==2:
			spellPoint2.material=spellMaterialOn
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==3:
			spellPoint3.material=spellMaterialOn
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==4:
			spellPoint4.material=spellMaterialOn
