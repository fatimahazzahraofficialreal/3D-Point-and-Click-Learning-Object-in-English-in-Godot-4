extends Node3D

var words = ["banana", "apple", "orange"]
var objects = {}
var current_word = ""
var score = 0

func _ready():
	# Load and instance scenes
	var banana_scene = preload("res://banana.tscn").instantiate()
	var apple_scene = preload("res://apple.tscn").instantiate()
	var orange_scene = preload("res://orange.tscn").instantiate()

	# Add instances to the scene
	add_child(banana_scene)
	add_child(apple_scene)
	add_child(orange_scene)

	# Set objects to dictionary
	objects["banana"] = banana_scene
	objects["apple"] = apple_scene
	objects["orange"] = orange_scene

	# Ensure UI elements are valid
	var ui = get_node("UI")  # Path to your CanvasLayer or main UI node
	var word_label = ui.get_node("WordLabel")
	var score_label = ui.get_node("ScoreLabel")

	if word_label == null:
		print("Error: WordLabel node not found!")
	if score_label == null:
		print("Error: ScoreLabel node not found!")

	randomize_word()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func randomize_word():
	current_word = words[randi() % words.size()]
	var ui = get_node("UI")  # Path to your CanvasLayer or main UI node
	var word_label = ui.get_node("WordLabel")
	if word_label != null:
		word_label.text = current_word

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var space_state = get_world_3d().direct_space_state
		var from = get_node("Camera").project_ray_origin(event.position)
		var to = from + get_node("Camera").project_ray_normal(event.position) * 1000

		var query = PhysicsRayQueryParameters3D.new()
		query.from = from
		query.to = to

		var result = space_state.intersect_ray(query)
		if result:
			var clicked_object = result["collider"]
			if objects.has(current_word) and objects[current_word] == clicked_object:
				score += 1
				randomize_word()
				print("Correct! Score: " + str(score))
				var ui = get_node("UI")  # Path to your CanvasLayer or main UI node
				var score_label = ui.get_node("ScoreLabel")
				if score_label != null:
					score_label.text = "Score: " + str(score)
			else:
				print("Wrong object clicked")
