/* minilang.l — PUNTO DE PARTIDA del proyecto: el analizador de la práctica de Flex (Semana 5).
   Ya reconoce los tokens y los errores E1 a E4. Falta: E5, E6, tabla de símbolos,
   return de los códigos de tokens.h y el bucle de yylex() en main. */
%{
#include <stdio.h>
int linea = 1, col = 1;              /* posición donde empieza el lexema actual */
static int sig_linea = 1, sig_col = 1;
static int com_linea, com_col;        /* dónde empezó un comentario de bloque */
int ntokens = 0, nerrores = 0;

/* Se ejecuta antes de cada acción: guarda la posición y avanza el contador */
#define YY_USER_ACTION { linea = sig_linea; col = sig_col;               \
    for (int i = 0; i < yyleng; i++)                                     \
        if (yytext[i] == '\n') { sig_linea++; sig_col = 1; }             \
        else sig_col++; }

static void token(const char *tipo) {
    printf("%d:%d\t%s\t%s\n", linea, col, tipo, yytext);
    ntokens++;
}
static void error(const char *cod, const char *msg, int l, int c) {
    printf("%d:%d\tERROR %s\t%s\n", l, c, cod, msg);
    nerrores++;
}
static void error_caracter(void) {          /* E1: muestra el byte en hexadecimal */
    char msg[64];
    unsigned char b = (unsigned char) yytext[0];
    if (b >= 32 && b < 127) sprintf(msg, "carácter no válido '%c'", b);
    else sprintf(msg, "byte no válido 0x%02X", b);
    error("E1", msg, linea, col);
}
static void error_numero(void) {           /* E4: muestra el lexema completo */
    char msg[160];
    snprintf(msg, sizeof msg, "número mal formado '%.120s'", yytext);
    error("E4", msg, linea, col);
}
%}
%option noyywrap nounput noinput
%x COMENT

DIG     [0-9]
LETRA   [A-Za-z_]
ID      {LETRA}({LETRA}|{DIG})*
REAL    {DIG}+"."{DIG}+([eE][+-]?{DIG}+)?|{DIG}+[eE][+-]?{DIG}+

%%
[ \t\r\n]+              { /* espacios: se descartan */ }
"//".*                  { /* comentario de línea */ }
"/*"                    { com_linea = linea; com_col = col; BEGIN(COMENT); }
<COMENT>"*/"            { BEGIN(INITIAL); }
<COMENT>[^*\n]+|"*"|\n  { /* dentro del comentario */ }
<COMENT><<EOF>>         { error("E3", "comentario sin cerrar", com_linea, com_col); BEGIN(INITIAL); }

entero|real|cadena|logico|si|sino|mientras|para|funcion|retornar|imprimir|leer|verdadero|falso {
                          token("PALABRA_RESERVADA"); }
{ID}   {

    if (yyleng > 31){
        error("E5", "identificador de más de 31 caracteres", linea, col);
    }else{
        token("IDENTIFICADOR");
    }
}                 

{REAL}                  { token("REAL"); }
{DIG}+                  { token("ENTERO"); }
({REAL}|{DIG}+)[A-Za-z0-9_.]+ { error_numero(); }

\"(\\[^\n]|[^"\\\n])*\" { token("CADENA"); }
\"(\\[^\n]|[^"\\\n])*   { error("E2", "cadena sin cerrar", linea, col); }
\"([^\"\n\\]|\\[ntr\"\\\\])*\\[^ntr\"\\\\].*\" {error("E6", "la secuencia de escape no es valida", linea, col);}

"=="|"!="|"<="|">="|"<"|">"  { token("OP_RELACIONAL"); }
"&&"|"||"|"!"           { token("OP_LOGICO"); }
"="                     { token("ASIGNACION"); }
[-+*/%]                 { token("OP_ARITMETICO"); }
[(){}\[\];,]            { token("DELIMITADOR"); }
.                       { error_caracter(); }
<<EOF>>                 { printf("%d:%d\tFIN\t\n", sig_linea, sig_col); return 0; }
%%

int main(int argc, char *argv[]) {
    if (argc > 1 && !(yyin = fopen(argv[1], "r"))) { perror(argv[1]); return 1; }
    yylex();
    fprintf(stderr, "tokens: %d  errores: %d\n", ntokens, nerrores);
    return 0;
}
