%option noyywrap nodefault yylineno noinput nounput never-interactive
%{
#include "parser.tab.h"
#include <stdio.h>
%}
LETRA   [A-Za-z_]
DIGITO  [0-9]
%%
[ \t\r\n]+                         { /* ignorar espacios */ }
"//"[^\n]*                         { /* ignorar comentario */ }
"if"                               { return SI; }
"else"                             { return SINO; }
{LETRA}({LETRA}|{DIGITO})*         { return ID; }
{DIGITO}+                          { return NUM; }
"="                                { return ASIGNA; }
"+"                                { return MAS; }
"*"                                { return POR; }
"("                                { return PAR_I; }
")"                                { return PAR_D; }
";"                                { return PUNTO_COMA; }
. {
    fprintf(stderr, "Error lexico en la linea %d: caracter '%s'\n",
            yylineno, yytext);
    return (unsigned char) yytext[0];
}
%%