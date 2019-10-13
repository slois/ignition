extends Node

func generate_block(index):
	var block = get_child(index).duplicate()
	block.type = index
	return(block)
