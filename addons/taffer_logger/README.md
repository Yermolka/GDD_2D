# Logger - Taffer's Components

Emit BBCode-formatted log entry signals.

The Logger produces signals containing BBCode-formatted log entries. Use
these in a
[RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html)
or dump them to the console, etc.

Sorry Americans, this is using Canadian spelling, so you'll have to add "u" to
your colours.

## Using Logger

1) Create a Logger instance in your tree:
   - Right-click a node and choose "Instantiate Child Scene" (or press
	 Ctrl+Shift+A).
   - Choose `addons/taffer_logger/logger.tscn`.
2) Use the Inspector to configure the instance.
3) Connect the `log_entry` signal to something. The `log_entry` signal comes
   with one argument, the BBCode-formatted log entry text.
4) When you call the Logger's `info()`, `warning()`, or `error()` functions,
   it'll generate a signal containing the BBCode-formatted log entry string.

## Demo

In the `demo` folder, there's a simple project showing how you can use the
Logger in your own games.

The demo has several nodes:

- A Logger, whose `log_entry` signal is connected to the root node's
  `_on_logger_log_entry()` function.
- Buttons, whose `pressed` signals are connected to the root node; when the
  root node handles these signals, it creates log entries by calling the
  Logger's functions.
- A RichTextLabel to display the log entries, which are also printed to the
  console.

## License

Taffer's Components are licensed with the
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) license. This means:

- You can **Share** Taffer's Components any way you like, including commercially.
- You can **Adapt** Taffer's Components for any purposes, even commercial ones.

In return, you *must*:

- You must give me
  [appropriate credit](https://creativecommons.org/licenses/by/4.0/#ref-appropriate-credit),
  provide a link to [the license](https://creativecommons.org/licenses/by/4.0/),
  and [indicate if changes were made](https://creativecommons.org/licenses/by/4.0/#ref-indicate-changes).

There are *no additional restrictions*, although if you somehow use these to
make the world a worse place, I'll be *very disappointed* in you.

See the
[`LICENSE`](https://codeberg.org/Taffer/godot-logger/src/branch/main/LICENSE)
file or the
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) page for details.
