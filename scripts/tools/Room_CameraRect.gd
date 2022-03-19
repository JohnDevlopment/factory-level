# To use this script, create a *Rect control somewhere in our scene tree.
# To make sure it works, it should be a child to another control,
# probably the Control base class. Next, select the control and run this script.
# The root node must be a room (it will have the 'camera_rects' property defined).
tool
extends EditorScript

func _run() -> void:
	var root := get_scene()
	var selection := get_editor_interface().get_selection()
	var selected_node : Node = selection.get_selected_nodes()[0]
	if _has(root, 'camera_rects') and root.get('camera_rects') is Array:
		if selected_node is Control and selected_node.get_class().ends_with('Rect'):
			var rects : Array = root.get('camera_rects')
			var node_rect := (selected_node as Control).get_global_rect()
			rects.push_back(node_rect)
			root.set('camera_rects', rects)
			selected_node.queue_free()
		else:
			print("%s is not a *Rect control" % selected_node)
	else:
		print("%s is not a room scene" % root)

func _has(node: Node, property: String) -> bool:
	return node.get(property) != null
