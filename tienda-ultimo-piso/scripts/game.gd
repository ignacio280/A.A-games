class_name Game
extends RefCounted

signal logged(text: String)
signal changed

enum Phase { BUY, SELL, READY, REPORT, WON, LOST }

const MAX_DAYS := 30
const RENT_EVERY := 5
const RENTS := [50, 100, 160, 240, 330, 440]
const LEND_CUT := 0.3
const START_GOLD := 150

var rng := RandomNumberGenerator.new()
var day := 1
var gold := START_GOLD
var reputation := 20
var record_depth := 0
var stock: Array[Item] = []
var roster: Array[Adventurer] = []
var fallen: Array[String] = []
var phase: int = Phase.BUY
var queue: Array[Adventurer] = []
var report: Array[String] = []
var end_reason := ""


func start(seed_value: int = 0) -> void:
	if seed_value != 0:
		rng.seed = seed_value
	else:
		rng.randomize()
	day = 1
	gold = START_GOLD
	reputation = 20
	record_depth = 0
	end_reason = ""
	stock.clear()
	roster.clear()
	fallen.clear()
	report.clear()
	for k in [Item.Kind.WEAPON, Item.Kind.ARMOR, Item.Kind.WEAPON, Item.Kind.POTION]:
		stock.append(Item.make(k, rng.randi_range(1, 2), rng))
	for i in 3:
		roster.append(Adventurer.recruit(rng, 1, _names()))
	_log("[b]Día 1.[/b] Abres la tienda en lo alto de la mazmorra. Tres aventureros se preparan para bajar.")
	begin_day()


# --- Queries -----------------------------------------------------------------

func customer() -> Adventurer:
	return queue[0] if not queue.is_empty() else null


func current_item() -> Item:
	var adv := customer()
	if adv == null or adv.loot.is_empty():
		return null
	return adv.loot[0]


func asking_price(item: Item, adv: Adventurer) -> int:
	return int(round(item.value * (0.8 + 0.3 * adv.hp_ratio())))


## Lowest price the seller will take: the more wounded, the more desperate.
func min_accept(item: Item, adv: Adventurer) -> int:
	var ratio := clampf(0.3 + 0.5 * adv.hp_ratio() - (adv.trust - 50) * 0.004, 0.15, 0.95)
	return maxi(1, int(round(item.value * ratio)))


## Highest price a buyer will pay before calling it a rip-off.
func max_pay(item: Item, adv: Adventurer) -> int:
	return int(round(item.value * (1.2 + adv.trust * 0.006)))


func suggested_sale(item: Item) -> int:
	return int(round(item.value * 1.2))


func next_rent_day() -> int:
	return int(ceil(day / float(RENT_EVERY))) * RENT_EVERY


func next_rent() -> int:
	var idx := next_rent_day() / RENT_EVERY - 1
	return RENTS[mini(idx, RENTS.size() - 1)]


# --- Morning: buying loot ----------------------------------------------------

func begin_day() -> void:
	queue.clear()
	for a in roster:
		if not a.loot.is_empty():
			a.patience = 2
			queue.append(a)
	if queue.is_empty():
		begin_sell_phase()
		return
	phase = Phase.BUY
	changed.emit()


func offer(amount: int) -> String:
	var adv := customer()
	var it := current_item()
	if adv == null or it == null:
		return ""
	if amount > gold:
		return "No tienes tanto oro."
	var ask := asking_price(it, adv)
	var lowest := min_accept(it, adv)
	if amount >= lowest:
		gold -= amount
		adv.gold += amount
		adv.loot.pop_front()
		stock.append(it)
		if amount >= ask:
			adv.trust += 4
		elif amount < (ask + lowest) / 2:
			adv.trust -= 1
		_log("Compraste %s a %s por %d de oro." % [it.name, adv.name, amount])
		var reply := "«Trato hecho.»"
		_advance_buy()
		return reply
	adv.patience -= 1
	adv.trust -= 3
	if adv.patience <= 0:
		adv.loot.pop_front()
		adv.patience = 2
		_log("%s se llevó %s al mercader de los pisos de abajo." % [adv.name, it.name])
		_advance_buy()
		return "«Olvídalo. Se lo vendo a otro.»"
	changed.emit()
	if amount < lowest * 0.6:
		return "«¿%d? ¡Eso es un insulto!»" % amount
	return "«Casi... sube un poco.»"


func pass_item() -> void:
	var adv := customer()
	if adv == null or adv.loot.is_empty():
		return
	var it: Item = adv.loot.pop_front()
	_log("No quisiste %s de %s." % [it.name, adv.name])
	_advance_buy()


func _advance_buy() -> void:
	var adv := customer()
	if adv != null and adv.loot.is_empty():
		queue.pop_front()
	if queue.is_empty():
		begin_sell_phase()
	else:
		changed.emit()


# --- Afternoon: arming adventurers -------------------------------------------

func begin_sell_phase() -> void:
	queue.clear()
	for a in roster:
		if a.alive:
			a.hp = a.max_hp()
			queue.append(a)
	phase = Phase.SELL if not queue.is_empty() else Phase.READY
	changed.emit()


func sell(item: Item, price: int) -> String:
	var adv := customer()
	if adv == null or item == null:
		return ""
	if not adv.is_upgrade(item):
		return "«No me sirve, ya tengo algo igual o mejor.»"
	if price > adv.gold:
		return "«No me alcanza, solo tengo %d de oro.»" % adv.gold
	if price > max_pay(item, adv):
		adv.trust -= 2
		changed.emit()
		return "«¿%d por eso? Ni en sueños.»" % price
	gold += price
	adv.gold -= price
	stock.erase(item)
	var old := adv.equip(item)
	if old != null:
		adv.loot.append(old)
	adv.shop_gear = true
	if price <= item.value:
		adv.trust += 3
	_log("Vendiste %s a %s por %d de oro." % [item.name, adv.name, price])
	changed.emit()
	return "«Gracias. Con esto llegaré más hondo.»"


func lend(item: Item) -> String:
	var adv := customer()
	if adv == null or item == null:
		return ""
	if not adv.is_upgrade(item):
		return "«No me sirve, ya tengo algo igual o mejor.»"
	stock.erase(item)
	var old := adv.equip(item)
	if old != null:
		adv.loot.append(old)
	adv.lent.append(item)
	adv.shop_gear = true
	adv.trust += 6
	_log("Prestaste %s a %s a cambio del %d%% de su oro." % [item.name, adv.name, int(LEND_CUT * 100)])
	changed.emit()
	return "«¡Te lo devuelvo con intereses!»"


func next_customer() -> void:
	if not queue.is_empty():
		queue.pop_front()
	if queue.is_empty():
		phase = Phase.READY
	changed.emit()


# --- Night: the expedition ---------------------------------------------------

func run_expeditions() -> void:
	report.clear()
	var won_by: Adventurer = null
	var survivors: Array[Adventurer] = []
	for adv in roster:
		if not adv.alive:
			continue
		var r := Dungeon.run(adv, rng)
		var line: String = r.text
		record_depth = maxi(record_depth, r.depth)
		if r.died:
			adv.alive = false
			fallen.append(adv.name)
			if adv.shop_gear:
				reputation -= 8
				line += " Llevaba tu equipo."
			if not adv.lent.is_empty():
				line += " Perdiste lo que le prestaste."
		else:
			survivors.append(adv)
			reputation += 3 if adv.shop_gear else 1
			var cut := 0
			if not adv.lent.is_empty():
				cut = int(adv.loot_gold * LEND_CUT)
				var back := 0
				for it in adv.lent:
					if adv.unequip(it):
						stock.append(it)
						back += 1
				line += " Te devolvió %d objeto(s) prestado(s) y %d de oro." % [back, cut]
				gold += cut
			adv.gold += adv.loot_gold - cut
			if r.boss:
				won_by = adv
		adv.lent.clear()
		report.append(line)
		_log(line)
	roster = survivors
	reputation = clampi(reputation, 0, 100)

	if won_by != null:
		phase = Phase.WON
		end_reason = "%s derrotó al Señor de la Mazmorra el día %d. Tu tienda será leyenda." % [won_by.name, day]
		_log("[color=#f0c040][b]¡Victoria![/b][/color] " + end_reason)
		changed.emit()
		return

	if day % RENT_EVERY == 0:
		var rent := next_rent()
		if gold < rent:
			phase = Phase.LOST
			end_reason = "No pudiste pagar los %d de oro de renta al Gremio el día %d. Te quitaron la tienda." % [rent, day]
			_log("[color=#e05050][b]Derrota.[/b][/color] " + end_reason)
			changed.emit()
			return
		gold -= rent
		report.append("Pagaste %d de oro de renta al Gremio." % rent)
		_log("Pagaste %d de oro de renta al Gremio." % rent)

	day += 1
	if day > MAX_DAYS:
		phase = Phase.LOST
		end_reason = "Pasaron %d días y nadie derrotó al Señor de la Mazmorra. El Gremio cierra la mazmorra." % MAX_DAYS
		_log("[color=#e05050][b]Derrota.[/b][/color] " + end_reason)
		changed.emit()
		return

	_recruit()
	phase = Phase.REPORT
	changed.emit()


func _recruit() -> void:
	var cap := clampi(3 + reputation / 20, 3, 7)
	var arrivals := 0
	while roster.size() < cap and arrivals < 2:
		var lvl := 1 + rng.randi_range(0, reputation / 30)
		var a := Adventurer.recruit(rng, lvl, _names())
		roster.append(a)
		arrivals += 1
		var line := "Llegó %s, atraído por la fama de tu tienda." % a.title()
		report.append(line)
		_log(line)


func _names() -> Array[String]:
	var out: Array[String] = []
	for a in roster:
		out.append(a.name)
	return out


func next_day() -> void:
	_log("[b]Día %d.[/b]" % day)
	begin_day()


func _log(text: String) -> void:
	logged.emit(text)
