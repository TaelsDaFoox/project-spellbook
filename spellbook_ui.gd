extends Control
@onready var spellbook = $SubViewport/spellbook
@onready var spellbookleftpage = $SubViewport/spellbook/Armature/Skeleton3D/FrontPagesRender
var spellbookTimer := 0.0
func _physics_process(delta: float) -> void:
	spellbook.rotation.y=sin(spellbookTimer)/12
	spellbook.rotation.x=cos(spellbookTimer*0.9)/12
	spellbookTimer+=delta
