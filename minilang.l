%{
#include <stdio.h>
#include "tabla.h"
#include "tokens.h"

int linea = 1, col = 1;
int ntokens = 0, nerrores = 0;

static int sig_linea = 1, sig_col = 1;
static int com_linea, com_col;

/* Guarda la posición inicial del lexema y avanza el contador. */
#define YY_USER_ACTION do {                       \
    linea = sig_linea;                            \
    col = sig_col;                                \
    for (int i = 0; i < yyleng; i++) {             \
        if (yytext[i] == '\n') {                   \
            sig_linea++;                          \
            sig_col = 1;                          \
        } else {                                  \
            sig_col++;                            \
        }                                         \
    }                                             \
} while (0);

static int token(const char *tipo, int codigo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
    return codigo;
}

static void error(const char *cod, const char *msg, int l, int c) {
    printf("%d:%d\tERROR [%s]\t%s\n", l, c, cod, msg);
    nerrores++;
}

static void error_caracter(void) {
    char msg[64];
    unsigned char b = (unsigned char) yytext[0];

    if (b >= 32 && b < 127) {
        snprintf(msg, sizeof msg, "carácter no válido '%c'", b);
    } else {
        snprintf(msg, sizeof msg, "byte no válido 0x%02X", (unsigned int) b);
    }

    error("E1", msg, linea, col);
}

static void error_numero(void) {
    char msg[160];
    snprintf(msg, sizeof msg, "número mal formado '%.120s'", yytext);
    error("E4", msg, linea, col);
}

/* Se invoca únicamente para cadenas con comillas de cierre. */
static int primer_escape_invalido(void) {
    for (int i = 1; i < yyleng - 1; i++) {
        if (yytext[i] == '\\') {
            int inicio = i;
            char escape = yytext[++i];

            if (escape != 'n' && escape != 't' &&
                escape != '"' && escape != '\\') {
                return inicio;
            }
        }
    }

    return -1;
}
%}

%option noyywrap nounput noinput
%x COMENT

DIG       [0-9]
LETRA     [A-Za-z_]
ID        {LETRA}({LETRA}|{DIG})*
REAL      {DIG}+"."{DIG}+([eE][+-]?{DIG}+)?|{DIG}+[eE][+-]?{DIG}+
CONT_CAD  (\\[^\n]|[^"\\\n])*

%%
[ \t\r\n]+             { /* espacios: se descartan */ }
"//".*                 { /* comentario de línea */ }

"/*" {
    com_linea = linea;
    com_col = col;
    BEGIN(COMENT);
}

<COMENT>"*/"           { BEGIN(INITIAL); }
<COMENT>[^*\n]+|"*"|\n { /* dentro del comentario */ }

<COMENT><<EOF>> {
    error("E3", "comentario sin cerrar", com_linea, com_col);
    BEGIN(INITIAL);
}

entero|real|cadena|logico|si|sino|mientras|para|funcion|retornar|imprimir|leer|verdadero|falso {
    return token("PALABRA_RESERVADA", T_RESERVADA);
}

{ID} {
    if (yyleng > 31) {
        error("E5", "identificador de más de 31 caracteres", linea, col);
    } else {
        tabla_agregar(yytext, linea);
        return token("IDENTIFICADOR", T_IDENTIFICADOR);
    }
}

{REAL}                       { return token("REAL", T_REAL); }
{DIG}+                       { return token("ENTERO", T_ENTERO); }
({REAL}|{DIG}+)[A-Za-z0-9_.]+ { error_numero(); }

\"{CONT_CAD}\" {
    int escape_invalido = primer_escape_invalido();

    if (escape_invalido >= 0) {
        error("E6", "secuencia de escape no válida", linea, col + escape_invalido);
    } else {
        return token("CADENA", T_CADENA);
    }
}

\"{CONT_CAD}\\? {
    error("E2", "cadena sin cerrar", linea, col);
}

"=="|"!="|"<="|">="|"<"|">" { return token("OP_RELACIONAL", T_OP_RELACIONAL); }
"&&"|"||"|"!"              { return token("OP_LOGICO", T_OP_LOGICO); }
"="                        { return token("ASIGNACION", T_ASIGNACION); }
[-+*/%]                    { return token("OP_ARITMETICO", T_OP_ARITMETICO); }
[(){}\[\];,]               { return token("DELIMITADOR", T_DELIMITADOR); }
.                          { error_caracter(); }

<<EOF>> {
    printf("%d:%d\tFIN\t\n", sig_linea, sig_col);
    return T_FIN;
}
%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            perror(argv[1]);
            return 1;
        }
    }

    while (yylex() != T_FIN) {
        /* Cada llamada consume hasta el siguiente token válido o el fin. */
    }

    putchar('\n');
    tabla_imprimir();
    printf("\ntokens: %d      errores: %d\n", ntokens, nerrores);

    if (argc > 1) {
        fclose(yyin);
    }

    return 0;
}
