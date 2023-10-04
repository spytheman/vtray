module vtray

$if windows {
	#define TRAY_WINAPI 1
}

$if linux {
	#define TRAY_APPINDICATOR 1
	#pkgconfig gtk+-2.0
	#pkgconfig appindicator3-0.1
}

$if macos {
	#define TRAY_APPKIT 1
}

#include "@VMODROOT/src/zserge_tray/tray.h"

type FnCTrayMenuCb = fn (pmenu &C.tray_menu)

pub struct C.tray {
pub mut:
	icon &char
	menu &C.tray_menu
}

// Note: menu arrays must be terminated with a NULL item, e.g. the last item in the array must have text field set to NULL.
pub struct C.tray_menu {
pub mut:
	text     &char
	disabled int
	checked  int

	cb      FnCTrayMenuCb
	context voidptr

	submenu &C.tray_menu
}

// C.tray_init creates tray icon. Returns -1 if tray icon/menu can't be created.
fn C.tray_init(ptray &C.tray) int

// C.tray_update updates the tray icon and its menu
fn C.tray_update(ptray &C.tray)

// C.tray_loop runs one iteration of the UI loop. Returns -1 if tray_exit() has been
fn C.tray_loop(blocking int) int

// C.tray_exit terminates UI loop
fn C.tray_exit()

pub struct Tray {
pub mut:
	ctray C.tray = C.tray{
		icon: 0
		menu: 0
	}
	mitems []MenuItem
}

pub fn new() &Tray {
	return &Tray{}
}

type FnTrayMenuCb = fn (mut mi MenuItem)

[params]
pub struct MenuItem {
pub mut:
	text     string
	disabled int
	checked  int
	cb       FnTrayMenuCb = unsafe { nil }
	submenu  []MenuItem
}

pub fn new_menu_item(params MenuItem) MenuItem {
	return MenuItem{
		...params
	}
}

pub fn (mut t Tray) set_icon(path string) {
	t.ctray.icon = path.str
}

pub fn (mut t Tray) init() int {
	return C.tray_init(&t.ctray)
}

pub fn (mut t Tray) update() {
	t.set_menu(t.mitems)
	C.tray_update(&t.ctray)
}

pub fn (mut t Tray) exit() {
	C.tray_exit()
}

pub fn (mut t Tray) loop(blocking int) int {
	return C.tray_loop(blocking)
}

pub fn (mut t Tray) set_menu(menu_items []MenuItem) {
	t.mitems = menu_items
	t.ctray.menu = t.menuitems_v2c(t.mitems)
}

fn (mut t Tray) menuitems_v2c(mitems []MenuItem) &C.tray_menu {
	if mitems.len == 0 {
		return unsafe { nil }
	}
	mut citems := []C.tray_menu{len: mitems.len + 1}
	for i in 0 .. mitems.len {
		mut c := &mitems[i]
		// eprintln('>>> i: $i | c: ${voidptr(c)}')
		mut ci := unsafe { &C.tray_menu(&citems[i]) }
		ci.context = c
		ci.submenu = t.menuitems_v2c(c.submenu)
		ci.text = c.text.str
		ci.disabled = c.disabled
		ci.checked = c.checked
		ci.cb = fn (pcm &C.tray_menu) {
			mut c := unsafe { &MenuItem(pcm.context) }
			if c != unsafe { nil } && c.cb != unsafe { nil } {
				c.cb(mut c)
			}
		}
	}
	citems[mitems.len].text = unsafe { nil }
	return citems.data
}
