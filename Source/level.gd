extends Node2D

onready var globals = get_node('/root/globals')

var Ground = preload("res://Ground.tscn")
var UtilityPole = preload("res://UtilityPole.tscn")
var Garbage = preload("res://Garbage.tscn")
var Line = preload("res://line.tscn")

export(int) var screens = 10
export(int) var pole_density = 1
export(int) var pole_x_variance = 200

var terrain = []
var filler_terrain = []
var poles = []

var lines = []
var active_lines = []

var min_x = 0
var max_x = 1000

func build_screen():
	var screen = Ground.instance()
	
	self.add_child(screen)
	
	return screen
	
func build_pole():
	var pole = UtilityPole.instance()
	
	self.add_child(pole)
	
	return pole

func get_line_for_team(team):
	for l in active_lines:
		if l.team == team:
			return l
	
	return null

func check_lines():
	var remove = []
	var add = []
	for i in range(active_lines.size()):
		var l = active_lines[i]
		if l.pole2 != null:
			self.lines.append(l)
			var line = Line.instance()
			line.team = l.team
			line.add_pole(l.pole2, l.pole2_y)
			self.add_child(line)
			remove.append(i)
			add.append(line)
	
	for r in remove:
		active_lines.remove(r)
	
	for l in add:
		active_lines.append(l)
	

func generate_level():
	for i in range(1,10):
		var road = build_screen()
		road.set_global_pos(Vector2(-(i*1918), -200))
		
	
	for i in range(screens):
		var screen = build_screen()
		
		var pos = Vector2((i * 1918), -200)
		
		screen.set_global_pos(pos)
		
		terrain.append(screen)
		
		var garbage_chance = int(rand_range(0,4))
		if garbage_chance == 2 or garbage_chance == 0:
			print("ADDING GARBAGE")
			var garbage = Garbage.instance()
			garbage.set_z_as_relative(2)
			garbage.set_pos(Vector2(rand_range(200, 1700) + (i*1918), -40))
			
			self.add_child(garbage)
		
		for p in range(pole_density):
			var pole = build_pole()
			
			var pole_pos = Vector2(1920.0/self.pole_density, -470)
			pole_pos.x *= p
			
			randomize()
			pole_pos.x += self.pole_x_variance * rand_range(-1, 1)
			
			pole_pos.x += pos.x
			
			pole.set_pos(pole_pos)
			
			pole.pole_index = poles.size()
			
			poles.append(pole)
	
	min_x = terrain[0].get_global_pos().x
	max_x = screens*1920 + 1920
	
	for i in range(0,10):
		var road = build_screen()
		road.set_global_pos(Vector2((i*1918) + max_x - 2200, -200))

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	generate_level()
	
	for i in range(2):
		var line = Line.instance()
		line.team = i
		self.add_child(line)
		active_lines.append(line)
	
	var first_pole = self.poles[0]
	
	first_pole.complete()
	
	var green_line = get_line_for_team(0)
	var pink_line = get_line_for_team(1)
	
	green_line.add_pole(first_pole, first_pole.get_node("GreenTarget").get_global_pos().y)
	pink_line.add_pole(first_pole, first_pole.get_node("PinkTarget").get_global_pos().y)
	
	globals.game_state.set_pole_count(self.screens * self.pole_density)
	
	set_process(true)

func _process(delta):
	if globals.game_state.winner != null:
		globals.goto_scene("res://end_menu.tscn")

