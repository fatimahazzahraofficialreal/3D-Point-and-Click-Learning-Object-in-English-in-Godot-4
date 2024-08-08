extends Node3D

var words = ["banana", "apple", "orange"]
var objects = {}
var current_word = ""
var score = 0
var max_mistakes = 3
var mistakes = 0

func _ready():
	print("Game is ready")

	# Setup StaticBody3D objects directly
	setup_object("banana", "res://banana.glb", "StaticBody3D")
	setup_object("apple", "res://apple.glb", "StaticBody3D2")
	setup_object("orange", "res://orange.glb", "StaticBody3D3")

	# Ensure UI elements are valid
	var ui = get_node("UI")
	if ui == null:
		print("Error: UI node not found!")
		return
	
	var word_label = ui.get_node("WordLabel")
	var score_label = ui.get_node("ScoreLabel")

	if word_label == null:
		print("Error: WordLabel node not found!")
	if score_label == null:
		print("Error: ScoreLabel node not found!")

	randomize_word()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func setup_object(name, glb_path, static_body_name):
	var static_body = get_node(static_body_name)
	if static_body == null:
		print("Error: " + static_body_name + " node not found!")
		return
	
	var model = load(glb_path).instantiate()
	static_body.add_child(model)
	objects[name] = static_body

func randomize_word():
	current_word = words[randi() % words.size()]
	var ui = get_node("UI")
	var word_label = ui.get_node("WordLabel")
	if word_label != null:
		word_label.text = current_word
	print("Randomized word: " + current_word)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Mouse button pressed")
		var space_state = get_world_3d().direct_space_state
		var from = get_node("Camera").project_ray_origin(event.position)
		var to = from + get_node("Camera").project_ray_normal(event.position) * 1000

		var query = PhysicsRayQueryParameters3D.new()
		query.from = from
		query.to = to
		query.collide_with_areas = true
		query.collide_with_bodies = true

		var result = space_state.intersect_ray(query)
		if result:
			print("Ray intersected with object: " + str(result.collider))
			var clicked_object = result.collider
			if objects.has(current_word) and objects[current_word] == clicked_object:
				score += 1
				print("Correct! Score: " + str(score))
				update_score_label()
				randomize_word()
			else:
				mistakes += 1
				print("Wrong object clicked. Mistakes: " + str(mistakes))
				if mistakes >= max_mistakes:
					game_over()
				else:
					randomize_word()
		else:
			print("Ray did not intersect with any object")

func update_score_label():
	var ui = get_node("UI")
	var score_label = ui.get_node("ScoreLabel")
	if score_label != null:
		score_label.text = "Score: " + str(score)
	print("Updated score: " + str(score))

func game_over():
	print("Game Over")
	var ui = get_node("UI")
	var word_label = ui.get_node("WordLabel")
	if word_label != null:
		word_label.text = "Game Over"
	set_process(false)  # Stop further input processing
