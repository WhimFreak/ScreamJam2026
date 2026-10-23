class_name BaseDialogue extends Resource


const CALM_CUTE_GIRL__LONG_ = preload("uid://een5bkj7ap6")
const DEMON_VOICE__LONG_ = preload("uid://bdw1i2a1fyd3e")
const ENERGETIC_GIRL_VOICE__LONG_ = preload("uid://dq4onou3d1n0x")
const FUNKY_MAN_VOICE_1__LONG_ = preload("uid://cafdmuy66bfns")
const NORMAL_MAN_VOICE__LONG_ = preload("uid://bnmdpjo2onaij")
const OLD_AGE_GRANNY__LONG_ = preload("uid://0tf1liw4fv8i")










@export var character_name := ""
@export var portrait : Texture2D = null

@export_multiline var text := ""


@export_group("sounds")
@export var dialogue_sound : AudioStream = null
@export var sound_effect: AudioStream = null
