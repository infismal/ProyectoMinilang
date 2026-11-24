# Makefile del proyecto de análisis léxico
#   make           compila el analizador (./minilang)
#   make pruebas   analiza cada programa de pruebas/ y compara con esperadas/
#   make limpiar   borra los archivos generados
CC = gcc
CFLAGS = -Wall -Wextra

minilang: lex.yy.c tabla.c tabla.h tokens.h
	$(CC) $(CFLAGS) -o minilang lex.yy.c tabla.c

lex.yy.c: minilang.l tabla.h tokens.h
	flex minilang.l

pruebas: minilang
	@mkdir -p salidas
	@fallas=0; \
	for f in pruebas/*.ml; do \
		n=$$(basename $$f .ml); \
		./minilang $$f > salidas/$$n.txt; \
		if diff -u esperadas/$$n.txt salidas/$$n.txt; then \
			echo "OK     $$n: sin diferencias"; \
		else \
			echo "FALLA  $$n: ver diferencias arriba"; fallas=1; \
		fi; \
	done; \
	exit $$fallas

limpiar:
	rm -f minilang lex.yy.c
	rm -rf salidas

.PHONY: pruebas limpiar
