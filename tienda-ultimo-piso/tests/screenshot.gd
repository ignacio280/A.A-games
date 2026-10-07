## Saves screenshots of a few game phases to user:// (needs a display, e.g. xvfb-run).
## Run: godot --path . --script res://tests/screenshot.gd -- <out_dir>
extends SceneTree

var out_dir := "user://"


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out_dir = args[0]
	var main: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	_run(main)


func _run(main: Control) -> void:
	await process_frame
	var g: Game = main.game
	g.start(7)
	main.log_box.clear()
	await _snap("1_tarde")
	if not g.stock.is_empty():
		main._on_stock_selected(0)
		main._on_a()
	await _snap("2_venta")
	while g.phase == Game.Phase.SELL:
		g.next_customer()
	await _snap("3_noche")
	g.run_expeditions()
	await _snap("4_informe")
	g.next_day()
	if g.phase == Game.Phase.BUY:
		main._on_a()
	await _snap("5_compra")
	quit()


func _snap(tag: String) -> void:
	for i in 4:
		await process_frame
	var img := root.get_texture().get_image()
	img.save_png(out_dir.path_join(tag + ".png"))
