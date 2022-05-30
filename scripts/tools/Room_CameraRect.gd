# To use this script, create a *Rect control somewhere in our scene tree.
# To make sure it works, it should be a child to another control,
# probably the Control base class. Next, select the control and run this script.
# The root node must be a room (it will have the 'camera_rects' property defined).
tool
extends EditorScript

func _run() -> void:
	var root := get_scene()
	
	# Root scene must have 'camera_rects' property and it must be an array
	if not root.get('camera_rects') is Array:
		printerr("%s: Invalid 'camera_rects' property, not an array" % root)
		return
	
	# Set each selected node as one of the camera rects
	var rects : Array = root.get('camera_rects')
	
	for node in get_editor_interface().get_selection().get_selected_nodes():
		if not node is ReferenceRect:
			printerr("Expected a ReferenceRect")
			continue
		
		rects.push_back((node as Control).get_global_rect())
		node.queue_free()
	
	root.set('camera_rects', rects)
