extends Node2D

const TAMANIO = Vector2(4, 4)
const TILE_TEXTURE = {
	0: preload("res://fotos/ffffff.png"),
	2: preload("res://fotos/2.png"),
	4: preload("res://fotos/4.png"),
	8: preload("res://fotos/8.png"),
	16: preload("res://fotos/16.jpeg"),
	32: preload("res://fotos/32.png"),
	64: preload("res://fotos/64.png"),
	128: preload("res://fotos/128.jpg"),
	256: preload("res://fotos/256.jpg"),
	512: preload("res://fotos/512.jpeg"),
	1024: preload("res://fotos/1024.png"),
	2048: preload("res://fotos/2048.png")
}
const Tamanio_celda = 100
var grid := [
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 0, 0, 0],
	[0, 0, 0, 0]
]
#BASE DE DATOS DE LOS PODERES
const INFO_PODERES = {
	"Limpieza de Gonzas": {
		"descripcion": "Elimina a todos los numeros 2 del tablero",
		"icono": preload("res://fotos/Poderes/Limpieza_Gonzas.png"),
		"color": "95da05"
	},
	"Movimiento Libre": {
		"descripcion": "Intercambia de lugar cualquier ficha con cualquier otra.",
		"icono": preload("res://fotos/Poderes/MovimientoLibre.png"),
		"color": "53d180" 
	},
	"Fuerza Bruta": {
		"descripcion": "Sube una ficha al siguiente nivel instantáneamente.",
		"icono": preload("res://fotos/Poderes/FuerzaBruta.png"),
		"color": "ff901c"
	},
	"El Martillo": {
		"descripcion": "Rompe y elimina por completo una ficha molesta (3 usos).",
		"icono": preload("res://fotos/Poderes/ElMartillo.png"),
		"color": "61e0ef"
	},
	"Comodin": {
		"descripcion": "Congela la PRESIÓN del tablero por 5 turnos.",
		"icono": preload("res://fotos/Poderes/Comodin.png"),
		"color": "6168b0" 
	},
	"Celda Anclada": {
		"descripcion": "Protege una celda. No se moverá cuando ataque la Presión.",
		"icono": preload("res://fotos/Poderes/ProteccionCelda.png"),
		"color": "ba1a3b"
	},
	"Tornado": {
		"descripcion": "Mezcla aleatoriamente las posiciones de todas las fichas.",
		"icono": preload("res://fotos/Poderes/Tornado.png"),
		"color": "d39e1c" 
	},
	"Fusión Cuántica": {
		"descripcion": "Atrae a una esquina y fusiona todas las fichas de un mismo número.",
		"icono": preload("res://fotos/Poderes/FusionCuantica.png"),
		"color": "c52c6d" 
	},
	"Ampliamiento": {
		"descripcion": "Agrega una nueva fila al tablero (5x5). Requiere elegirlo 2 veces.",
		"icono": preload("res://fotos/Poderes/Ampliamientox1.png"), 
		"color": "5934c2"
	},
	"Fuerza Bruta II": {
		"descripcion": "Evoluciona todos los números iguales elegidos al siguiente nivel.",
		"icono": preload("res://fotos/Poderes/FuerzaBrutaII.png"),
		"color": "fd871b"
	},
	"Clonación": {
		"descripcion": "Crea una copia idéntica de la ficha seleccionada en una celda vacía.",
		"icono": preload("res://fotos/Poderes/Clonacion.png"),
		"color": "1badac" 
	},
	"Blindaje Fila": {
		"descripcion": "Protege tu mejor fila (la superior) contra el ataque de la Presión.",
		"icono": preload("res://fotos/Poderes/BlindajeFila.png"),
		"color": "c21d48" 
	}
	
}


#PODERES
var numeros_descubiertos = [2]
@onready var menu_poderes = $"../CanvasLayer/VBoxContainer"
@onready var inventario = $"../CanvasLayer/PanelContainer/InventarioPoderes"
@onready var btn_opcion_1 = $"../CanvasLayer/VBoxContainer/MenuPoderes/HBoxContainer/Button1"
@onready var btn_opcion_2 = $"../CanvasLayer/VBoxContainer/MenuPoderes/HBoxContainer/Button2"
@onready var btn_opcion_3 = $"../CanvasLayer/VBoxContainer/MenuPoderes/HBoxContainer/Button3"


#EL TABLERO
@onready var tablero_ui = $"../FondoTablero/TableroUI"
@onready var rectanguloLava = $"../CanvasLayer/ColorRect"
@onready var label_advertencia2 = $"../CanvasLayer/LabelAdvertencia2" 
@onready var label_advertencia = $"../CanvasLayer/LabelAdvertencia" 
const MOVIMIENTOS_PARA_PRESION = 30
var contadorMovimientos = 0

func _ready() -> void:
	$"../CanvasLayer/PanelGameOver".hide()
	spawn_new_tile()
	update_visuals()

				
func update_visuals() -> void:
	var index = 0
	for y in range(TAMANIO.y):
		for x in range(TAMANIO.x):
			var valor = grid[y][x]
			var tile_node = tablero_ui.get_child(index) 
			
			var foto_nodo = tile_node.get_node("TextureRect")
			foto_nodo.texture = TILE_TEXTURE[valor]
			
			if valor == 0:
				tile_node.get_node("Label").text = ""
			else:
				tile_node.get_node("Label").text = str(valor)
				
			index += 1
func spawn_new_tile() -> bool:
	var celda_vacia: Array[Vector2i] = []
	for y in range(TAMANIO.y):
		for x in range(TAMANIO.x):
			if grid[y][x] == 0:
				celda_vacia.append(Vector2i(x,y))
				
	if celda_vacia.size() > 0:
		var random_cell = celda_vacia.pick_random()
		var new_number = [2, 2, 4].pick_random()
		grid[random_cell.y][random_cell.x] = new_number
		update_visuals()
		
		var index = random_cell.y * TAMANIO.x + random_cell.x
		var tile_node = tablero_ui.get_child(index) 
		tile_node.get_node("AnimationPlayer").play("aparecer")
		return true
	
	return false	
									


func _unhandled_input(event: InputEvent) -> void:
	var seMovio = false
	
	if event.is_action_pressed("ui_left"):
		seMovio = move_left()
	elif event.is_action_pressed("ui_right"):
		seMovio = move_right()
	elif event.is_action_pressed("ui_up"):
		seMovio = move_up()
	elif event.is_action_pressed("ui_down"):
		seMovio = move_down()
						
	if seMovio:
		spawn_new_tile()
		contadorMovimientos += 1
		verificar_presion()
		update_visuals()
		if is_game_over():
			$"../CanvasLayer/PanelGameOver".show()
		
func verificar_presion() -> void:
	var faltan = MOVIMIENTOS_PARA_PRESION - (contadorMovimientos % MOVIMIENTOS_PARA_PRESION)
	if faltan <= 5 and faltan < MOVIMIENTOS_PARA_PRESION:
		label_advertencia.text = str(faltan)
		label_advertencia2.text = "Tablero sube en..."
		rectanguloLava.color= Color("ff4300")
		label_advertencia.show()
		label_advertencia2.show()
		rectanguloLava.show()
	elif faltan == MOVIMIENTOS_PARA_PRESION: 
		label_advertencia.hide()
		label_advertencia2.hide()
		rectanguloLava.hide()
				
	
		aplicar_presion()
	else:
		label_advertencia.hide()
func aplicar_presion() -> void:
	for y in range(TAMANIO.y - 1):
		grid[y] = grid[y + 1].duplicate()
	var nueva_fila = []
	for x in range(TAMANIO.x):
		nueva_fila.append([2, 4].pick_random()) 
		
	grid[TAMANIO.y - 1] = nueva_fila
		
func move_left() -> bool:
		var moved = false
		for y in range(TAMANIO.y):
			var nuevaFila = []
			var last = false
			
			for x in range(TAMANIO.x):
				if grid[y][x] != 0:
					if nuevaFila.size() > 0 and nuevaFila[-1] == grid[y][x]: 
						nuevaFila[-1] *= 2
						#score += new_row[-1]
						last = true
						moved = true
						var numero_fusionado = nuevaFila[-1]
						if not numeros_descubiertos.has(numero_fusionado):
							numeros_descubiertos.append(numero_fusionado)
							mostrar_menu_poderes()
					else:
						nuevaFila.append(grid[y][x])
						last = false
						if x != len(nuevaFila) - 1:
							moved = true
							
			#RELLENO TDO DE CEROS
			while nuevaFila.size() < TAMANIO.x:
				nuevaFila.append(0)
				
			#SI LA NUEVA Fila ES DIFERENTE A LA ORIGINAL, actualizo el grid
			if grid[y] != nuevaFila:
				grid[y] = nuevaFila
				moved = true
		return moved
func move_right() -> bool:
	var moved = false
	for y in range(TAMANIO.y):
		var nuevaFila = []
		var last = false
		for x in range(TAMANIO.x - 1, -1, -1): # Recorremos de derecha a izquierda
			if grid[y][x] != 0:
				if nuevaFila.size() > 0 and nuevaFila[-1] == grid[y][x]: 
					nuevaFila[-1] *= 2
					#score += new_row[-1]
					last = true
					moved = true
					var numero_fusionado = nuevaFila[-1]
					if not numeros_descubiertos.has(numero_fusionado):
						numeros_descubiertos.append(numero_fusionado)
						mostrar_menu_poderes()
				else:
					nuevaFila.append(grid[y][x])
					last = false
					if x != TAMANIO.x - 1 - (len(nuevaFila) - 1):
						moved = true
		#RELLENO TDO DE CEROS
		while nuevaFila.size() < TAMANIO.x:
			nuevaFila.append(0)
			
		nuevaFila.reverse() # Invertimos porque leímos de derecha a izquierda
			
		#SI LA NUEVA Fila ES DIFERENTE A LA ORIGINAL, actualizo el grid
		if grid[y] != nuevaFila:
			grid[y] = nuevaFila
			moved = true
	return moved
func move_up() -> bool:
	var moved = false
	for x in range(TAMANIO.x):
		var nuevaColumna = []
		var last = false
		for y in range(TAMANIO.y): # Recorremos de arriba a abajo
			if grid[y][x] != 0:
				if nuevaColumna.size() > 0 and nuevaColumna[-1] == grid[y][x]: 
					nuevaColumna[-1] *= 2
					#score += new_row[-1]
					last = true
					moved = true
					var numero_fusionado = nuevaColumna[-1]
					if not numeros_descubiertos.has(numero_fusionado):
						numeros_descubiertos.append(numero_fusionado)
						mostrar_menu_poderes()
				else:
					nuevaColumna.append(grid[y][x])
					last = false
					if y != len(nuevaColumna) - 1:
						moved = true
		#RELLENO TDO DE CEROS
		while nuevaColumna.size() < TAMANIO.y:
			nuevaColumna.append(0)
			
		#SI LA NUEVA Columna ES DIFERENTE A LA ORIGINAL, actualizo el grid
		for y in range(TAMANIO.y):
			if grid[y][x] != nuevaColumna[y]:
				grid[y][x] = nuevaColumna[y]
				moved = true
	return moved
func move_down() -> bool:
	
	var moved = false
	for x in range(TAMANIO.x):
		var nuevaColumna = []
		var last = false
		for y in range(TAMANIO.y - 1, -1, -1): # Recorremos de abajo a arriba
			if grid[y][x] != 0:
				if nuevaColumna.size() > 0 and nuevaColumna[-1] == grid[y][x]: 
					nuevaColumna[-1] *= 2
					#score += new_row[-1]
					last = true
					moved = true
					var numero_fusionado = nuevaColumna[-1]
					if not numeros_descubiertos.has(numero_fusionado):
						numeros_descubiertos.append(numero_fusionado)
						mostrar_menu_poderes()
				else:
					nuevaColumna.append(grid[y][x])
					last = false
					if y != TAMANIO.y - 1 - (len(nuevaColumna) - 1):
						moved = true
		#RELLENO TDO DE CEROS
		while nuevaColumna.size() < TAMANIO.y:
			nuevaColumna.append(0)
		
		nuevaColumna.reverse() # Invertimos porque leímos de abajo a arriba
			
		#SI LA NUEVA Columna ES DIFERENTE A LA ORIGINAL, actualizo el grid
		for y in range(TAMANIO.y):
			if grid[y][x] != nuevaColumna[y]:
				grid[y][x] = nuevaColumna[y]
				moved = true
	return moved	

func is_game_over() -> bool:
	for y in range(TAMANIO.y):
		for x in range(TAMANIO.x):
			if grid[y][x] == 0:
				return false
	return not hayMovimientosPosibles()	
func mostrar_menu_poderes() -> void:
	
	menu_poderes.show()
	#con tdos los nombre los mezclo con shuffle
	var nombres_poderes = INFO_PODERES.keys()
	nombres_poderes.shuffle()
		
	var opciones = [nombres_poderes[0], nombres_poderes[1], nombres_poderes[2]]
	var botones = [btn_opcion_1, btn_opcion_2, btn_opcion_3]
				
	for i in range(3):
		var btn = botones[i]
		var nombre = opciones[i]
		var info = INFO_PODERES[nombre]
			
		var layout = btn.get_node("LayoutInterno")
				
		layout.get_node("TextureRect").texture = info["icono"]
		layout.get_node("TituloLabel").text = nombre
		layout.get_node("DescLabel").text = info["descripcion"]
	
func _on_button_1_pressed() -> void:
	var nombre_poder = btn_opcion_1.get_node("LayoutInterno/TituloLabel").text
	agregar_poder_al_inventario(nombre_poder)
	
func _on_button_2_pressed() -> void:
	var nombre_poder = btn_opcion_2.get_node("LayoutInterno/TituloLabel").text
	agregar_poder_al_inventario(nombre_poder)
	
func _on_button_3_pressed() -> void:
	var nombre_poder = btn_opcion_3.get_node("LayoutInterno/TituloLabel").text
	agregar_poder_al_inventario(nombre_poder)
		
func agregar_poder_al_inventario(nombre_poder: String) -> void:
	menu_poderes.hide() 
	var info = INFO_PODERES[nombre_poder]
		
	var nuevo_boton_poder = Button.new()
	nuevo_boton_poder.text = nombre_poder
	nuevo_boton_poder.custom_minimum_size = Vector2(150, 50)
	
				
	nuevo_boton_poder.add_theme_color_override("font_color", Color(info["color"]))
	
	nuevo_boton_poder.icon = info["icono"]
	nuevo_boton_poder.expand_icon = true #lo hago desde el codigo en ves de la interfaz visual
	nuevo_boton_poder.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	nuevo_boton_poder.pressed.connect(usar_poder_automatico.bind(nombre_poder, nuevo_boton_poder))
		
	inventario.add_child(nuevo_boton_poder)
	
		
func usar_poder_automatico(nombre_poder: String, boton_usado: Button) -> void:
	var exito = false
	
	#MATCH es como Switch enn JAVA
	match nombre_poder:
		"Limpieza de Gonzas":
			exito = usar_limpieza_gonzas()
		"Tornado":
			exito = poder_tornado()
		"Comodin":
			exito = poder_comodin()
			
		_:		
			return 
			
	if exito:
		update_visuals()
		boton_usado.queue_free() 
			
	
func usar_limpieza_gonzas() -> bool:
	var exito = false
	for y in range(TAMANIO.y):
		for x in range(TAMANIO.x):
			if grid[y][x] == 2:
				grid[y][x] = 0
				exito = true
	return exito
	#if exito:
	#	update_visuals()
	#	boton_usado.queue_free()
func poder_tornado() -> bool:
	
	var valores_guardados = []
	var todas_las_posiciones = []
	#1 recorremos fichas y las guardamois
	for y in range(TAMANIO.y):
		for x in range(TAMANIO.x):
			todas_las_posiciones.append(Vector2i(x, y)) 
								
			if grid[y][x] != 0:
				valores_guardados.append(grid[y][x])
				grid[y][x] = 0 # vaciamos la celda
	
	#2 random
	todas_las_posiciones.shuffle()
	
	# 3 vvolvemos a colocar los valores en las nuevas posiciones aleatorias
	for i in range(valores_guardados.size()):
		var pos_azar = todas_las_posiciones[i]
		grid[pos_azar.y][pos_azar.x] = valores_guardados[i]
		
	return true
func poder_comodin() -> bool:
	contadorMovimientos -= 5
	if contadorMovimientos < 0:
		contadorMovimientos = 0
			
	return true

func hayMovimientosPosibles() -> bool:
	for row in range(TAMANIO.y):
		for col in range(TAMANIO.x - 1):
			if grid[row][col] == grid[row][col + 1]:
				return true

	for col in range(TAMANIO.x):
		for row in range(TAMANIO.y - 1):
			if grid[row][col] == grid[row + 1][col]:
				return true
	return false
