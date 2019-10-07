extends Node

func generate_block(index):
	return get_child(index).duplicate()
