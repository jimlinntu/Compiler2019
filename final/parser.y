%{

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "y.tab.h" 
%}
/* https://stackoverflow.com/questions/1430390/include-struct-in-the-union-def-with-bison-yacc */
/* This part will be put into `y.tab.h` */
%code requires{
    #include "util.h"
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
Start: Program_head BEGIN_ Stmt_list End
     | Program_head BEGIN_ End /* [*] Deal with no statments situation*/
     ;
End: END {
    print_tmp_declaration();
}
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
    // Flush Variable_list into symbol table and print declarations
    flush_var_buf($4);
};

 /* ID = expression */
ExpressionStmt: ID ASSIGNOP Expression {
                
              }
              | Expression /* Do nothing*/{
                    /*
                    printf("Expression: \n");
                    printf("kind = %d\n", $1.kind);
                    if($1.kind == int_literal_expr){
                        printf("Literal value: %d\n", $1.ival);
                    }else if($1.kind == flt_literal_expr){
                        printf("Literal value: %f\n", $1.dval);
                    }
                    */
                }
              ;

Expression: Expression PLUSOP Expression {
            $$ = expression_action($1, $3, plus);
          }
          | Expression MINUSOP Expression {
            $$ = expression_action($1, $3, minus);
          }
          | Expression MULTOP Expression {
            $$ = expression_action($1, $3, mult);
          }
          | Expression DIVOP Expression {
            $$ = expression_action($1, $3, div_);
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
                declare_type type = search_symbol_table($1, &symbol_table);
                if(type == undefined) yyerror("This variable does not exist\n");
            }
            /* TODO: Support array indexing ex. LLL[I], LLL[I*j+5] */
          | ID LSQPAREN Expression RSQPAREN {
                Var *var = get_symbol_table_record($1, &symbol_table);
                if(var->isarray == 0){
                    yyerror("This variable cannot be indexed\n");
                }
                declare_type type = search_symbol_table($1, &symbol_table);
                // Generate temporary variable
                insert_tmp_symbol(type);
                int top = tmpSymbol_table.size-1;
                // array indexing
                if($3.kind == id_expr || $3.kind == temp_expr){
                    generate_load_word($1, $3.name, tmpSymbol_table.var_list[top].name);
                }else if($3.kind == int_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $3.ival);
                    generate_load_word($1, literalstr, tmpSymbol_table.var_list[top].name);
                }else if($3.kind == flt_literal_expr){
                    yyerror("Array indexing with double value is not supported\n");
                }else assert(0);
            }
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
