module vtray

$if windows {
#define TRAY_WINAPI 1
}

$if linux {
#define TRAY_APPINDICATOR 1
}

$if macos {
#define TRAY_APPKIT 1
}

#flag linux -I/usr/include/gtk-2.0
#flag linux -I/usr/lib/x86_64-linux-gnu/gtk-2.0/include
#flag linux -I/usr/include/glib-2.0
#flag linux -I/usr/lib/x86_64-linux-gnu/glib-2.0/include
#flag linux -I/usr/include/pango-1.0
#flag linux -I/usr/include/harfbuzz
#flag linux -I/usr/include/cairo
#flag linux -I/usr/include/atk-1.0
#flag linux -I/usr/include/libappindicator3-0.1
#flag linux -lgdk-x11-2.0
#flag linux -lappindicator

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
	
	cb       FnCTrayMenuCb
	context  voidptr

	submenu  &C.tray_menu
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
	ctray C.tray = C.tray{ icon: 0, menu: 0}
	mitems []&MenuItem
}

pub fn new() &Tray {
	return &Tray{}
}

type FnTrayMenuCb = fn (mi &MenuItem)
[params]
pub struct MenuItem {
pub mut:
	text string
	disabled int
	checked int
	cb FnTrayMenuCb = unsafe { nil }
	sub_menuitems []MenuItem
}
pub fn new_menu_item(params MenuItem) &MenuItem {
	return &MenuItem{
		...params
	}
}

pub fn (mut t Tray) set_icon(path string) {
	t.ctray.icon = path.str	
}

pub fn (mut t Tray) on_click(midx int, pcm &C.tray_menu) {
	dump(midx)
	dump(voidptr(pcm))
}

pub fn (mut t Tray) init() int {
	return C.tray_init(&t.ctray)
}

pub fn (mut t Tray) loop(blocking int) int {
	return C.tray_loop(blocking)	
}
pub fn (mut t Tray) exit() {
	C.tray_exit()
}

pub fn (mut t Tray) set_menu(menu_items []&MenuItem) {
	t.mitems = menu_items
	if t.mitems.len == 0 {
		return
	}
	t.ctray.menu = &C.tray_menu(unsafe{nil})
	mut p := t.ctray.menu
	for i in 0..t.mitems.len {
		mut c := t.mitems[i]
		eprintln('> i: $i | pcm: ${voidptr(&t.mitems[i])}')
		mut ci := &C.tray_menu {text: 0, submenu: 0}
		if c.text != '' {
			ci.text = c.text.str
			ci.disabled = c.disabled
			ci.checked = c.checked
			ci.cb = fn [i, mut t] (pcm &C.tray_menu) {
				dump(voidptr(pcm))
				t.on_click(i, pcm)
			}
			ci.context = &t.mitems[i]
			ci.submenu = unsafe { nil }
		}
		if p == unsafe { nil } {
			t.ctray.menu = ci
			p = t.ctray.menu
		} else {
			p.submenu = ci
		}
		p = ci
	}
	dump(p)
}

