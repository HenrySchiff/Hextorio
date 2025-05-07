class_name TransportLine extends Path2D

const ITEM_GAP: int = 15
var speed: int = 50
var next_line: TransportLine = null

func _process(delta: float) -> void:
	for path_follower in get_children():
		path_follower.progress += speed * delta
		
		var ahead: PathFollow2D
		var ahead_progress: float
		
		# If it's the last item on this belt
		if path_follower.get_index() == get_child_count() - 1:
			# And there's an item on the next belt
			if next_line && next_line.get_child_count() > 0:
				ahead = next_line.get_child(0)
				ahead_progress = ahead.progress + get_curve().get_baked_length()
		
		# If it's not the last item on the belt
		else:
			ahead = get_child(path_follower.get_index() + 1)
			ahead_progress = ahead.progress
		
		if ahead && ahead_progress - path_follower.progress < ITEM_GAP:
			path_follower.progress = ahead_progress - ITEM_GAP
		
		if path_follower.progress_ratio >= 1:
			if !next_line:
				path_follower.progress_ratio = 1
				continue
			
			var item: Item = path_follower.get_child(0)
			path_follower.remove_child(item)
			next_line.receive_item(item, path_follower.progress - get_curve().get_baked_length())
			path_follower.queue_free()

func receive_item(item: Item, progress: float) -> bool:
	#for path_follower in get_children():
		#if path_follower.progress > progress
	
	var new_path_follower = PathFollow2D.new()
	new_path_follower.progress = progress
	new_path_follower.loop = false
	new_path_follower.rotates = false
	new_path_follower.add_child(item)
	add_child(new_path_follower)
	move_child(new_path_follower, 0)
	return true
