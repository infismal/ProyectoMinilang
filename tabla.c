#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla_simbolos.h"
#include "gestion_lexemas.h"

void inicializarTabla(TablaSimbolos *tabla) {
    tabla->inicio = NULL;
    tabla->fin = NULL;
}

Simbolo *buscarIdentificador(TablaSimbolos *tabla, const char *identificador) {
    Simbolo *actual = tabla->inicio;

    while (actual != NULL) {
        if (strcmp(actual->identificador, identificador) == 0) {
            return actual;
        }
        actual = actual->siguiente;
    }

    return NULL;
}

void insertarIdentificador(TablaSimbolos *tabla, const char *identificador, int linea) {
    Simbolo *simbolo = buscarIdentificador(tabla, identificador);

    /* Si ya existe, registrar la nueva linea evitando duplicados */
    if (simbolo != NULL) {
        for (int i = 0; i < simbolo->cantidad_lineas; i++) {
            if (simbolo->lineas[i] == linea) {
                return;
            }
        }

        if (simbolo->cantidad_lineas == simbolo->capacidad) {
            int nuevaCapacidad = simbolo->capacidad * 2;
            int *nuevasLineas = realloc(
                simbolo->lineas,
                nuevaCapacidad * sizeof(int)
            );

            if (nuevasLineas == NULL) {
                fprintf(stderr, "Error de memoria al redimensionar lineas.\n");
                return;
            }

            simbolo->lineas = nuevasLineas;
            simbolo->capacidad = nuevaCapacidad;
        }

        simbolo->lineas[simbolo->cantidad_lineas++] = linea;
        return;
    }

    /* Si no existe, crear un nuevo simbolo e insertarlo al final */
    simbolo = malloc(sizeof(Simbolo));
    if (simbolo == NULL) {
        fprintf(stderr, "Error de memoria al crear simbolo.\n");
        return;
    }

    simbolo->identificador = copiar_lexema(identificador);
    simbolo->lineas = malloc(2 * sizeof(int));

    if (simbolo->identificador == NULL || simbolo->lineas == NULL) {
        free(simbolo->identificador);
        free(simbolo->lineas);
        free(simbolo);
        fprintf(stderr, "Error de memoria al inicializar simbolo.\n");
        return;
    }

    simbolo->capacidad = 2;
    simbolo->cantidad_lineas = 1;
    simbolo->lineas[0] = linea;
    simbolo->siguiente = NULL;

    if (tabla->fin == NULL) {
        tabla->inicio = simbolo;
        tabla->fin = simbolo;
    } else {
        tabla->fin->siguiente = simbolo;
        tabla->fin = simbolo;
    }
}

void imprimirTabla(TablaSimbolos *tabla) {
    Simbolo *actual = tabla->inicio;

    printf("\n TABLA DE SIMBOLOS \n");

    while (actual != NULL) {
        printf("%s: lineas ", actual->identificador);

        for (int i = 0; i < actual->cantidad_lineas; i++) {
            printf("%d", actual->lineas[i]);
            if (i < actual->cantidad_lineas - 1) {
                printf(", ");
            }
        }

        printf("\n");
        actual = actual->siguiente;
    }
}

void liberarTabla(TablaSimbolos *tabla) {
    Simbolo *actual = tabla->inicio;

    while (actual != NULL) {
        Simbolo *siguiente = actual->siguiente;
        free(actual->identificador);
        free(actual->lineas);
        free(actual);
        actual = siguiente;
    }

    tabla->inicio = NULL;
    tabla->fin = NULL;
}
