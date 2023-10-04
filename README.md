# Description
A V wrapper for the C library https://github.com/zserge/tray .

It allows you to make cross platform apps with [V](https://github.com/vlang/v), that show a small icon
and menu in the system tray on the supported platforms (linux, macos, 
windows).

See [a simple example of a system tray app](https://github.com/spytheman/vtray/blob/master/examples/simple_tray.v).

## Installation
You can install the module in 2 ways:

* Through vpm (in this case, use `import spytheman.vtray` in your app)

`v install spytheman.vtray`


* Directly from github, to a local folder in your app's src/ folder 
(in this case, use `import vtray` in your app):

`git submodule add https://github.com/spytheman/vtray src/vtray`

## Dependencies:

This module is currently tested to work well on Ubuntu 20.04 .
It depends on libappindicator3-dev, libgtk2.0-dev and libgdk-pixbuf2.0-dev.

You can install those with:
```sh
sudo apt install --quiet -y libappindicator3-dev libgtk2.0-dev libgdk-pixbuf2.0-dev
```

It currently fails to compile on latest macOS Sonoma 14.0.

It is not tested at all on Windows for now, but cross compiles for it with:
`v -os windows examples/simple_tray.v`

