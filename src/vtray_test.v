import vtray

fn test_compiles() {
	t := vtray.new()
	unsafe {
		_ := tos4(&u8(t.ctray.icon))
	}
	dump(t)
	assert true
}
