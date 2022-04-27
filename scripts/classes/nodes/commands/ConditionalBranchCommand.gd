## A branch that executes its children if a condition is met
tool
extends BranchCommand
class_name ConditionalBranchCommand

## Returns true if the command-branch should be run.
# @virtual
func _precondition() -> bool: return true

func _do_command():
	var result := _precondition()
	if result:
		return ._do_command()
