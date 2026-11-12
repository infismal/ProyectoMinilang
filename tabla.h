#ifndef TABLA_SIMBOLOS_H
#define TABLA_SIMBOLOS_H

typedef struct Simbolo {
    char *identificador;
    int *lineas;
    int cantidad_lineas;
    int capacidad;
    struct Simbolo *siguiente;
} Simbolo;

typedef struct {
    Simbolo *inicio;
    Simbolo *fin;
} TablaSimbolos;

void inicializarTabla(TablaSimbolos *tabla);

void insertarIdentificador(
    TablaSimbolos *tabla,
    const char *identificador,
    int linea
);

Simbolo *buscarIdentificador(
    TablaSimbolos *tabla,
    const char *identificador
);

void imprimirTabla(TablaSimbolos *tabla);

void liberarTabla(TablaSimbolos *tabla);

#endif
