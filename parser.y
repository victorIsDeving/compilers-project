%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

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

#define MAX_VARS 100

//conceito B - analisador semântico
typedef enum {
    VAR_SIMPLE, 
    VAR_ARRAY
} VarType;

typedef struct {
    char name[32];
    char data_type[10];
    VarType var_type;

    union {
        int int_val;
        float float_val;
        char char_val;
    } value;

    int array_size;
    void* array_data;
    bool is_init;
} Symbol;

Symbol symbol_table[MAX_VARS];
int num_symbols = 0;

Symbol* find_symbol(const char* name) {
    for (int i = 0; i < num_symbols; i++) {
        if (strcmp(symbol_table[i].name, name) == 0) {
            return &symbol_table[i];
        }
    }
    return NULL;
}

bool add_var(const char* name, const char* type) {
    if (find_symbol(name) != NULL) {
        printf("ERRO: Variável '%s' já existe\n", name);
        return false;
    }
    
    if (num_symbols >= MAX_VARS) {
        printf("ERRO: Tabela de símbolos cheia\n");
        return false;
    }
    
    strcpy(symbol_table[num_symbols].name, name);
    strcpy(symbol_table[num_symbols].data_type, type);
    symbol_table[num_symbols].var_type = VAR_SIMPLE;
    symbol_table[num_symbols].array_size = 0;
    symbol_table[num_symbols].array_data = NULL;
    symbol_table[num_symbols].is_init = false;
    
    num_symbols++;
    return true;
}

bool add_array_var(const char* name, const char* type, int size) {
    if (!find_symbol(name)) {
        printf("ERRO: Variável '%s' já existe\n", name);
        return false;
    }
    
    if (num_symbols >= MAX_VARS) {
        printf("ERRO: Tabela de símbolos cheia\n");
        return false;
    }
    
    if (strcmp(type, "int") != 0 && strcmp(type, "float") != 0 && strcmp(type, "char") != 0) {
        printf("ERRO: Tipo '%s' inválido\n", type);
        return false;
    }
    
    strcpy(symbol_table[num_symbols].name, name);
    strcpy(symbol_table[num_symbols].data_type, type);
    symbol_table[num_symbols].var_type = VAR_ARRAY;
    symbol_table[num_symbols].array_size = size;
    symbol_table[num_symbols].is_init = false;
    
    if (strcmp(type, "int") == 0) {
        symbol_table[num_symbols].array_data = calloc(size, sizeof(int));
    } else if (strcmp(type, "float") == 0) {
        symbol_table[num_symbols].array_data = calloc(size, sizeof(float));
    } else if (strcmp(type, "char") == 0) {
        symbol_table[num_symbols].array_data = calloc(size, sizeof(char));
    }
    
    num_symbols++;
    return true;
}

bool is_declared(const char* name) {
    return find_symbol(name) != NULL;
}

bool is_type_compatible(const char* left_type, const char* right_type) {
    if (strcmp(left_type, right_type) == 0) {
        return true;
    }
    
    return false;
}

bool is_valid_array_index(const char* array_name, int index) {
    Symbol* sym = find_symbol(array_name);
    if (!sym) {
        printf("ERRO: Array '%s' não foi declarado!\n", array_name);
        return false;
    }
    
    if (sym->var_type != VAR_ARRAY) {
        printf("ERRO: '%s' não é um array!\n", array_name);
        return false;
    }
    
    if (index < 0 || index >= sym->array_size) {
        printf("ERRO: Índice %d fora dos limites do array '%s' (tamanho: %d)!\n", 
               index, array_name, sym->array_size);
        return false;
    }
    
    return true;
}

char current_array[20];

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
%token SEMICOLON LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET COMMA

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
        if(add_var($2, $1)) {
            gen_code("DECL", $1, "", $2);
        } else {
            YYERROR;
        }
    }
    | type ID ASSIGN expr SEMICOLON
    {   
        if(add_var($2, $1)) {
            gen_code("DECL", $1, "", $2);
            gen_code("=", $4, "", $2);
        } else {
            YYERROR;
        }
    }
    // conceito B - arrays
    | type ID LBRACKET NUM RBRACKET SEMICOLON //declaração
    {
        char size_str[20];
        sprintf(size_str, "%d", $4);
        gen_code("ARR_DECL", $1, size_str, $2);
    }
    | type ID LBRACKET NUM RBRACKET ASSIGN LBRACE  //declaração com inicialização
    {
        char size_str[20];
        sprintf(size_str,"%d",$4);
        gen_code("ARR_DECL", $1, size_str, $2);
        gen_code("ARR_INIT", $2, "", "");
        strcpy(current_array, $2);
    }
    init_arr RBRACE SEMICOLON
    ;
// conceito B - arrays
init_arr:
    init_arr COMMA expr
    {
        gen_code("add_elem",$3,current_array,"");
    }
    | expr
    {
        gen_code("add_elem",$1,current_array,"");
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
    | ID ASSIGN LBRACE  //conceito B - arrays
    {
        gen_code("ARR_INIT", $1, "", "");
        strcpy(current_array, $1);
    }
    init_arr RBRACE SEMICOLON
    ;
// Estrutura de decisão 
if_stmt:
// se - conceito C
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
    | 
    ;

%%

int main() {
    printf("=== COMPILADOR CIMPLES ===\n");
    return yyparse();
}