class_name Dungeon
extends RefCounted

const BOSS_FLOOR := 10
const BOSS_DANGER := 40.0
const BAG_SIZE := 4


static func floor_danger(f: int, rng: RandomNumberGenerator) -> float:
	if f == BOSS_FLOOR:
		return BOSS_DANGER
	return 4.0 + f * 3.2 + rng.randf_range(-2.0, 3.0)


## Sends one adventurer down from the top. Mutates the adventurer and returns
## {died, depth, boss, text}.
static func run(adv: Adventurer, rng: RandomNumberGenerator) -> Dictionary:
	adv.hp = adv.max_hp()
	adv.loot_gold = 0
	var depth := 0
	var died := false
	var boss := false
	var drank := 0
	var leveled := false
	var found := 0
	while true:
		var f := depth + 1
		var danger := floor_danger(f, rng)
		var atk := adv.attack()
		var dmg := maxf(3.0, danger * 1.5 - adv.defense()) * rng.randf_range(0.75, 1.25)
		if atk < danger:
			dmg *= 1.0 + (danger - atk) * 0.15
		adv.hp -= dmg
		if adv.hp <= 0.0 and not adv.potions.is_empty():
			var p: Item = adv.potions.pop_back()
			adv.hp = adv.max_hp() * p.power() / 100.0
			drank += 1
		if adv.hp <= 0.0:
			died = true
			depth = f
			break
		depth = f
		if f == BOSS_FLOOR:
			boss = true
			break
		if adv.loot.size() < BAG_SIZE and rng.randf() < 0.55 + adv.luck() * 0.03:
			adv.loot.append(Item.random_loot(f, rng))
			found += 1
		adv.loot_gold += int(f * rng.randf_range(2.0, 6.0) * (1.0 + adv.luck() * 0.05))
		if adv.gain_xp(f):
			leveled = true
		if adv.hp < adv.max_hp() * adv.retreat_at():
			break
	adv.best_depth = maxi(adv.best_depth, depth)

	var text := ""
	if boss:
		text = "[color=#f0c040]%s llegó al piso %d y derrotó al Señor de la Mazmorra.[/color]" % [adv.title(), depth]
	elif died:
		text = "[color=#e05050]%s murió en el piso %d.[/color]" % [adv.title(), depth]
	else:
		text = "%s llegó al piso %d y volvió con %d objeto(s) y %d de oro." % [adv.title(), depth, found, adv.loot_gold]
		if leveled:
			text += " Subió de nivel."
	if drank > 0:
		text += " Usó %d poción(es)." % drank
	return {"died": died, "depth": depth, "boss": boss, "text": text}
