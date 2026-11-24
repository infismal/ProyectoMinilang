#ifndef TABLA_H
#define TABLA_H

typedef struct Simbolo {
    char *identificador;        
    int *lineas;               
    int cantidades_lineas;      
    int capacidad;             
    struct Simbolo *siguiente;
} Simbolo;

typedef struct {
    Simbolo *inicio;
    Simbolo *fin;
    int cantidad;            
} TablaSimbolos;

void tabla_iniciar(void);
void registrar_identificador(const char *identificador, int linea);
Simbolo *buscar_identificador(const char *identificador);
void imprimir_tabla(void);
void liberar_tabla(void);

#endif
