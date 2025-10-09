extends CSGBox3D
@export var lineNum:int
@export var spellLineStraightLength:=3.5
@export var spellLineAngledLength:=2.5
@export var lerpSpeed:=20.0

func _physics_process(delta: float) -> void:
	if PlayerGlobalManager.spellDirs.size()>lineNum:
		visible = true
		if lineNum==0:
			rotation.y=(PlayerGlobalManager.spellDirs[lineNum]+2)*(PI/-2)
			size.x=lerp(size.x,spellLineStraightLength/2,delta*lerpSpeed)
			position.z=size.x/-2*sin(rotation.y)
			position.x=size.x/2*cos(rotation.y)
		else:
			visible = true
			if (PlayerGlobalManager.spellDirs[lineNum]-PlayerGlobalManager.spellDirs[lineNum-1])%2==0:
				#straight connectors
				rotation.y=(PlayerGlobalManager.spellDirs[lineNum]+2)*(PI/-2)
				size.x=lerp(size.x,spellLineStraightLength,delta*lerpSpeed)
				position.z=(sin(rotation.y)*spellLineStraightLength/2)*((spellLineStraightLength-size.x)/spellLineStraightLength)
				position.x=(cos(rotation.y)*spellLineStraightLength/-2)*((spellLineStraightLength-size.x)/spellLineStraightLength)
			else:
				#angled connectors
				size.x=lerp(size.x,spellLineAngledLength,delta*lerpSpeed)
				if PlayerGlobalManager.spellDirs[lineNum-1]>PlayerGlobalManager.spellDirs[lineNum]:
					rotation.y=(PlayerGlobalManager.spellDirs[lineNum])*(PI/-2)+PI/4
					if PlayerGlobalManager.spellDirs[lineNum-1]==4 and PlayerGlobalManager.spellDirs[lineNum]==1:
						rotation.y+=PI/2
					position.z=(cos(rotation.y)*-1.1)
					position.x=(sin(rotation.y)*-1.1)
				else:
					rotation.y=(PlayerGlobalManager.spellDirs[lineNum])*(PI/-2)-PI/4
					if PlayerGlobalManager.spellDirs[lineNum]==4 and PlayerGlobalManager.spellDirs[lineNum-1]==1:
						rotation.y-=PI/2
					position.z=(cos(rotation.y)*1.1)
					position.x=(sin(rotation.y)*1.1)
	else:
		visible = false
		size.x=lerp(size.x,0.01,delta*lerpSpeed)
