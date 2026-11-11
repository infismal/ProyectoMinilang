/* tabla.c — tabla de símbolos de identificadores (PUNTO DE PARTIDA: completar)
 *
 * Requisitos (ver la consigna del proyecto):
 *   - cada identificador aparece UNA sola vez, en el orden en que aparece por primera vez;
 *   - guarda las líneas donde aparece, sin repetir una línea;
 *   - copia el nombre con strdup: yytext se reutiliza en cada lexema;
 *   - tabla_imprimir() escribe exactamente el formato de la consigna:
 *
 *       TABLA DE SÍMBOLOS (N identificadores)
 *         1  nombre               líneas: 2 4 5
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabla.h"

/* COMPLETAR: la estructura de cada símbolo (nombre, líneas, siguiente…) */

void tabla_agregar(const char *nombre, int linea) {
    /* COMPLETAR: buscar el nombre; si existe, agregar la línea si es nueva;
       si no existe, crear el símbolo con strdup(nombre) al final de la lista */
    (void) nombre; (void) linea;
}

void tabla_imprimir(void) {
    /* COMPLETAR: recorrer la tabla e imprimir con el formato de la consigna */
    printf("\nTABLA DE SÍMBOLOS (0 identificadores)\n");
}
