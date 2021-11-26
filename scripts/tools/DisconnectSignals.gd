tool
extends EditorScript

func _run() -> void:
	var nodes := get_editor_interface().get_selection().get_selected_nodes()
	for node in nodes:
		print(node.name)
