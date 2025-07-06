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
char* last_label() {
    char* label = malloc(10);
    sprintf(label, "L%d", label_count - 1);
    return label;
}
// Gera código intermediário em 3 endereços - Conceito C
void gen_code(char* op, char* arg1, char* arg2, char* result) {
    strcpy(code[code_count].op, op);
    strcpy(code[code_count].arg1, arg1 ? arg1 : "");
    strcpy(code[code_count].arg2, arg2 ? arg2 : "");
    strcpy(code[code_count].result, result ? result : "");
    code_count++;
}
void gen_code_2(char* op, char* arg1, char* arg2, char* result) {
    code[code_count] = code[code_count - 1];
    strcpy(code[code_count - 1].op, op);
    strcpy(code[code_count - 1].arg1, arg1 ? arg1 : "");
    strcpy(code[code_count - 1].arg2, arg2 ? arg2 : "");
    strcpy(code[code_count - 1].result, result ? result : "");
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
    struct {
        char* start_loop;
        char* end_loop;
    } loop_labels;
    struct {
        char* else_cond;
        char* end_cond;
    } cond_labels;
}

%token <str> ID
%token <num> NUM
%token <fnum> FNUM
%token <str> CNUM
%token INT FLOAT CHAR
%token IF ELSE WHILE DO
%token READ WRITE MAIN
%token PLUS MINUS MULT DIV ASSIGN
%token EQ NE LT GT
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE

%type <str> expr term factor
%type <str> type 
%type <cond_labels> if_start else_stmt
%type <loop_labels> while_start_action do_start
%type <str> while_stmt do_stmt

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
    | do_stmt
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
// Definição de 3 tipos de dados - conceito C
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
// Estrutura de decisão 
if_stmt:
// se então - conceito C
    IF if_start LPAREN expr RPAREN LBRACE // se 
    {
        gen_code("IF_FALSE", $4, "", $2.else_cond);
    }
    stmt_list RBRACE // então
    {
        gen_code("LABEL", $2.else_cond, "", "");
    }
    else_stmt
    ;
if_start:
    {
        $$.else_cond = new_label();
    }
else_stmt: // se não - conceito B
    {}
    |
    ELSE LBRACE
    {
        $$.end_cond = new_label();
        gen_code_2("GOTO", $$.end_cond, "", "");
    }
    stmt_list RBRACE
    {
        gen_code("LABEL", last_label(), "", "");
    }
    ;
// Estrutura de repetição - conceito C
while_stmt:
    WHILE LPAREN while_start_action expr RPAREN LBRACE 
    {
        gen_code("IF_FALSE", $4, "", $3.end_loop);
    }
    stmt_list RBRACE
    {
        gen_code("GOTO", $3.start_loop, "", ""); 
        gen_code("LABEL", $3.end_loop, "", "");
    }
    ;
while_start_action:
    {
        $$.start_loop = new_label();
        $$.end_loop = new_label();
        gen_code("LABEL", $$.start_loop, "", "");
    }
    ;
// Segunda estrutura de repetição do-while - conceito B
do_stmt:
    DO LBRACE do_start stmt_list RBRACE WHILE LPAREN expr RPAREN SEMICOLON
    {
        gen_code("IF_FALSE", $8, "", $3.end_loop);
        gen_code("GOTO", $3.start_loop, "", "");
        gen_code("LABEL", $3.end_loop, "", "");
    }
    ;
do_start:
    {
        $$.start_loop = new_label();
        $$.end_loop = new_label();
        gen_code("LABEL", $$.start_loop, "", "");
    }
    ;
// Comandos de leitura e escrita - conceito C
read_stmt:
    READ LPAREN ID RPAREN SEMICOLON
    {
        gen_code("READ", $3, "", "");
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