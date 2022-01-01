extends Node

# Override in inherited
var state_map = {}

var current_state
var current_state_name
var previous_state

export(NodePath) var begin_state_path
var begin_state

var active = false

func _ready():

	init_state_list()
	on_statemachine_ready()
	enter_state_machine()

#Override
func on_statemachine_ready()->void:
	pass

func init_state_list()->void:

	var state_nodes = get_children()

	for node in state_nodes:
		state_map[node.name] = node

func enter_state_machine()->void:
	
	var state_nodes = get_children()

	for node in state_nodes:
		node.connect("Finished", self, "switch_state")
	
	begin_state = get_node(begin_state_path)
	current_state = begin_state
	current_state_name = current_state.name

	set_process_active(true)
	current_state.enter()

func set_process_active(value : bool)->void:
	
	active = true
	set_physics_process(value)
	set_process(value)

	if active == false:

		current_state = null

#Look into using process too if needed
func _physics_process(delta):
	
	current_state.update(delta)

func _input(event):
	
	current_state.update_input(event)

func switch_state(next_state : String)->void:
	
	if active == false:
		return
	
	if next_state == current_state_name:
		return
	
	current_state.exit()

	if next_state == "previous":

		current_state = previous_state

	else:

		previous_state = current_state
		current_state = state_map.get(next_state)
	
	current_state_name = current_state.name
	current_state.enter()

