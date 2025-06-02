%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char op[10];
    char arg1[20];
    char arg2[20];
    char result[20];
} TAC;

TAC code[200];
int code_count = 0;
int temp_count = 0;
int label_count = 0;

char* new_temp() {
    char* temp = malloc(10);
    sprintf(temp, "t%d", temp_count++);
    return temp;
}

char* new_label() {
    char* label = malloc(10);
    sprintf(label, "L%d", label_count++);
    return label;
}

void gen_code(char* op, char* arg1, char* arg2, char* result) {
    strcpy(code[code_count].op, op);
    strcpy(code[code_count].arg1, arg1 ? arg1 : "");
    strcpy(code[code_count].arg2, arg2 ? arg2 : "");
    strcpy(code[code_count].result, result ? result : "");
    code_count++;
}

void print_code() {
    printf("\n=== CÓDIGO INTERMEDIÁRIO ===\n");
    for (int i = 0; i < code_count; i++) {
        printf("%d: %s %s %s %s\n", i, 
               code[i].op, code[i].arg1, code[i].arg2, code[i].result);
    }
}

extern int yylex();
void yyerror(const char* s) {
    printf("Erro: %s\n", s);
}
%}

%union {
    char* str;
    int num;
    float fnum;
}

%token <str> ID
%token <num> NUM
%token <fnum> FNUM
%token <str> CNUM
%token INT FLOAT CHAR
%token IF ELSE WHILE
%token READ WRITE MAIN
%token PLUS MINUS MULT DIV ASSIGN
%token EQ NE LT GT
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE

%type <str> expr term factor
%type <str> type 

%left PLUS MINUS
%left MULT DIV
%right ASSIGN

%%

program:
    MAIN LPAREN RPAREN LBRACE stmt_list RBRACE
    {
        printf("Programa compilado com sucesso!\n");
        print_code();
    }
    ;

stmt_list:
    stmt_list stmt
    | stmt
    ;

stmt:
    decl_stmt
    | assign_stmt
    | if_stmt
    | while_stmt
    | read_stmt
    | write_stmt
    ;

decl_stmt:
    type ID SEMICOLON
    {
        gen_code("DECL", $1, "", $2);
    }
    | type ID ASSIGN expr SEMICOLON
    {
        gen_code("DECL", $1, "", $2);
        gen_code("=", $4, "", $2);
    }
    ;

type:
    INT     { $$ = "int"; }
    | FLOAT { $$ = "float"; }
    | CHAR  { $$ = "char"; }
    ;

assign_stmt:
    ID ASSIGN expr SEMICOLON
    {
        gen_code("=", $3, "", $1);
    }
    ;

if_stmt:
    IF LPAREN expr RPAREN LBRACE stmt_list RBRACE
    {
        char* label = new_label();
        gen_code("IF", $3, "", label);
        gen_code("LABEL", label, "", "");
    }
    | IF LPAREN expr RPAREN LBRACE stmt_list RBRACE ELSE LBRACE stmt_list RBRACE
    {
        char* label1 = new_label();
        char* label2 = new_label();
        gen_code("IF", $3, "", label1);
        gen_code("GOTO", label2, "", "");
        gen_code("LABEL", label1, "", "");
        gen_code("LABEL", label2, "", "");
    }
    ;

while_stmt:
    WHILE LPAREN expr RPAREN LBRACE stmt_list RBRACE
    {
        char* start = new_label();
        char* end = new_label();
        gen_code("LABEL", start, "", "");
        gen_code("IF_FALSE", $3, "", end);
        gen_code("GOTO", start, "", "");
        gen_code("LABEL", end, "", "");
    }
    ;

read_stmt:
    READ LPAREN ID RPAREN SEMICOLON
    {
        gen_code("READ", "", "", $3);
    }
    ;

write_stmt:
    WRITE LPAREN expr RPAREN SEMICOLON
    {
        gen_code("WRITE", $3, "", "");
    }
    ;

expr:
    expr EQ expr    { $$ = new_temp(); gen_code("==", $1, $3, $$); }
    | expr NE expr  { $$ = new_temp(); gen_code("!=", $1, $3, $$); }
    | expr LT expr  { $$ = new_temp(); gen_code("<", $1, $3, $$); }
    | expr GT expr  { $$ = new_temp(); gen_code(">", $1, $3, $$); }
    | expr PLUS term  { $$ = new_temp(); gen_code("+", $1, $3, $$); }
    | expr MINUS term { $$ = new_temp(); gen_code("-", $1, $3, $$); }
    | term
    ;

term:
    term MULT factor
    {
        $$ = new_temp();
        gen_code("*", $1, $3, $$);
    }
    | term DIV factor
    {
        $$ = new_temp();
        gen_code("/", $1, $3, $$);
    }
    | factor
    ;

factor:
    ID { $$ = $1; }
    | NUM   
    { 
        $$ = malloc(10);
        sprintf($$, "%d", $1);
    }
    | FNUM  
    { 
        $$ = malloc(10);
        sprintf($$, "%.2f", $1);
    }
    | CNUM  { $$ = $1; }
    | LPAREN expr RPAREN { $$ = $2; }
    ;

%%

int main() {
    printf("=== COMPILADOR CIMPLES ===\n");
    return yyparse();
}