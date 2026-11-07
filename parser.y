%require "3.7"
%{
#include <stdio.h>

int yylex(void);
void yyerror(const char *mensaje);
extern int yylineno;
%}

%define lr.type lalr
%define parse.error detailed
%define parse.lac full

%token ID "identificador" NUM "numero"
%token SI "if" SINO "else"
%token ASIGNA "=" MAS "+" POR "*"
%token PAR_I "(" PAR_D ")" PUNTO_COMA ";"

%left MAS
%left POR

%start programa

%%
programa:
    %empty
  | programa sentencia
  ;

sentencia:
    sentencia_emparejada
  | sentencia_no_emparejada
  ;

sentencia_emparejada:
    ID ASIGNA expr PUNTO_COMA
  | SI PAR_I expr PAR_D sentencia_emparejada SINO sentencia_emparejada
  ;

sentencia_no_emparejada:
    SI PAR_I expr PAR_D sentencia
  | SI PAR_I expr PAR_D sentencia_emparejada SINO sentencia_no_emparejada
  ;

expr:
    ID
  | NUM
  | expr MAS expr
  | expr POR expr
  | PAR_I expr PAR_D
  ;
%%

void yyerror(const char *mensaje)
{
    fprintf(stderr, "Error sintactico en la linea %d: %s\n",
            yylineno, mensaje);
}

int main(void)
{
    return yyparse();
}