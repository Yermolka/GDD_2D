extends Node
class_name Logger
## Emit BBCode-formatted log entry signals.
##
## The Logger produces signals containing BBCode-formatted log entries. Use
## these in a [RichTextLabel] or dump them to the console, etc. Sorry Americans,
## this is using Canadian spelling, so you'll have to add "u" to your colours.
##
## @tutorial(Using Logger):
##
## 1) Create a Logger instance in your tree.
## 2) Use the Inspector to configure the instance.
## 3) Connect the log_entry signal to something.
## 4) When you call the Logger's info(), warning(), or error() functions, it'll
##    generate a signal containing the BBCode-formatted log entry string.

@export var timestamp: bool = true  ## Include a timestamp?
@export var timestamp_utc: bool = false  ## Use UTC instead of local time for the timestamp?
@export var timestamp_use_space: bool = true  ## Use a space instead of "T" between the date and the time?

@export var info_colour: Color = Color.WHITE  ## Colour to use for info() log entries.
@export var warning_colour: Color = Color.YELLOW  ## Colour to use for warning() log entries.
@export var error_colour: Color = Color.RED  ## Colour to use for error() log entries.

@export var push_warnings: bool = false  ## Automatically send warning entries to the debugger and console?
@export var push_errors: bool = false  ## Automatically send error entries to the debugger and console?


## The different log levels; you don't need to use these directly, just call
## info(), warning(), or error() as appropriate.
enum Level {
	LOG_INFO = 0,  ## The default sort of log message.
	LOG_WARNING = 1,  ## Warning log messages.
	LOG_ERROR = 2  ## Error log messages.
}


## The log_entry signal is emitted whenever you call info(), warning(), or
## error(); it arrives with a BBCode-formatted string containing the log
## entry.
signal log_entry


# Colourize based on the supplied log_level.
func _level_to_colour(log_level: Level) -> String:
	match log_level:
		Level.LOG_INFO:
			return info_colour.to_html()
		Level.LOG_WARNING:
			return warning_colour.to_html()
		Level.LOG_ERROR:
			return error_colour.to_html()

	# You shouldn't actually get here.
	return Color.MAGENTA.to_html()


# Format a log entry.
func _format_log(log_level: Level, log_text: String) -> String:
	# Return a BBCode formatted log entry.
	var log_colour: String = _level_to_colour(log_level)
	var out: String = "[color=#{log_color}]".format({"log_color": log_colour})

	if timestamp:
		out += Time.get_datetime_string_from_system(timestamp_utc, timestamp_use_space) + " "

	match log_level:
		# TODO: How to make these translatable?
		# TODO: Add style variables instead of hard-coding Italic/Bold?
		Level.LOG_WARNING:
			out += "[i]Warning:[/i] "
		Level.LOG_ERROR:
			out += "[b]ERROR:[/b] "

	out += log_text + "[/color]\n"

	return out


## Emit an info-level log entry containing the given text.
func info(text: String) -> void:
	emit_signal("log_entry", _format_log(Level.LOG_INFO, text))


## Emit a warning-level log entry containing the given text.
func warning(text: String) -> void:
	emit_signal("log_entry", _format_log(Level.LOG_WARNING, text))
	if push_warnings:
		push_warning(text)


## Emit an error-level log entry containing the given text.
func error(text: String) -> void:
	emit_signal("log_entry", _format_log(Level.LOG_ERROR, text))
	if push_errors:
		push_error(text)
