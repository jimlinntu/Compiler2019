%{

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "y.tab.h" 
#define MAX_VAR 1000
#define MAX_TMP_VAR_LEN 1000
#define PRINT_FROM_YACC (printf("[*] FROM YACC\n"))
typedef short bool;
typedef enum {undefined, integer, float_} declare_type; // ex. declare ... as [declare_type]
typedef enum { plus, minus, mult, div_ } operator_kind;
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

SymbolTable symbol_table; // For variables
SymbolTable tmpSymbol_table; // For temporary variables


void init_symbol_table(SymbolTable *table){
    table->var_list = (Var *)malloc(sizeof(Var) * MAX_VAR);
    assert(table->var_list != NULL);
    table->capacity = MAX_VAR;
    table->size = 0;
}
void destroy_symbol_table(SymbolTable *table){
    for(int i = 0; i < table->size; i++){
        free(table->var_list[i].name);
    }
    free(table->var_list);
}
bool symbol_lookup(Var *var, SymbolTable *table){
    // [*] Search whether there is a variable name conflict
    for(int i = 0; i < table->size; i++){
        if(strcmp(var->name, table->var_list[i].name) == 0){
            yyerror("Variable name already exists");
            return 0;
        }
    }
    // [*] Add new variable record into symbol table
    if(table->capacity > table->size){
        table->var_list[table->size] = *var; // shallow copy(the `name` pointer will also be copied)
        table->size++;
        return 1;
    }else{
        yyerror("TODO: Add dynamic allocate memory method");
        return 0;
    }
}
declare_type search_symbol_table(char *name, SymbolTable *table){
    for(int i = 0; i < table->size; i++){
        if(strcmp(name, table->var_list[i].name) == 0) return table->var_list[i].decltype;
    }
    return undefined;
}
bool insert_tmp_symbol(declare_type type){
    int size = tmpSymbol_table.size;
    Var tmp_var = {.name=(char *)malloc(sizeof(char) * MAX_TMP_VAR_LEN), .array_size=1, .isarray=0, .decltype=type};
    assert(tmp_var.name != NULL);
    snprintf(tmp_var.name, MAX_TMP_VAR_LEN, "T&%d", size+1); // ex. T&1, T&2 ...
    int ret = symbol_lookup(&tmp_var, &tmpSymbol_table);
    assert(ret == 1);
    return 1;
}
void print_declaration();
// [*] Flush variable buffer
void flush_var_buf(declare_type type){
    // [*] Put these variables into symbol table
    for(int i = 0; i < var_buf.size; i++){
        // [*] Assign correct type of variable
        var_buf.var_list[i].decltype = type;
        assert(type != undefined);
        bool ret = symbol_lookup(&var_buf.var_list[i], &symbol_table);
        // Fail
        if(ret == 0){
            free(var_buf.var_list[i].name);
        }
    }
    print_declaration();
    var_buf.size = 0;
}
void print_type(declare_type type){
    static char type2string[10][100] = { "undefined", "Integer", "Float"};
    printf("%s", type2string[type]);
}
void print_declaration(){
    Var *var;
    for(int i = 0; i < var_buf.size; i++){
        var = &var_buf.var_list[i];
        printf("\tDeclare ");
        printf("%s, ", var->name);
        print_type(var->decltype);
        if(var->isarray) printf("_array, %d", var->array_size);
        printf("\n");
    }
}
char *op2string(operator_kind op_kind){
    static char op2string_array[10][100] = {"ADD", "SUB", "MUL", "DIV"};
    return op2string_array[op_kind];
}

void generate_arithmetic(declare_type type, char *op, char *src1, char *src2, char *target){
    printf("\t");
    if(type == integer) printf("I_");
    else if(type == float_) printf("F_");
    else assert(0);
    // print operator
    printf("%s ", op);
    // print operands
    if(strcmp(op, "UMINUS") != 0){
        printf("%s, %s, %s\n", src1, src2, target);
    }else{
        assert(src2 == NULL); // Unused operand
        printf("%s, %s\n", src1, target);
    }
}
// TODO: 
void generate_conversion(char *convert_command, char *src, char *target){

}
// [*] Detect whether one of expressions is not literal value
bool has_var(ExpressionRecord expr1, ExpressionRecord expr2){
    return (expr1.kind == id_expr) || (expr1.kind == temp_expr) 
        || (expr2.kind == id_expr) || (expr2.kind == temp_expr);
}
bool has_double(ExpressionRecord expr1, ExpressionRecord expr2){
    declare_type ltype, rtype;
    if(expr1.kind == id_expr){
        ltype = search_symbol_table(expr1.name, &symbol_table);
    }else if(expr1.kind == temp_expr){
        ltype = search_symbol_table(expr1.name, &tmpSymbol_table);
    }else assert(0);
    
    if(expr2.kind == id_expr){
        rtype = search_symbol_table(expr2.name, &symbol_table);
    }else if(expr2.kind == temp_expr){
        rtype = search_symbol_table(expr2.name, &tmpSymbol_table);
    }else assert(0);
    return (ltype == float_) || (rtype == float_);
}

// [*] To avoid duplication of expression [+|-|*|/] expression
ExpressionRecord expression_action(ExpressionRecord $1, ExpressionRecord $3, operator_kind op){
    bool ret = has_var($1, $3); // check whether there are variables. If not, then we will compute literal value
    ExpressionRecord $$;
    // [*] if there is variable
    if(ret){
        ret = has_double($1, $3);
        // if one of expressions has double type, then we will assign
        declare_type return_type = (ret)? (float_):(integer); 
        bool ret = insert_tmp_symbol(return_type); // create float temporary variable
        assert(ret == 1);
        // Assign lhs expression to temporary variable
        $$.kind = temp_expr;
        $$.name = tmpSymbol_table.var_list[tmpSymbol_table.size-1].name;
        // TODO: type conversion instruction
        // Generate instruction
        //generate_arithmetic(return_type, op2string($2), $1.name, $3.name, $$.name);
        generate_arithmetic(return_type, op2string(op), $1.name, $3.name, $$.name);
    }
    // [*] if there is no variables
    else{
        bool has_double_ = ($1.kind == flt_literal_expr) || ($3.kind == flt_literal_expr);

        if(has_double_){
            $$.kind = flt_literal_expr;
            $$.dval = 0.;
        }else{
            $$.kind = int_literal_expr;
            $$.ival = 0;
        }

        if($1.kind == flt_literal_expr){
            $$.dval = $1.dval;
        }else{
            if(has_double_){
                $$.dval = $1.ival; // use dval field
            }else{
                $$.ival = $1.ival; // use ival field
            }
        }
        
        if($3.kind == flt_literal_expr){
            if(op == plus) $$.dval += $3.dval;
            else if(op == minus) $$.dval -= $3.dval;
            else if(op == mult) $$.dval *= $3.dval;
            else if(op == div_) $$.dval /= $3.dval;
            else assert(0);
        }else{
            if(has_double_){
                if(op == plus) $$.dval += $3.ival;
                else if(op == minus) $$.dval -= $3.ival;
                else if(op == mult) $$.dval *= $3.ival;
                else if(op == div_) $$.dval /= $3.ival;
                else assert(0);
            }else{
                if(op == plus) $$.ival += $3.ival;
                else if(op == minus) $$.ival -= $3.ival;
                else if(op == mult) $$.ival *= $3.ival;
                else if(op == div_) $$.ival /= $3.ival;
                else assert(0);
            }
        }
    }
    return $$;
}
%}
/* https://stackoverflow.com/questions/1430390/include-struct-in-the-union-def-with-bison-yacc */
/* This part will be put into `y.tab.h` */
%code requires{
    #define MAX_VAR_LEN 1000
    typedef enum {id_expr, flt_literal_expr, int_literal_expr, temp_expr} expr_kind;
    typedef struct ExpressionRecord_ {
        expr_kind kind;
        union{
            char *name;
            int ival;
            int dval;
        };
    } ExpressionRecord;
}
%union {
    int ival; // [*] Integer value
    double dval; // [*] double value
    int type;  // [*] declare_type
    char *name; 
    ExpressionRecord record;
    int op; // [*] operator_kind
}

%token PROGRAM FAIL BEGIN_ END READ WRITE ID INTLITERAL FLTLITERAL EXPFLTLITERAL STRLITERAL LPAREN RPAREN LSQPAREN RSQPAREN SEMICOL COMMA ASSIGNOP PLUSOP MINUSOP MULTOP DIVOP NEQ GT LT GEQ LEQ EQ IF THEN ELSE ENDIF FOR TO ENDFOR WHILE ENDWHILE DECLARE AS INTEGER REAL FLOATTOK SCANEOF IGNORE NEWLINE


%left PLUSOP MINUSOP
%left MULTOP DIVOP
%nonassoc UMINUS
/* Note: Bison accept terminal and nontermial as well*/
%type <name> ID
%type <ival> INTLITERAL
%type <dval> FLTLITERAL
%type <type> Type
%type <record> Number Expression

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
Stmt: DeclareStmt | ExpressionStmt;

DeclareStmt: DECLARE Variable_list AS Type{
    // Flush Variable_list into symbol table and print
    flush_var_buf($4);
};

 /* ID = expression */
ExpressionStmt: ID ASSIGNOP Expression {
                
              }
              | Expression /* Do nothing*/{
                    printf("Expression: \n");
                    printf("kind = %d\n", $1.kind);
                }
              ;

Expression: Expression PLUSOP Expression {
            $$ = expression_action($1, $3, plus);
          }
          | MINUSOP Expression %prec UMINUS {
                if($2.kind == flt_literal_expr){
                    $$.kind = $2.kind;
                    $$.dval = (-$2.dval);
                }else if($2.kind == int_literal_expr){
                    $$.kind = $2.kind;
                    $$.ival = (-$2.ival);
                }else{
                    declare_type type;
                    if($2.kind == id_expr){
                        type = search_symbol_table($2.name, &symbol_table);
                    }else if($2.kind == temp_expr){
                        type = search_symbol_table($2.name, &tmpSymbol_table);
                    }else assert(0);
                    // Create temporary variable and assign it to $$
                    int ret = insert_tmp_symbol(type);
                    assert(ret == 1);
                    int top = tmpSymbol_table.size-1;
                    $$.kind = temp_expr;
                    $$.name = tmpSymbol_table.var_list[top].name; // assign pointer
                    generate_arithmetic(type, "UMINUS", $2.name, NULL, $$.name);
                }
            }
          | LPAREN Expression RPAREN {
                $$ = $2;
            }
          | Number {
                $$ = $1;
            }
          | ID {
                $$.kind = id_expr;
                $$.name = $1; // Note: assign heap memory pointer, TODO: remember to free memory on upper layer
                // TODO: check if ID exists
                declare_type type = search_symbol_table($1, &symbol_table);
                if(type == undefined) yyerror("This variable does not exist\n");
            }
            /* TODO: Support array indexing ex. LLL[I] */
          ;
Number: INTLITERAL {
        $$.kind = int_literal_expr;
        $$.ival = $1;
      }
      | FLTLITERAL {
        $$.kind = flt_literal_expr;
        $$.dval = $1;
      }
      ;

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
int yyerror(char *s){
    fprintf(stderr, "%s\n", s);
}

int main(){
    init_symbol_table(&symbol_table);
    init_symbol_table(&tmpSymbol_table);
    yyparse();
    destroy_symbol_table(&symbol_table);
    destroy_symbol_table(&tmpSymbol_table);
}
