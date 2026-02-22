extends Control

@onready var contract_container = $Panel/ScrollContainer/ContractList

func _ready():
	ContractManager.contracts_updated.connect(_update_list)
	_update_list()

func _update_list():
	for child in contract_container.get_children():
		child.queue_free()
		
	var topbar = get_node_or_null("TopBar")
	if topbar and topbar.has_method("refresh_ui"):
		topbar.refresh_ui()
		
	var contracts = ContractManager.available_contracts
	for i in range(contracts.size()):
		var c = contracts[i]
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = "[%s] %s | Pay: $%d | Diff: %d" % [c.type.to_upper(), c.title, c.payout, c.difficulty]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var btn = Button.new()
		btn.text = "Accept"
		btn.pressed.connect(func(): _on_accept_pressed(i))
		
		hbox.add_child(label)
		hbox.add_child(btn)
		contract_container.add_child(hbox)

func _on_accept_pressed(idx):
	ContractManager.accept_contract(idx)

func _on_close_button_pressed():
	queue_free()
