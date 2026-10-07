class_name Item
extends RefCounted

enum Kind { WEAPON, ARMOR, CHARM, POTION }

const KIND_LABEL := ["arma", "armadura", "amuleto", "poción"]
const BASES := [
	["Espada", "Hacha", "Lanza", "Maza", "Daga"],
	["Cota", "Coraza", "Escudo", "Yelmo"],
	["Amuleto", "Anillo", "Talismán"],
	["Poción"],
]
const SUFFIX := [
	["de madera", "de hierro", "de acero", "de mithril", "del abismo"],
	["de cuero", "de hierro", "de acero", "de mithril", "del abismo"],
	["de hueso", "de cobre", "de plata", "de oro", "estelar"],
	["de hierbas", "curativa", "de troll", "de fénix", "de dragón"],
]
const KIND_VALUE := [1.0, 1.0, 1.2, 0.5]

var kind: int
var tier: int
var name: String
var value: int


static func make(kind_: int, tier_: int, rng: RandomNumberGenerator) -> Item:
	var it := Item.new()
	it.kind = kind_
	it.tier = clampi(tier_, 1, 5)
	var bases: Array = BASES[kind_]
	it.name = "%s %s" % [bases[rng.randi() % bases.size()], SUFFIX[kind_][it.tier - 1]]
	var base: float = (6.0 + 10.0 * it.tier * it.tier) * KIND_VALUE[kind_]
	it.value = int(round(base * rng.randf_range(0.85, 1.15)))
	return it


static func random_loot(depth: int, rng: RandomNumberGenerator) -> Item:
	var roll := rng.randf()
	var kind_ := Kind.WEAPON
	if roll < 0.3:
		kind_ = Kind.WEAPON
	elif roll < 0.6:
		kind_ = Kind.ARMOR
	elif roll < 0.8:
		kind_ = Kind.CHARM
	else:
		kind_ = Kind.POTION
	var tier_ := int(ceil(depth / 2.0)) + rng.randi_range(-1, 1)
	return make(kind_, tier_, rng)


func power() -> int:
	match kind:
		Kind.WEAPON, Kind.ARMOR:
			return tier * 3
		Kind.CHARM:
			return tier * 2
		Kind.POTION:
			return 25 + tier * 15
	return 0


func stat_text() -> String:
	match kind:
		Kind.WEAPON:
			return "+%d ataque" % power()
		Kind.ARMOR:
			return "+%d defensa" % power()
		Kind.CHARM:
			return "+%d suerte" % power()
		Kind.POTION:
			return "revive con %d%% de vida" % power()
	return ""


func describe() -> String:
	return "%s (%s)" % [name, stat_text()]
