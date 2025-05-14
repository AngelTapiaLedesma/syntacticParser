%{
/*
Elaborado por:
Tapia Ledesma Angel Hazel 
Arroyo Ramirez Carlos Alberto
Fecha de entrega: 18/03/2025

Objetivo: Elaborar un analizador léxico en lex/flex que reconozca los componentes léxicos pertenecientes 
a las clases abajo descritas y que fueron definidas en clase. 
Generando un analizador el cual reconozca de forma óptima las componentes del lenguaje para así posteriormente 
adjuntar su salida con la entrada del analizador sintáctico.

char *palRes[16][2] = {
    {"Bool","b"},
    {"Cade","c"},
    {"Continuar","t"},
    {"Devo","d"},
    {"Ent","n"},
    {"Fals","q"},
    {"Flota","f"},
    {"Global","g"},
    {"Haz","h"},
    {"Mientras","w"},
    {"Nulo","u"},
    {"Para","o"},
    {"Parar","p"},
    {"Si","i"},
    {"Sino","l"},
    {"Ver","m"}
};
*/
#include <stdio.h>

// Estructuras para las tablas
typedef struct Literal {
    int valor;
    char *literal;
    struct Literal *siguiente;
} Literal;

typedef struct Simbolo {
    int valor;
    char *nombre;
    int tipo;
    struct Simbolo *siguiente;
} Simbolo;

// Prototipos de las funciones
int buscar_catalogo(char *catalogo[], char *literal, int tamano);
char *token(int pos, char *yytext, char *catalogo[], int tamano);

Simbolo *crear_tabla_simbolos();
Simbolo *agrega_simbolo(Simbolo *tabla, char *nombre);
Simbolo *buscar_simbolo(Simbolo *tabla, char *nombre);
void imprimir_tabla_simbolos(Simbolo *tabla, char *nombre_arch);
char *token_simbolos(int pos, char *nombre, Simbolo **tabla);

FILE *abrir_archivo(const char *nombre_archivo, const char *modo);
void cerrar_archivo(FILE*archivo);
char *errores(char *yytext);

Literal *crear_tabla();
Literal *agrega_literal(Literal *tabla, char *literal);
Literal *buscar_literal(Literal *tabla, char *literal);
void imprimir_tabla(Literal *tabla, char *nombre_arch);
char *token_literales(int pos, char *nombre, Literal **tabla);

// Atomos
char *generarAtomo(int pos, int val);
char *atomoPalRes(int val);
char *atomoSimbEsp(int val);
char *atomoOpArim(int val);
char *atomoOpRel(int val);
char *atomoOpAsig(int val);

// Creación de las tablas dinámicas
Simbolo *tabla_simbolos = NULL;
Literal *tabla_cadenas = NULL;
Literal *tabla_reales = NULL;
Literal *tabla_enteros = NULL;


// Catalogos
char *palRes[16] = {
    "Bool",
    "Cade",
    "Continuar",
    "Devo",
    "Ent",
    "Fals",
    "Flota",
    "Global",
    "Haz",
    "Mientras",
    "Nulo",
    "Para",
    "Parar",
    "Si",
    "Sino",
    "Ver"
};

char *opArim[9] = {
    "sum",
    "rest",
    "mult",
    "div",
    "mod",
    "inc",
    "dec",
    "exp",
    "dive"
};

char *opAsign[10] = {
    "->",
    "+->",
    "-->",
    "*->",
    "/->",
    "%->",
    ">>->",
    "<<->",
    "^->",
    "&->"
};

char *simbEsp[9] = {
    "<",
    ">",
    "<<",
    ">>",
    "#",
    "!#",
    "*",
    "|",
    "°"
};

char *opRel[6] = {
    "h",
    "m",
    "e",
    "c",
    "he",
    "me"
};

// Funciones para la tabla de simbolos
 
Simbolo *agrega_simbolo(Simbolo *tabla, char *nombre) {
    Simbolo *res = buscar_simbolo(tabla,nombre);

    if( res == NULL){ // Checa si el elemento NO existe, para crearlo
        Simbolo *nuevoSimbolo = (Simbolo *)malloc(sizeof(Simbolo));
        nuevoSimbolo->nombre = strdup(nombre);
        nuevoSimbolo->tipo = -1;
        nuevoSimbolo->siguiente = NULL;

        if (tabla == NULL) {
            nuevoSimbolo->valor = 0;
            return nuevoSimbolo;
        }
        Simbolo *actual = tabla; // temporal que almacena el inicio de la tabla
        while (actual->siguiente != NULL) {
            actual = actual->siguiente;
        }
        nuevoSimbolo->valor = actual->valor + 1; // Asigna la posición del último elemento + 1
        actual->siguiente = nuevoSimbolo; // se inserta al final de la tabla
    }
    return tabla; // Si existe, regresa la tabla, si no existe lo crea y también regresa la tabla
}

Simbolo *buscar_simbolo(Simbolo *tabla, char *nombre) {
    Simbolo *actual = tabla;
    while (actual != NULL) {
        if (strcmp(actual->nombre, nombre) == 0) {
            return actual; // Retornamos el valor 
        }
        actual = actual->siguiente;
    }
    return NULL;
}

void imprimir_tabla_simbolos(Simbolo *tabla, char *nombre_arch) {
    Simbolo *actual = tabla;
    FILE *archTablas = abrir_archivo(nombre_arch,"a");
    if (actual == NULL) {
        printf("La tabla de símbolos está vacía.\n");
        return;
    }
    printf("Pos\tNombre\t\tTipo\n");
    fprintf(archTablas,"Pos\tNombre\t\tTipo\n");
    while (actual != NULL) {
        printf("%d\t%s\t%d\n",actual->valor, actual->nombre, actual->tipo);
	    fprintf(archTablas,"%d\t%s\t%d\n",actual->valor, actual->nombre, actual->tipo);
        actual = actual->siguiente;
    }
    cerrar_archivo(archTablas);
}

// Funciones para las tablas de cadenas, reales y enteros

Literal *agrega_literal(Literal *tabla, char *literal) {
    // Buscar si la literal ya existe en la tabla
    Literal *res = buscar_literal(tabla, literal);

    if (res == NULL) { // Checa si el elemento NO existe, para crearlo
        Literal *NuevaLiteral = (Literal *)malloc(sizeof(Literal));
        NuevaLiteral->literal = strdup(literal);
        NuevaLiteral->siguiente = NULL;

        if (tabla == NULL) {
            NuevaLiteral->valor = 0; // El primer elemento tiene posición 0
            return NuevaLiteral;
        }

        Literal *actual = tabla; // temporal que almacena el inicio de la tabla
        while (actual->siguiente != NULL) {
            actual = actual->siguiente;
        }
        NuevaLiteral->valor = actual->valor + 1; // Asigna la posición del último elemento + 1
        actual->siguiente = NuevaLiteral; // se inserta al final de la tabla
    }
    return tabla; // Si existe, regresa la tabla, si no existe lo crea y también regresa la tabla
}

Literal *buscar_literal(Literal *tabla, char *literal) {
    Literal *actual = tabla;
    while (actual != NULL) {
        if (strcmp(actual->literal, literal) == 0) {
            return actual; // Retornamos el valor 
        }
        actual = actual->siguiente;
    }
    return NULL;
}

void imprimir_tabla(Literal *tabla, char *nombre_arch) {
    Literal *actual = tabla;
    FILE *archTablas = abrir_archivo(nombre_arch,"a");

    if (actual == NULL) {
        printf("La tabla de literales está vacía.\n");
        return;
    }
    fprintf(archTablas,"Pos\tLiteral\n");
    printf("Pos\tLiteral\n");
    while (actual != NULL) {
        printf("%d\t%s\n", actual->valor, actual->literal);
        fprintf(archTablas,"%d\t%s\n", actual->valor, actual->literal);
        actual = actual->siguiente;
    }
    cerrar_archivo(archTablas);
}

int buscar_catalogo(char *catalogo[], char *literal, int tamano) {
    for(int i = 0;i<tamano;i++){
        if(strcmp(catalogo[i], literal) == 0){
            return i;
        }
    }
    return -1;
}

// generador de tokens de tablas estáticas
char *token(int pos, char *yytext, char *catalogo[], int tamano){
    int valor = 0;
    valor = buscar_catalogo(catalogo,yytext,tamano);
    printf("(%i,%i)\t",pos,valor);
    FILE *archTokens = abrir_archivo("tokens.txt","a");
    fprintf(archTokens, "%i,%i\n", pos, valor);
    cerrar_archivo(archTokens);
    // Sintactico
    printf("%s\t",generarAtomo(pos,valor));
    return "Caracter";
}

// Generador de tokens de tablas dinámicas
char *token_simbolos(int pos, char *nombre, Simbolo **tabla) {
    *tabla = agrega_simbolo(*tabla, nombre);
    Simbolo *simbolo = buscar_simbolo(*tabla, nombre);
    printf("(%i,%i)", pos, simbolo->valor);

    FILE *archTokens = abrir_archivo("tokens.txt","a");
    fprintf(archTokens, "%i,%i\n", pos, simbolo->valor);
    cerrar_archivo(archTokens);
    return "Caracter";
}

char *token_literales(int pos, char *nombre, Literal **tabla) {
    *tabla = agrega_literal(*tabla, nombre);
    Literal *literal = buscar_literal(*tabla, nombre);
    printf("(%i,%i)", pos, literal->valor);
    
    FILE *archTokens = abrir_archivo("tokens.txt","a");
    fprintf(archTokens, "%i,%i\n", pos, literal->valor);
    cerrar_archivo(archTokens);
    return "Caracter";
}

char *errores(char *yytext){
    FILE *archErr = abrir_archivo("errores.txt","a");
    fprintf(archErr, "Caracter no reconocido: %s\n", yytext);
    cerrar_archivo(archErr);
    return "Caracter";
}

// Manipulación de Archivos 
FILE *abrir_archivo(const char *nombre_archivo, const char *modo) {
    FILE *archivo = fopen(nombre_archivo, modo);
    if (archivo == NULL) {
        perror("Error al abrir el archivo");
        exit(1); // Termina el programa si no se puede abrir el archivo
    }
    return archivo;
}

void cerrar_archivo(FILE *archivo) {
    fclose(archivo);
}

// Analisis sintactico 
char *generarAtomo(int pos, int val){
    switch(pos){
        case 0:
            return atomoPalRes(val);
        case 1:
            return atomoSimbEsp(val);
        case 2:
            break;
        case 3:
            return atomoOpArim(val);
        case 4:
            return atomoOpRel(val);
        case 5:
            return atomoOpAsig(val);
        case 6:
            break;
        case 7:
            break;
        case 8:
            break;
        default:
            break;

    }
}


char *atomoPalRes(int val){
    switch(val){
        case 0:
            return "b";
        case 1:
            return "c";
        case 2:
            return "t";
        case 3:
            return "d";
        case 4:
            return "n";
        case 5:
            return "q";
        case 6:
            return "f";
        case 7:
            return "g";
        case 8:
            return "h";
        case 9:
            return "w";
        case 10:
            return "u";
        case 11:
            return "o";
        case 12:
            return "p";
        case 13:
            return "i";
        case 14:
            return "l";
        case 15:
            return "m";
        default:
            break;
    }
}
char *atomoSimbEsp(int val){
    switch(val){
        case 0:
            return "(";
        case 1:
            return ")";
        case 2:
            return "[";
        case 3:
            return "]";
        case 4:
            return "{";
        case 5:
            return "}";
        case 6:
            return ";";
        case 7:
            return ",";
        case 8:
            return ".";
        default:
            break;
    }
}
char *atomoOpArim(int val){
    switch(val){
        case 0:
            return "+";
        case 1:
            return "-";
        case 2:
            return "*";
        case 3:
            return "/";
        case 4:
            return "%";
        case 5:
            return "z";
        case 6:
            return "j";
        case 7:
            return "k";
        case 8:
            return "~";
        default:
            break;
    }
}
char *atomoOpRel(int val){
    switch(val){
        case 0:
            return ">";
        case 1:
            return "<";
        case 2:
            return "¡";
        case 3:
            return "!";
        case 4:
            return "x";
        case 5:
            return "y";
        default:
            break;
    }
}
char *atomoOpAsig(int val){
    switch(val){
        case 0:
            return "=";
        case 1:
            return "#";
        case 2:
            return "ñ";
        case 3:
            return "$";
        case 4:
            return "v";
        case 5:
            return "?";
        case 6: 
            return ":";
        case 7: 
            return "\"";
        case 8: 
            return "^";
        case 9: 
            return "&";
        default:
            break;
    }
}



%}
%option noyywrap

digito      [0-9]

letra       [a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]

comentario   \[.+\]

palRes Bool|Cade|Continuar|Devo|Ent|Fals|Flota|Global|Haz|Mientras|Nulo|Para|Parar|Si|Sino|Ver

simbEsp "<"|">"|"<<"|">>"|"#"|"#!"|"*"|"|"|"°"

opArim sum|rest|mult|div|mod|inc|dec|exp|dive

opRel "h"|"m"|"e"|"c"|"he"|"me"

opAsign "->"|"+->"|"-->"|"*->"|"/->"|"%->"|">>->"|"<<->"|"^->"|"&->"

identificador @({letra}|{digito})+_

cadena --.*--

ent [+-]?(0|[1-9]{digito}*)[pg]?

real (({ent}?'{digito}+)|({ent}[rR]))

%%

{palRes}       {token(0, yytext, palRes, 16); printf(" %s es una palabra reservada\n", yytext);}
{opArim}       {token(3, yytext, opArim, 9); printf(" %s es un operador aritmetico\n", yytext); }
{opAsign}      {token(5, yytext, opAsign, 10); printf(" %s es un operador de asignacion\n", yytext); }
{simbEsp}      {token(1, yytext, simbEsp, 9); printf(" %s es un simbolo especial\n", yytext); }
{opRel}        {token(4, yytext, opRel, 6); printf(" %s es un operador relacional\n", yytext); }
{cadena}       {token_literales(8, yytext, &tabla_cadenas);printf("%s es una cadena\n", yytext); }
{comentario}   {printf("%s es un comentario\n", yytext); }
{identificador} {token_simbolos(2, yytext, &tabla_simbolos); printf("%s es una identificador\n", yytext); }
{real}          {token_literales(8, yytext, &tabla_reales); printf("%s es un real\n", yytext); }
{ent}           {token_literales(8, yytext, &tabla_enteros);printf("%s es un entero\n", yytext); }
[ \t\n\r]+ ; // Ignorar espacios, tabulaciones y saltos de      línea
.              {errores(yytext); printf("%s no es reconocido\n", yytext); }
%%

int main(int argc, char **argv) {
    // Lee desde un archivo 
    // Verificar si se proporcionó un archivo de entrada
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r"); // Abrir el archivo en modo lectura
        if (!file) {
            perror("Error al abrir el archivo");
            return 1;
        }
        yyin = file; // Redirigir la entrada de yylex al archivo
    } else {
        printf("Uso: %s <archivo_de_entrada>\n", argv[0]);
        return 1;
    }

    // Escribe los tokens
    FILE *archTokens = abrir_archivo("tokens.txt","w");
    fprintf(archTokens, ""); // Sobreescribe cada vez que se inicia el programa para que inicie vacío
    cerrar_archivo(archTokens);

    //Escribe los Errores 
    FILE *archErr = abrir_archivo("errores.txt","w");
    fprintf(archErr, ""); // Sobreescribe cada vez que se inicia el programa para que inicie vacío
    cerrar_archivo(archErr);
    
    //Escribe la tabla de simbolos 
    FILE *archSimbolos = abrir_archivo("simbolos.txt","w");
    fprintf(archSimbolos, ""); // Sobreescribe cada vez que se inicia el programa para que inicie vacío
    cerrar_archivo(archSimbolos);
    
    //Escribe la tabla de enteros 
    FILE *archEnteros = abrir_archivo("enteros.txt","w");
    fprintf(archEnteros, ""); // Sobreescribe cada vez que se inicia el programa para que inicie vacío
    cerrar_archivo(archEnteros);
    
    //Escribe la tabla de flotantes 
    FILE *archFlotantes = abrir_archivo("reales.txt","w");
    fprintf(archFlotantes, ""); // Sobreescribe cada vez que se inicia el programa para que inicie vacío
    cerrar_archivo(archFlotantes);

    //Escribe la tabla de cadenas
    FILE *archCadenas = abrir_archivo("cadenas.txt","w");
    fprintf(archCadenas, ""); // Sobreescribe cada vez que se inicia el programa para que inicie vacío
    cerrar_archivo(archCadenas);

    yylex();  // Ejecutar el analizador léxico
    fclose(yyin);

    // Impresión de las tablas en consola
    printf("\nTabla de simbolos\n");
    imprimir_tabla_simbolos(tabla_simbolos, "simbolos.txt");

    printf("\nTabla de cadenas\n");
    imprimir_tabla(tabla_cadenas, "cadenas.txt");

    printf("\nTabla de enteros\n");
    imprimir_tabla(tabla_enteros,"enteros.txt");
    
    printf("\nTabla de reales\n");
    imprimir_tabla(tabla_reales, "reales.txt");

    return 0;
}