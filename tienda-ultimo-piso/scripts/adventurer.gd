class_name Adventurer
extends RefCounted

enum Cls { WARRIOR, ROGUE, MAGE, CLERIC }

const CLASS_LABEL_M := ["Guerrero", "Pícaro", "Mago", "Clérigo"]
const CLASS_LABEL_F := ["Guerrera", "Pícara", "Maga", "Clériga"]
const CLASS_ATK := [2, 1, 4, 0]
const CLASS_DEF := [2, 0, 0, 3]
const CLASS_LUCK := [0, 4, 0, 1]
const CLASS_RETREAT := [0.30, 0.50, 0.40, 0.35]
const CLASS_FAVORITE := [Item.Kind.WEAPON, Item.Kind.CHARM, Item.Kind.WEAPON, Item.Kind.ARMOR]
const NAMES_M := ["Aldo", "Bruno", "Ciro", "Darío", "Emilio", "Fausto", "Gael", "Hugo", "Iker", "Joaquín", "León", "Mateo", "Nico", "Óscar", "Rufo", "Teo"]
const NAMES_F := ["Alba", "Bea", "Carla", "Dana", "Elsa", "Flor", "Greta", "Inés", "Julia", "Lía", "Mara", "Nora", "Olga", "Rita", "Sol", "Vera"]
const MAX_POTIONS := 2

var name: String
var female := false
var cls: int
var level := 1
var xp := 0
var hp := 1.0
var gold := 0
var trust := 50:
	set(v):
		trust = clampi(v, 0, 100)
var alive := true
var weapon: Item
var armor: Item
var charm: Item
var potions: Array[Item] = []
var loot: Array[Item] = []
var loot_gold := 0
var lent: Array[Item] = []
var shop_gear := false
var best_depth := 0
var patience := 2


static func recruit(rng: RandomNumberGenerator, lvl: int, taken: Array[String] = []) -> Adventurer:
	var a := Adventurer.new()
	a.female = rng.randf() < 0.5
	var pool: Array = (NAMES_F if a.female else NAMES_M).filter(func(n: String) -> bool: return not taken.has(n))
	if pool.is_empty():
		pool = NAMES_F if a.female else NAMES_M
	a.name = pool[rng.randi() % pool.size()]
	a.cls = rng.randi() % 4
	a.level = lvl
	a.gold = rng.randi_range(25, 60) + lvl * 15
	a.trust = rng.randi_range(40, 60)
	if rng.randf() < 0.5:
		a.weapon = Item.make(Item.Kind.WEAPON, 1, rng)
	a.hp = a.max_hp()
	return a


func class_label() -> String:
	return CLASS_LABEL_F[cls] if female else CLASS_LABEL_M[cls]


func title() -> String:
	return "%s, %s nv. %d" % [name, class_label(), level]


func max_hp() -> float:
	return 30.0 + level * 8.0


func hp_ratio() -> float:
	return clampf(hp / max_hp(), 0.0, 1.0)


func attack() -> int:
	return level * 2 + CLASS_ATK[cls] + (weapon.power() if weapon else 0)


func defense() -> int:
	return level + CLASS_DEF[cls] + (armor.power() if armor else 0)


func luck() -> int:
	return CLASS_LUCK[cls] + (charm.power() if charm else 0)


func retreat_at() -> float:
	return CLASS_RETREAT[cls]


func slot(kind: int) -> Item:
	match kind:
		Item.Kind.WEAPON:
			return weapon
		Item.Kind.ARMOR:
			return armor
		Item.Kind.CHARM:
			return charm
	return null


func is_upgrade(item: Item) -> bool:
	if item.kind == Item.Kind.POTION:
		return potions.size() < MAX_POTIONS
	var current := slot(item.kind)
	return current == null or item.power() > current.power()


func compare_text(item: Item) -> String:
	if item.kind == Item.Kind.POTION:
		if is_upgrade(item):
			return "Lleva %d de %d pociones." % [potions.size(), MAX_POTIONS]
		return "Ya lleva todas las pociones que puede."
	var current := slot(item.kind)
	if current == null:
		return "No tiene %s: %s." % [Item.KIND_LABEL[item.kind], item.stat_text()]
	var diff := item.power() - current.power()
	if diff > 0:
		return "Mejora en %d sobre su %s." % [diff, current.name]
	return "Su %s ya es igual o mejor." % current.name


## Equips the item and returns whatever it replaced (null if the slot was empty).
func equip(item: Item) -> Item:
	var old: Item = null
	match item.kind:
		Item.Kind.WEAPON:
			old = weapon
			weapon = item
		Item.Kind.ARMOR:
			old = armor
			armor = item
		Item.Kind.CHARM:
			old = charm
			charm = item
		Item.Kind.POTION:
			potions.append(item)
	return old


## Removes the item if still carried; false when it was used up or lost.
func unequip(item: Item) -> bool:
	if weapon == item:
		weapon = null
	elif armor == item:
		armor = null
	elif charm == item:
		charm = null
	elif potions.has(item):
		potions.erase(item)
	else:
		return false
	return true


func wants() -> int:
	if weapon == null:
		return Item.Kind.WEAPON
	if armor == null:
		return Item.Kind.ARMOR
	if potions.is_empty():
		return Item.Kind.POTION
	if charm == null:
		return Item.Kind.CHARM
	return CLASS_FAVORITE[cls]


func gain_xp(amount: int) -> bool:
	xp += amount
	var leveled := false
	while xp >= level * 5:
		xp -= level * 5
		level += 1
		leveled = true
	return leveled


func gear_text() -> String:
	var parts: Array[String] = []
	parts.append("Arma: %s" % (weapon.name if weapon else "—"))
	parts.append("Armadura: %s" % (armor.name if armor else "—"))
	parts.append("Amuleto: %s" % (charm.name if charm else "—"))
	parts.append("Pociones: %d" % potions.size())
	return "   ".join(parts)
