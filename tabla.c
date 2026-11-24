#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla.h"

#define CAPACIDAD_INICIAL 4

static TablaSimbolos tabla = { NULL, NULL, 0 };

void tabla_iniciar(void) {
    tabla.inicio = NULL;
    tabla.fin = NULL;
    tabla.cantidad = 0;
}

Simbolo *buscar_identificador(const char *identificador) {
    for (Simbolo *s = tabla.inicio; s != NULL; s = s->siguiente) {
        if (strcmp(s->identificador, identificador) == 0) {
            return s;
        }
    }
    return NULL;
}

static void agregar_linea(Simbolo *s, int linea) {
    if (s->lineas[s->cantidades_lineas - 1] == linea) {
        return;
    }
    if (s->cantidades_lineas == s->capacidad) {
        int nueva = s->capacidad * 2;
        int *aux = realloc(s->lineas, (size_t) nueva * sizeof(int));
        if (aux == NULL) {
            fprintf(stderr, "Error de memoria al ampliar las líneas.\n");
            return;
        }
        s->lineas = aux;
        s->capacidad = nueva;
    }
    s->lineas[s->cantidades_lineas++] = linea;
}

void registrar_identificador(const char *identificador, int linea) {
    Simbolo *s = buscar_identificador(identificador);

    if (s != NULL) {
        agregar_linea(s, linea);
        return;
    }

    s = malloc(sizeof(Simbolo));
    if (s == NULL) {
        fprintf(stderr, "Error de memoria al crear el símbolo.\n");
        return;
    }

    s->identificador = strdup(identificador);
    s->lineas = malloc(CAPACIDAD_INICIAL * sizeof(int));
    if (s->identificador == NULL || s->lineas == NULL) {
        free(s->identificador);
        free(s->lineas);
        free(s);
        fprintf(stderr, "Error de memoria al inicializar el símbolo.\n");
        return;
    }

    s->capacidad = CAPACIDAD_INICIAL;
    s->cantidades_lineas = 1;
    s->lineas[0] = linea;
    s->siguiente = NULL;

    if (tabla.fin == NULL) {
        tabla.inicio = s;
    } else {
        tabla.fin->siguiente = s;
    }
    tabla.fin = s;
    tabla.cantidad++;
}

void imprimir_tabla(void) {
    int n = 1;

    printf("TABLA DE SÍMBOLOS (%d identificadores)\n", tabla.cantidad);
    for (Simbolo *s = tabla.inicio; s != NULL; s = s->siguiente, n++) {
        printf("  %d  %-20s líneas:", n, s->identificador);
        for (int i = 0; i < s->cantidades_lineas; i++) {
            printf(" %d", s->lineas[i]);
        }
        printf("\n");
    }
}

void liberar_tabla(void) {
    Simbolo *s = tabla.inicio;
    while (s != NULL) {
        Simbolo *sig = s->siguiente;
        free(s->identificador);
        free(s->lineas);
        free(s);
        s = sig;
    }
    tabla_iniciar();
}
