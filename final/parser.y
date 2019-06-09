%{

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#define MAX_VAR 1000
#define PRINT_FROM_YACC (printf("[*] FROM YACC\n"))
typedef short bool;
typedef enum {undefined, integer, float_} declare_type; // ex. declare ... as [declare_type]
typedef struct Var_{
    char *name;
    int array_size; 
    bool isarray;
    declare_type decltype;
} Var;

typedef struct VarBuffer_{
    Var var_list[MAX_VAR];
    int size;
} VarBuffer;

VarBuffer var_buf;

typedef struct SymbolTable_{
    Var *var_list;
    int capacity; 
    int size;
} SymbolTable;

SymbolTable symbol_table;

void init_symbol_table(){
    symbol_table.var_list = malloc(sizeof(Var) * MAX_VAR);
    symbol_table.capacity = MAX_VAR;
    symbol_table.size = 0;
}
void destroy_symbol_table(){
    for(int i = 0; i < symbol_table.size; i++){
        free(symbol_table.var_list[i].name);
    }
    free(symbol_table.var_list);
}
bool symbol_lookup(Var *var){
    // [*] Search whether there is a variable name conflict
    for(int i = 0; i < symbol_table.size; i++){
        if(strcmp(var->name, symbol_table.var_list[i].name) == 0){
            yyerror("Variable name already exists");
            return 0;
        }
    }
    // [*] Add new variable record into symbol table
    if(symbol_table.capacity > symbol_table.size){
        symbol_table.var_list[symbol_table.size] = *var; // shallow copy(the `name` pointer will also be copied)
        symbol_table.size++;
        return 1;
    }else{
        yyerror("TODO: Add dynamic allocate memory method");
        return 0;
    }
}
// [*] Flush variable buffer
void flush_var_buf(declare_type type){
    // [*] Put these variables into symbol table
    for(int i = 0; i < var_buf.size; i++){
        // [*] Assign correct type of variable
        var_buf.var_list[i].decltype = type;
        assert(type != undefined);
        bool ret = symbol_lookup(&var_buf.var_list[i]);
        // Fail
        if(ret == 0){
            free(var_buf.var_list[i].name);
        }
    }
    var_buf.size = 0;
}
void print_type(declare_type type){
    static char type2string[10][100] = { "undefined", "Integer", "Float"};
    printf("%s", type2string[type]);
}
void print_declaration(){
    Var *var;
    for(int i = 0; i < symbol_table.size; i++){
        var = &symbol_table.var_list[i];
        printf("Declare ");
        printf("%s, ", var->name);
        print_type(var->decltype);
        if(var->isarray) printf("_array, %d", var->array_size);
        printf("\n");
    }
}
%}
%union {
    int ival; // [*] Integer value
    double dval; // [*] double value
    int type;  // [*] declare_type
    char *name; 
}

%token PROGRAM FAIL BEGIN_ END READ WRITE ID INTLITERAL FLTLITERAL EXPFLTLITERAL STRLITERAL LPAREN RPAREN LSQPAREN RSQPAREN SEMICOL COMMA ASSIGNOP PLUSOP MINUSOP MULTOP DIVOP NEQ GT LT GEQ LEQ EQ IF THEN ELSE ENDIF FOR TO ENDFOR WHILE ENDWHILE DECLARE AS INTEGER REAL FLOATTOK SCANEOF IGNORE NEWLINE

/*Note: Bison accept terminal and nontermial as well*/
%type <name> ID
%type <ival> INTLITERAL
%type <type> Type

%%
Start: Program_head BEGIN_ Stmt_list END {
    // [*] Print declaration statements
    print_declaration();
}
     | Program_head BEGIN_ END /* [*] Deal with no statments situation*/
     ;
Program_head: PROGRAM ID{
    printf("START %s\n", $2);
    free($2);
};

Stmt_list: Stmt SEMICOL
         | Stmt_list Stmt SEMICOL
         ;

 /* TODO: Add more statement type */
Stmt: DeclareStmt;

DeclareStmt: DECLARE Variable_list AS Type{
    // Flush Variable_list into symbol table
    flush_var_buf($4);
};

Type: INTEGER {
       $$ = integer;
    }
    | FLOATTOK{
       $$ = float_;
    };

Variable_list: Var
             | Variable_list COMMA Var
             ;

/* TODO: turn INTLITERAL into expression*/
Var: ID {
    // Put ID's name pointer into variable buffer
    int top = var_buf.size;
    var_buf.var_list[top].name = $1;
    var_buf.var_list[top].array_size = 1;
    var_buf.var_list[top].isarray = 0;
    var_buf.var_list[top].decltype = undefined;
    var_buf.size++;
   }
   | ID LSQPAREN INTLITERAL RSQPAREN /* ex. LLL[10]*/{
    int top = var_buf.size;
    var_buf.var_list[top].name = $1;
    var_buf.var_list[top].array_size = $3;
    var_buf.var_list[top].isarray = 1;
    var_buf.var_list[top].decltype = undefined;
    var_buf.size++;
    }
   ;

%%

int main(){
    init_symbol_table();
    yyparse();
    destroy_symbol_table();
}
