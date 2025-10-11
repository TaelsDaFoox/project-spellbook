extends CharacterBody3D
@export var topSpeed: float
@export var runSpeedMult: float
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
@onready var spellMaterialWandStar: StandardMaterial3D = load("res://materials/wandStar.tres")
@onready var spellLine = $SpellEffectBase/SpellLine
@onready var playerSFX = $PlayerSFX
@onready var sfxSpellD: AudioStream=load("res://sfx/spells/down.wav")
@onready var sfxSpellL: AudioStream=load("res://sfx/spells/left.wav")
@onready var sfxSpellR: AudioStream=load("res://sfx/spells/right.wav")
@onready var sfxSpellU: AudioStream=load("res://sfx/spells/up.wav")
@onready var sfxSpellDF: AudioStream=load("res://sfx/spells/down-f.wav")
@onready var sfxSpellLF: AudioStream=load("res://sfx/spells/left-f.wav")
@onready var sfxSpellRF: AudioStream=load("res://sfx/spells/right-f.wav")
@onready var sfxSpellUF: AudioStream=load("res://sfx/spells/up-f.wav")
@onready var sfxSpellFail: AudioStream=load("res://sfx/spells/fail.wav")
@onready var playerModel = $PlayerModel
@onready var animator = $PlayerModel/AnimationPlayer
var material:StandardMaterial3D = null
var mouseLocked := false
var fireball = load("res://objects/fireball.tscn")
var chargedSpell := ""

var spellNames := ["Flare","Chill","Shock","Restore","Energize","Chronos","???"]
var spellCombos := [3421,1342,1423,3412,3124,2134]
var spellColors :=[Vector3(255,0,90),Vector3(128,140,255),Vector3(255,216,0),Vector3(0,240,160),Vector3(0,255,255),Vector3(237,109,54),Vector3.ZERO]

func _ready() -> void:
	playerSFX.volume_db=-10
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
	#spellMaterialBase.albedo_color.r=255
	#spellMaterialBase.albedo_color.g=216
	#spellMaterialBase.albedo_color.b=0
func spellColor(colorNum:int,reset:bool):
	var r = 1
	var g = 1
	var b = 1
	if not reset:
		print(spellColors[colorNum])
		r = spellColors[colorNum].x/255
		g = spellColors[colorNum].y/255
		b = spellColors[colorNum].z/255
	setMaterialColor(spellMaterialBase,Vector3(r,g,b))
	setMaterialColor(spellMaterialOff,Vector3(r,g,b))
	setMaterialColor(spellMaterialOn,Vector3(r,g,b))
	setMaterialColor(spellMaterialStar,Vector3(r,g,b))
	setMaterialColor(spellMaterialLine,Vector3(r,g,b))
	setMaterialColor(spellMaterialWandStar,Vector3(r,g,b))
func setMaterialColor(material,color:Vector3):
	material.albedo_color.r=color.x
	material.albedo_color.g=color.y
	material.albedo_color.b=color.z
func _physics_process(delta: float) -> void:
	spellStar.rotation.y+=delta*10
	#spellLine.rotation.y+=delta*2
	spellBase.rotation.y=lerp_angle(spellBase.rotation.y,camPivot.rotation.y,10*delta)
	var input_dir = Input.get_vector("left","right","forward","backward")
	if Input.is_action_pressed("magic"):
		if not PlayerGlobalManager.casting:
			animator.play("SpellReady",0.2)
		playerModel.rotation.y=lerp_angle(playerModel.rotation.y,camPivot.rotation.y,20*delta)
		PlayerGlobalManager.casting=true
		if PlayerGlobalManager.spellDirs.size()<0:
			PlayerGlobalManager.spellDirs.append(1)
		groundSpellTransparency(1,delta)
		addSpellDirections()
		input_dir = Vector2.ZERO
	else:
		if PlayerGlobalManager.casting:
			if chargedSpell=="Flare":
				var fireballSpawned = fireball.instantiate()
				get_parent().add_child(fireballSpawned)
				fireballSpawned.move_dir = Vector3(sin(playerModel.rotation.y+PI),0,cos(playerModel.rotation.y+PI))
				fireballSpawned.position = position
		chargedSpell= ""
		if input_dir:
			playerModel.rotation.y=lerp_angle(playerModel.rotation.y,-input_dir.rotated(-camPivot.rotation.y).angle()-PI/2,delta*10)
		PlayerGlobalManager.casting=false
		if PlayerGlobalManager.spellDirs.size()>0:
			PlayerGlobalManager.spellDirs.clear()
		groundSpellTransparency(0,delta)
		spellPoint1.material=spellMaterialOff
		spellPoint2.material=spellMaterialOff
		spellPoint3.material=spellMaterialOff
		spellPoint4.material=spellMaterialOff
		spellColor(0,true)
	var move_dir = (transform.basis*Vector3(input_dir.x,0,input_dir.y)).normalized().rotated(Vector3.UP,camPivot.rotation.y)
	var runSpeedApply := 1.0
	if Input.is_action_pressed("Sprint"):
		runSpeedApply = runSpeedMult
	velocity.x=move_dir.x*topSpeed*runSpeedApply
	velocity.z=move_dir.z*topSpeed*runSpeedApply
	if is_on_floor():
		if velocity.y<0:
			velocity.y=0
	else:
		velocity.y-=gravityForce*delta
	animate()
	move_and_slide()
	
func addSpellDirections():
	if Input.is_action_just_pressed("forward") and not PlayerGlobalManager.spellDirs.has(1):
		PlayerGlobalManager.spellDirs.append(1)
		animator.play("SpellUp",0.1)
		if PlayerGlobalManager.spellDirs.size()==4:
			spellFinish()
		else:
			playerSFX.stream=sfxSpellU
			playerSFX.play()
	if Input.is_action_just_pressed("right") and not PlayerGlobalManager.spellDirs.has(2):
		PlayerGlobalManager.spellDirs.append(2)
		animator.play("SpellRight",0.1)
		if PlayerGlobalManager.spellDirs.size()==4:
			spellFinish()
		else:
			playerSFX.stream=sfxSpellR
			playerSFX.play()
	if Input.is_action_just_pressed("backward") and not PlayerGlobalManager.spellDirs.has(3):
		PlayerGlobalManager.spellDirs.append(3)
		animator.play("SpellDown",0.1)
		if PlayerGlobalManager.spellDirs.size()==4:
			spellFinish()
		else:
			playerSFX.stream=sfxSpellD
			playerSFX.play()
	if Input.is_action_just_pressed("left") and not PlayerGlobalManager.spellDirs.has(4):
		animator.play("SpellLeft",0.1)
		PlayerGlobalManager.spellDirs.append(4)
		if PlayerGlobalManager.spellDirs.size()==4:
			spellFinish()
		else:
			playerSFX.stream=sfxSpellL
			playerSFX.play()
	if PlayerGlobalManager.spellDirs.size()>0:
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==1:
			spellPoint1.material=spellMaterialOn
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==2:
			spellPoint2.material=spellMaterialOn
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==3:
			spellPoint3.material=spellMaterialOn
		if PlayerGlobalManager.spellDirs[PlayerGlobalManager.spellDirs.size()-1]==4:
			spellPoint4.material=spellMaterialOn
func spellFinish():
	var spellSequence = PlayerGlobalManager.spellDirs[3]+PlayerGlobalManager.spellDirs[2]*10+PlayerGlobalManager.spellDirs[1]*100+PlayerGlobalManager.spellDirs[0]*1000
	print(spellSequence)
	print(spellNames[spellCombos.find(spellSequence)])
	chargedSpell= spellNames[spellCombos.find(spellSequence)]
	if spellCombos.has(spellSequence):
		if PlayerGlobalManager.spellDirs[3]==1:
			playerSFX.stream=sfxSpellUF
		if PlayerGlobalManager.spellDirs[3]==2:
			playerSFX.stream=sfxSpellRF
		if PlayerGlobalManager.spellDirs[3]==3:
			playerSFX.stream=sfxSpellDF
		if PlayerGlobalManager.spellDirs[3]==4:
			playerSFX.stream=sfxSpellLF
		spellColor(spellCombos.find(spellSequence),false)
	else:
		playerSFX.stream=sfxSpellFail
	playerSFX.play()

func animate():
	if not PlayerGlobalManager.casting:
		if is_on_floor():
			if velocity.length()>0.1:
				if Input.is_action_pressed("Sprint"):
					animator.play("Run",0.2,velocity.length()/4)
				else:
					animator.play("Walk",0.2,velocity.length()/3)
			else:
				animator.play("Idle",0.2,1)
		else:
			if velocity.y>0:
				animator.play("Jump",0.2,velocity.length()/8)
			else:
				animator.play("Fall",0.2,velocity.length()/8)
