# res://tools/editor_add_groups.gd
@tool
extends EditorScript

func _run():
	var root = EditorInterface.get_edited_scene_root()
	if not root:
		push_error("❌ Sahne root'u bulunamadı—lütfen bir sahne açık olsun!")
		return

	var added = 0
	_recursive_add(root, added)

	if added > 0:
		print("✅ %d node 'Difference' grubuna eklendi." % added)
	else:
		print("⚠️ Hiç 'GodotExport_SM_' ile başlayan node bulunamadı!")

func _recursive_add(node: Node, added: int) -> void:
	# İsme bakarak filtreleyelim:
	if node.name.begins_with("SM_"):
		node.add_to_group("Difference")
		added += 1
	# Tüm çocuklar üzerinde de çalış:
	for c in node.get_children():
		_recursive_add(c, added)
