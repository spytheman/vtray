import time
import vtray

mut t := vtray.new()
t.set_icon(@VMODROOT + '/examples/smiley.png')
t.set_menu([
	vtray.new_menu_item(text: 'should be checked', checked: 1),
	vtray.new_menu_item(
		text: 'click me'
		cb: fn [mut t] (omi &vtray.MenuItem) {
			mut mi := unsafe { omi }
			t.set_icon('indicator-messages')
			mi.text = time.now().str()
			mi.checked = if mi.checked == 0 { 1 } else { 0 }
			t.update() // rebuild the whole menu, so that the change is visible
			dump(mi.text)
		}
	),
	vtray.new_menu_item(text: 'this should be disabled', disabled: 1),
	vtray.new_menu_item(text: '-', disabled: 1),
	vtray.new_menu_item(
		text: 'quit'
		cb: fn [mut t] (mi &vtray.MenuItem) {
			t.exit() // this will make t.loop() return 0, thus exiting the app
		}
	),
])
t.init()
for t.loop(1) == 0 {}
eprintln('good bye')
