## Headless balance check: plays many games with a simple shopkeeper bot.
## Run: godot --headless --path . --script res://tests/sim.gd
extends SceneTree


func _init() -> void:
	var games := 300
	var wins := 0
	var rent_losses := 0
	var timeouts := 0
	var days_total := 0
	var deaths := 0
	var record_total := 0
	for s in games:
		var g := Game.new()
		g.start(s + 1)
		var guard := 0
		while g.phase != Game.Phase.WON and g.phase != Game.Phase.LOST and guard < 5000:
			guard += 1
			_step(g)
		match g.phase:
			Game.Phase.WON:
				wins += 1
			Game.Phase.LOST:
				if g.end_reason.contains("renta"):
					rent_losses += 1
				else:
					timeouts += 1
		if guard >= 5000: print("atascado fase=%d" % g.phase)
		days_total += g.day
		deaths += g.fallen.size()
		record_total += g.record_depth
	print("Partidas: %d | victorias %d | sin renta %d | sin tiempo %d" % [games, wins, rent_losses, timeouts])
	print("Día medio final %.1f | muertes medias %.1f | récord medio %.1f" % [
		days_total / float(games), deaths / float(games), record_total / float(games)])
	quit()


func _step(g: Game) -> void:
	match g.phase:
		Game.Phase.BUY:
			var adv := g.customer()
			var it := g.current_item()
			var lowest := g.min_accept(it, adv)
			var ask := g.asking_price(it, adv)
			var bid := int(ask * 0.6)
			if bid > g.gold:
				g.pass_item()
				return
			var before := it
			g.offer(bid)
			if g.current_item() == before and g.customer() == adv:
				var second := mini(g.gold, int(ask * 0.85))
				if second >= lowest or second == g.gold:
					g.offer(second)
				else:
					g.pass_item()
		Game.Phase.SELL:
			var adv := g.customer()
			var best: Item = null
			for it in g.stock:
				if adv.is_upgrade(it) and (best == null or it.power() > best.power()):
					best = it
			if best == null:
				g.next_customer()
				return
			var p := mini(g.suggested_sale(best), adv.gold)
			if p >= int(best.value * 0.8):
				if not g.sell(best, p).begins_with("«Gracias"):
					g.next_customer()
			elif adv.level >= 3:
				g.lend(best)
			else:
				g.next_customer()
		Game.Phase.READY:
			g.run_expeditions()
		Game.Phase.REPORT:
			g.next_day()
