%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern int yylineno;
extern char *yytext;

extern FILE *yyin;
void yyerror(const char *s) {
    fprintf(stderr, "Error sintáctico en la línea %d cerca de '%s': %s\n", yylineno, yytext, s);
}



%}

// Para manejar valores de tokens

%union {
    char* str;   // Para identificadores/cadenas
    int num;     // Para enteros
    float fnum;  // Para reales
}


// Declara TODOS los tokens usados en lexer.l
%token T_BOOL T_CADE T_CONTINUAR T_DEVO T_ENT T_FALS T_FLOTA T_GLOBAL
%token T_HAZ T_MIENTRAS T_NULO T_PARA T_PARAR T_SI T_SINO T_VER

%token T_MENOR T_MAYOR T_CORRIZQ T_CORRDER T_ALMOHADILLA T_ALMOHOADILLAFIN
%token T_ASTERISCO T_PIPE T_GRADO

%token T_SUM T_REST T_MULT T_DIV T_MOD T_INC T_DEC T_EXP T_DIVE
%token T_H T_M T_E T_C T_HE T_ME

%token T_ASIG T_SUMASIG T_RESASIG T_MULTASIG T_DIVASIG T_MODASIG
%token T_CORRDASIG T_CORRIASIG T_EXPASIG T_CONCATASIG

%token <str> T_IDENTIFICADOR T_CADENA
%token <num> T_ENTE
%token <fnum> T_REAL

// Precedencia de operadores
%left '+' '-'
%left '*' '/' '%'
%right '^'

%%

Programa:
    ListDecGlob Func otraFunc
    ;

ListDecGlob:
    DecGlob ListDecGlob
    |
    ;

otraFunc:
    Func otraFunc
    |
    ;

DecGlob:
    T_GLOBAL Decl
    ;

Decl:
    Tipo T_IDENTIFICADOR list T_ASTERISCO
    ;

Tipo: 
    T_BOOL
    | T_CADE
    | T_ENT
    | T_FLOTA
    ;

list:
    T_PIPE T_IDENTIFICADOR list
    |
    ;

Func: 
    Tipo T_IDENTIFICADOR T_MENOR Arg T_MAYOR T_CORRIZQ cuerpo T_CORRDER
    ;

Arg: 
    Tipo T_IDENTIFICADOR listArg
    ;

listArg:
    T_PIPE Arg
    |
    ;

cuerpo:
    listaDec listaSent
    ;

listaDec:
    Decl listaDec
    |
    ;

Asig:
    T_IDENTIFICADOR opAsig T_GRADO
    ;

opAsig:
    opAsigSimple ExprGral
    | opAsigComp E
    ;

opAsigSimple:
    T_ASIG
    ;

opAsigComp:
    T_SUMASIG
    | T_RESASIG
    | T_MULTASIG
    | T_DIVASIG
    | T_MODASIG
    | T_CORRDASIG
    | T_CORRIASIG
    | T_EXPASIG
    | T_CONCATASIG
    ;

ExprGral:
    T_CADENA
    | T_FALS
    | T_VER
    | T_NULO
    | E
    ;

E:
    T EP
    ;

EP:
    T_SUM T EP
    | T_REST T EP
    |
    ;

T:
    F TP
    ;

TP:
    T_MULT F TP
    | T_DIV F TP 
    | T_MOD F TP 
    | T_DIVE F TP 
    | T_EXP F TP 
    | 
    ;

F: 
    T_MENOR E T_MAYOR
    | T_IDENTIFICADOR G 
    | FP T_IDENTIFICADOR
    | T_ENTE
    | T_REAL
    | LlamaFunc
    ;

FP: 
    T_INC
    | T_DEC
    ;

G: 
    T_INC
    | T_DEC
    |
    ;

expRel:
    E opRel E
    ;

opRel:
    T_H
    | T_M
    | T_E
    | T_C
    | T_HE
    | T_ME
    ;

Sent:
    Asig
    | HazM
    | Si
    | Para
    | Dev
    | T_CONTINUAR T_GRADO
    | T_PARAR T_GRADO
    ;

listaSent:
    Sent listaSent
    |
    ;

HazM:
    T_HAZ T_CORRIZQ listaSent T_CORRDER T_MIENTRAS T_MENOR expRel T_MAYOR
    ;

Si: 
    T_SI T_MENOR expRel T_MAYOR T_CORRIZQ listaSent T_CORRDER Sino
    ;

Sino: 
    T_SINO T_CORRIZQ listaSent T_CORRDER
    |
    ;

Para:
    T_PARA T_MENOR E T_MAYOR T_CORRIZQ listaSent T_CORRDER
    ;

Dev:
    T_DEVO T_MENOR valRet T_MAYOR T_GRADO
    ;

valRet:
    ExprGral
    |
    ;

LlamaFunc:
    T_ALMOHADILLA T_IDENTIFICADOR T_MENOR listP T_MAYOR T_ALMOHOADILLAFIN
    ;

listP:
    ExprGral Param
    | 
    ;

Param: 
    T_PIPE ExprGral Param
    |
    ;

%% 

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error al abrir el archivo");
            return 1;
        }
    }
    yyparse();
    return 0;
}