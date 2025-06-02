%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int line_num = 1;
%}

%option noyywrap
%option nounput
%option noinput 

%%

[ \t]+  { /* ignora espaços */ }
\n      { line_num++; }
"//".*  { /* comentários */ }
"int"   { return INT; }
"float" { return FLOAT; }
"char"  { return CHAR; }
"if"    { return IF; }
"else"  { return ELSE; }
"while" { return WHILE; }
"read"  { return READ; }
"write" { return WRITE; }
"main"  { return MAIN; }
"+"     { return PLUS; }
"-"     { return MINUS; }
"*"     { return MULT; }
"/"     { return DIV; }
"="     { return ASSIGN; }
"=="    { return EQ; }
"!="    { return NE; }
"<"     { return LT; }
">"     { return GT; }
";"     { return SEMICOLON; }
"("     { return LPAREN; }
")"     { return RPAREN; }
"{"     { return LBRACE; }
"}"     { return RBRACE; }

[a-zA-Z][a-zA-Z0-9]* { 
    yylval.str = strdup(yytext); 
    return ID; 
}

[0-9]+ { 
    yylval.num = atoi(yytext); 
    return NUM; 
}

[0-9]+\.[0-9]+ { 
    yylval.fnum = atof(yytext); 
    return FNUM; 
}

\'[^\']*\' { 
    yylval.str = strdup(yytext); 
    return CNUM; 
}

. { printf("Erro: caractere inválido '%c'\n", yytext[0]); }

%%