## A command that executes its own list of commands
# @desc You can define your own flow by extending this class and implementing
#       your own @function{_do_command} method.
tool
extends Command
class_name BranchCommand

## Emitted when the branch has finished running its commands
signal branch_finished()

func _do_command():
	var command_child : Command
	for node in get_children():
		command_child = node
		var result = command_child.do_command()
		if result is GDScriptFunctionState:
			yield(result, 'completed')
	emit_signal('branch_finished')
