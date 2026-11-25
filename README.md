# Proyecto del I Bimestre · Analizador léxico de MiniLang

**Grupo N.º:** 2
**Integrantes y responsabilidades:**

| Integrante | Responsabilidad principal |
|---|---|
| Guala Jorge | Tabla de símbolos, prueba 1 e informe (4 y 6) |
| Heredia Ismael | Errores E1–E6, prueba 3 e informe (3 y 3.1) |
| Roca Martín | Integración, prueba 2, informe (1, 5, 7 y 8) |
| Bohorquez Nicolás | Tokens y posiciones, prueba 4 e informe (2 y 2.1) |

## Cómo compilar y probar

```
make            # genera ./minilang
./minilang pruebas/p1_correcto.ml
make pruebas    # compara cada salida con esperadas/
```

En Google Colab: `!apt-get -qq install -y flex` y luego `!make pruebas`.

Archivos principales: `minilang.l` (reglas Flex), `tabla.c` / `tabla.h` (tabla de símbolos) y `tokens.h` (códigos de token).

## Programas de prueba

| Archivo | Qué prueba |
|---|---|
| `pruebas/p1_correcto.ml` | Programa sin errores: declaraciones, `mientras`, operadores, cadena con escape e identificadores repetidos (0 errores). |
| `pruebas/p2_errores_e1_e3.ml` | E1 (`@`, `#`), E2 (cadena sin cerrar) y E3 (comentario sin cerrar al final del archivo). |
| `pruebas/p3_errores_e4_e6.ml` | E4 (`12abc`, `3.14.5`), E5 (identificador de más de 31 caracteres) y E6 (escape `\q`). |
| `pruebas/p4_limites.ml` | Casos límite: identificador de 31 caracteres, escapes válidos, `//` y `/*` dentro de una cadena, reales con exponente y recuperación tras `7e`. |

La salida esperada de cada uno está en `esperadas/` con el mismo nombre y extensión `.txt`.

## Decisiones de diseño

- **Orden de las reglas.** Las palabras reservadas van antes de `{ID}`: con `mientras` empatan y gana la primera; con `mientras2` gana `{ID}` por longitud. `{REAL}` va antes de la regla de números mal formados, y la cadena cerrada antes de la regla E2. La regla `.` (E1) va al final.
- **E5 y E6.** E5: la regla `{ID}` mide `yyleng`; si pasa de 31 caracteres informa el error y no devuelve token ni registra el identificador. E6: la regla de cadena cerrada recorre el lexema con `primer_escape_invalido()`; solo se aceptan `\n`, `\t`, `\"` y `\\`, y el error se informa en la posición de la barra invertida.
- **Recuperación de errores.** Ningún error detiene el análisis: se informa y `yylex()` sigue con el siguiente lexema. E2 consume hasta el fin de línea y E3 hasta el fin de archivo (informa la posición donde abrió el comentario).
- **Posiciones.** La macro `YY_USER_ACTION` guarda línea y columna iniciales de cada lexema y avanza los contadores.
- **Tabla de símbolos.** Lista enlazada simple con punteros `inicio` y `fin`. Cada nodo guarda una copia del identificador (`strdup`, porque `yytext` se sobrescribe) y un arreglo dinámico de líneas distintas que se duplica con `realloc`. El orden es el de primera aparición. Al terminar se imprime y se libera la memoria.
