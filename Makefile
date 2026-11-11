# Makefile del proyecto de análisis léxico
#   make           compila el analizador (./minilang)
#   make pruebas   analiza cada programa de pruebas/ y compara con esperadas/
#   make limpiar   borra los archivos generados
CC = gcc
CFLAGS = -Wall

minilang: lex.yy.c tabla.c tabla.h tokens.h
	$(CC) $(CFLAGS) -o minilang lex.yy.c tabla.c

lex.yy.c: minilang.l
	flex minilang.l

pruebas: minilang
	mkdir -p salidas
	for f in pruebas/*.ml; do ./minilang $$f > salidas/$$(basename $$f .ml).txt; done
	for f in pruebas/*.ml; do n=$$(basename $$f .ml); diff -q salidas/$$n.txt esperadas/$$n.txt; done

limpiar:
	rm -f minilang lex.yy.c
	rm -rf salidas
