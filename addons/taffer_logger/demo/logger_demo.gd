extends Node2D


@onready var logger: Logger = $Logger
@onready var console: RichTextLabel = $RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	logger.info("The _ready() function was just called.")


func _on_logger_log_entry(entry: String) -> void:
	# This prints the log entry to the console; note that print_rich()
	# automatically appends a newline, so we strip_edges() to remove it
	# (but not on the left-hand side in case you're using spaces for indents).
	print_rich(entry.strip_edges(false))

	# This adds the log entry to the RichTextLabel.
	console.append_text(entry)


func _on_info_button_pressed() -> void:
	logger.info("You pressed the Info button.")


func _on_warning_button_pressed() -> void:
	logger.warning("Don't touch that!")


func _on_error_button_pressed() -> void:
	logger.error("You fell victim to one of the classic blunders!")
