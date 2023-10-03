import vtray

mut t := vtray.new()
t.set_icon('/home/delian/code/vtray/src/zserge_tray/icon.png')
//t.set_icon('indicator-messages')
t.set_menu([
	vtray.new_menu_item(text: 'abc')
	vtray.new_menu_item(text: 'def', disabled: 1)
	vtray.new_menu_item(text: 'xyz')
	vtray.new_menu_item()
])
dump(t)
dump(t.init())
for t.loop(1) == 0 {
	eprintln('> iteration')
}
t.exit()
