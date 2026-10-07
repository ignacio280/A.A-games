extends Control

const C_BG := Color("1b1420")
const C_PANEL := Color("2a2030")
const C_ACCENT := Color("e0a84a")
const C_MUTED := Color("a89cb0")
const TIER_COLORS := [Color("c8c0b4"), Color("7ec26a"), Color("5aa0e0"), Color("b77ce0"), Color("f0a040")]

var game := Game.new()
var selected: Item

var lbl_day: Label
var lbl_gold: Label
var lbl_rep: Label
var lbl_record: Label
var lbl_rent: Label
var lbl_phase: Label
var stock_list: ItemList
var lbl_name: Label
var lbl_info: Label
var hp_bar: ProgressBar
var lbl_gear: Label
var dialog: RichTextLabel
var lbl_hint: Label
var lbl_reply: Label
var price_box: HBoxContainer
var price: SpinBox
var btn_a: Button
var btn_b: Button
var btn_c: Button
var btn_main: Button
var log_box: RichTextLabel


func _ready() -> void:
	_build_ui()
	game.logged.connect(func(t: String) -> void: log_box.append_text(t + "\n"))
	game.changed.connect(_refresh)
	game.start()


# --- Layout ------------------------------------------------------------------

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 10)
	margin.add_child(root)

	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 32)
	root.add_child(top)
	lbl_day = _label(top, 20, C_ACCENT)
	lbl_gold = _label(top, 20, Color("f0d060"))
	lbl_rep = _label(top, 18)
	lbl_record = _label(top, 18)
	lbl_rent = _label(top, 18, C_MUTED)

	lbl_phase = _label(root, 26, C_ACCENT)

	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 12)
	root.add_child(mid)

	var left := _panel(mid)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.8
	var lv := VBoxContainer.new()
	left.add_child(lv)
	_label(lv, 18, C_ACCENT).text = "Tu inventario"
	stock_list = ItemList.new()
	stock_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stock_list.add_theme_font_size_override("font_size", 16)
	stock_list.item_selected.connect(_on_stock_selected)
	lv.add_child(stock_list)

	var right := _panel(mid)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 8)
	right.add_child(rv)
	lbl_name = _label(rv, 24)
	lbl_info = _label(rv, 16, C_MUTED)
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(0, 14)
	hp_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("c04848")
	hp_bar.add_theme_stylebox_override("fill", fill)
	rv.add_child(hp_bar)
	lbl_gear = _label(rv, 15, C_MUTED)
	lbl_gear.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog = RichTextLabel.new()
	dialog.bbcode_enabled = true
	dialog.fit_content = true
	dialog.add_theme_font_size_override("normal_font_size", 18)
	dialog.add_theme_font_size_override("bold_font_size", 18)
	rv.add_child(dialog)
	lbl_hint = _label(rv, 15, Color("8fc0e0"))
	lbl_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_reply = _label(rv, 18, Color("f0e0b0"))
	lbl_reply.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rv.add_child(spacer)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	rv.add_child(actions)
	price_box = HBoxContainer.new()
	actions.add_child(price_box)
	_label(price_box, 16).text = "Precio:"
	price = SpinBox.new()
	price.min_value = 0
	price.max_value = 99999
	price.custom_minimum_size = Vector2(110, 0)
	price_box.add_child(price)
	btn_a = _button(actions, _on_a)
	btn_b = _button(actions, _on_b)
	btn_c = _button(actions, _on_c)
	btn_main = _button(actions, _on_main)

	var log_panel := _panel(root)
	log_panel.custom_minimum_size = Vector2(0, 150)
	log_box = RichTextLabel.new()
	log_box.bbcode_enabled = true
	log_box.scroll_following = true
	log_box.add_theme_font_size_override("normal_font_size", 14)
	log_box.add_theme_font_size_override("bold_font_size", 14)
	log_panel.add_child(log_box)


func _label(parent: Node, size: int, color: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l


func _panel(parent: Node) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_PANEL
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(12)
	p.add_theme_stylebox_override("panel", sb)
	parent.add_child(p)
	return p


func _button(parent: Node, cb: Callable) -> Button:
	var b := Button.new()
	b.add_theme_font_size_override("font_size", 16)
	b.custom_minimum_size = Vector2(0, 38)
	b.pressed.connect(cb)
	parent.add_child(b)
	return b


# --- Refresh -----------------------------------------------------------------

func _refresh() -> void:
	lbl_day.text = "Día %d / %d" % [game.day, Game.MAX_DAYS]
	lbl_gold.text = "Oro: %d" % game.gold
	lbl_rep.text = "Reputación: %d" % game.reputation
	lbl_record.text = "Récord: piso %d / %d" % [game.record_depth, Dungeon.BOSS_FLOOR]
	lbl_rent.text = "Renta: %d de oro el día %d" % [game.next_rent(), game.next_rent_day()]
	_fill_stock()
	for b in [btn_a, btn_b, btn_c, btn_main]:
		b.visible = false
	price_box.visible = false
	lbl_hint.text = ""
	hp_bar.visible = true

	match game.phase:
		Game.Phase.BUY:
			var adv := game.customer()
			var it := game.current_item()
			lbl_phase.text = "Mañana · Llegan los heridos con su botín"
			_show_customer(adv)
			var ask := game.asking_price(it, adv)
			dialog.text = "«Traigo esto de abajo: [b][color=#%s]%s[/color][/b]. Pido [b]%d[/b] de oro.»\n[color=#a89cb0]Vale unos %d. Le quedan %d objeto(s) por ofrecer.[/color]" % [
				TIER_COLORS[it.tier - 1].to_html(false), it.describe(), ask, it.value, adv.loot.size()]
			lbl_hint.text = "Cuanto más herido venga, más barato aceptará. Paciencia: %d intento(s)." % adv.patience
			price_box.visible = true
			price.value = int(ask * 0.6)
			_show(btn_a, "Ofrecer")
			_show(btn_b, "Pagar %d" % ask)
			_show(btn_c, "No me interesa")
		Game.Phase.SELL:
			var adv := game.customer()
			lbl_phase.text = "Tarde · Se preparan para bajar (%d en la fila)" % game.queue.size()
			_show_customer(adv)
			dialog.text = "«Busco [b]%s[/b]. Tengo [b]%d[/b] de oro.»" % [Item.KIND_LABEL[adv.wants()], adv.gold]
			price_box.visible = true
			_update_sell_hint()
			_show(btn_a, "Vender")
			_show(btn_b, "Prestar (%d%% de su oro)" % int(Game.LEND_CUT * 100))
			_show(btn_c, "Siguiente")
		Game.Phase.READY:
			lbl_phase.text = "Noche · La puerta de la mazmorra"
			lbl_name.text = "Esta noche bajan %d aventurero(s)" % game.roster.size()
			lbl_info.text = ""
			hp_bar.visible = false
			lbl_gear.text = ""
			var lines: Array[String] = []
			for a in game.roster:
				lines.append("[b]%s[/b]  ataque %d · defensa %d · suerte %d · pociones %d" % [a.title(), a.attack(), a.defense(), a.luck(), a.potions.size()])
			dialog.text = "\n".join(lines)
			_show(btn_main, "Abrir la puerta")
		Game.Phase.REPORT:
			lbl_phase.text = "Informe de la noche"
			lbl_name.text = "Al amanecer..."
			lbl_info.text = ""
			hp_bar.visible = false
			lbl_gear.text = ""
			dialog.text = "\n".join(game.report)
			_show(btn_main, "Abrir la tienda (día %d)" % game.day)
		Game.Phase.WON, Game.Phase.LOST:
			lbl_phase.text = "¡Victoria!" if game.phase == Game.Phase.WON else "Fin de la partida"
			lbl_name.text = ""
			lbl_info.text = ""
			hp_bar.visible = false
			lbl_gear.text = ""
			dialog.text = game.end_reason
			if not game.fallen.is_empty():
				dialog.text += "\n\n[color=#a89cb0]Caídos: %s[/color]" % ", ".join(game.fallen)
			_show(btn_main, "Nueva partida")
	for l in [lbl_name, lbl_info, lbl_gear]:
		l.visible = l.text != ""


func _show(b: Button, text: String) -> void:
	b.text = text
	b.visible = true


func _show_customer(adv: Adventurer) -> void:
	lbl_name.text = adv.title()
	lbl_info.text = "Ataque %d · Defensa %d · Suerte %d · Confianza %d · Oro %d · Mejor piso %d" % [
		adv.attack(), adv.defense(), adv.luck(), adv.trust, adv.gold, adv.best_depth]
	hp_bar.max_value = adv.max_hp()
	hp_bar.value = adv.hp
	lbl_gear.text = adv.gear_text()


func _fill_stock() -> void:
	stock_list.clear()
	var keep := -1
	for i in game.stock.size():
		var it: Item = game.stock[i]
		stock_list.add_item("%s · %d oro" % [it.describe(), it.value])
		stock_list.set_item_custom_fg_color(i, TIER_COLORS[it.tier - 1])
		if it == selected:
			keep = i
	if keep >= 0:
		stock_list.select(keep)
	else:
		selected = null


func _update_sell_hint() -> void:
	var adv := game.customer()
	if adv == null or game.phase != Game.Phase.SELL:
		return
	if selected == null:
		lbl_hint.text = "Elige un objeto de tu inventario para ofrecérselo."
		return
	lbl_hint.text = adv.compare_text(selected)


# --- Input -------------------------------------------------------------------

func _on_stock_selected(index: int) -> void:
	selected = game.stock[index]
	if game.phase == Game.Phase.SELL:
		price.value = game.suggested_sale(selected)
		_update_sell_hint()


func _on_a() -> void:
	match game.phase:
		Game.Phase.BUY:
			_reply(game.offer(int(price.value)))
		Game.Phase.SELL:
			if selected == null:
				_reply("Primero elige un objeto de tu inventario.")
				return
			_reply(game.sell(selected, int(price.value)))


func _on_b() -> void:
	match game.phase:
		Game.Phase.BUY:
			var it := game.current_item()
			_reply(game.offer(game.asking_price(it, game.customer())))
		Game.Phase.SELL:
			if selected == null:
				_reply("Primero elige un objeto de tu inventario.")
				return
			_reply(game.lend(selected))


func _on_c() -> void:
	match game.phase:
		Game.Phase.BUY:
			game.pass_item()
		Game.Phase.SELL:
			game.next_customer()
	_reply("")


func _on_main() -> void:
	_reply("")
	match game.phase:
		Game.Phase.READY:
			game.run_expeditions()
		Game.Phase.REPORT:
			game.next_day()
		Game.Phase.WON, Game.Phase.LOST:
			log_box.clear()
			game.start()


func _reply(text: String) -> void:
	lbl_reply.text = text
