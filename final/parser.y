%{

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include "y.tab.h" 
int lineno=1;
char *program_name;
%}
/* https://stackoverflow.com/questions/1430390/include-struct-in-the-union-def-with-bison-yacc */
/* This part will be put into `y.tab.h` */
%code requires{
    #include "util.h"
}
%union {
    int ival; // [*] Integer value
    double dval; // [*] double value
    declare_type type;  // [*] declare_type
    char *name; 
    ExpressionRecord record;
    operator_kind op; // [*] operator_kind
    comp_kind comp; // [*] comparison operation kind
    logical_expr_kind logic;
    LogicalExpressionRecord logical_record;
    bool isTo; // [*] FOR_DIR
}


%token PROGRAM FAIL BEGIN_ END READ WRITE ID INTLITERAL FLTLITERAL EXPFLTLITERAL STRLITERAL LPAREN RPAREN LSQPAREN RSQPAREN SEMICOL COMMA ASSIGNOP PLUSOP MINUSOP MULTOP DIVOP NEQ GT LT GEQ LEQ EQ AND OR NOT IF THEN ELSE ENDIF FOR TO DOWNTO ENDFOR WHILE ENDWHILE DECLARE AS INTEGER REAL FLOATTOK SCANEOF IGNORE NEWLINE


%left PLUSOP MINUSOP
%left MULTOP DIVOP
%nonassoc UMINUS
/* Note: Bison accept terminal and nontermial as well*/
%type <name> ID
%type <ival> INTLITERAL
%type <dval> FLTLITERAL
%type <type> Type
%type <record> Number Expression

%type <comp> Comp

%type <logical_record> LogicalExpression LogicalExpressionGroup AndLogicalExpression SingletonLogicalExpression
%type <isTo> FOR_DIR


%%
Start: Program_head BEGIN_ Stmt_list End
     | Program_head BEGIN_ End /* [*] Deal with no statments situation*/
     ;
End: END {
    // Print halt
    print_halt(program_name);
    free(program_name); // free memory
    // Print temporary variables declarations
    print_tmp_declaration();
}
Program_head: PROGRAM ID{
    printf("\t\tSTART %s\n", $2);
    program_name = $2; // save it for the usage of halting
};

Stmt_list: Stmt 
         | Stmt_list Stmt 
         ;

 
 /* Statement -> Declare | Expression | For loop | If | Function */
Stmt: DeclareStmt SEMICOL| ExpressionStmt SEMICOL| ForStmt SEMICOL_OR_NONE | IfStmt SEMICOL_OR_NONE;

 /* A -> ; | lambda */
SEMICOL_OR_NONE: SEMICOL | /*lambda*/;

DeclareStmt: DECLARE Variable_list AS Type{
    // Flush Variable_list into symbol table and print declarations
    flush_var_buf($4);
};
 
ExpressionStmt: ID ASSIGNOP Expression /* ID = expression */ {
                Var *var = get_symbol_table_record($1, &symbol_table);
                if(var == NULL){
                    yyerror("This variable does not exist");
                    return;
                }
                // Get the type of that ID
                declare_type type = var->decltype, to_assign_type;
                Var *tmpVar = NULL; // for type conversion
                // Convert an integer value into a string if needed
                // Type conversion if needed
                if($3.kind == id_expr || $3.kind == temp_expr){
                    if($3.kind == id_expr) to_assign_type = search_symbol_table($3.name, &symbol_table);
                    else if($3.kind == temp_expr) to_assign_type = search_symbol_table($3.name, &tmpSymbol_table);
                    
                    // if the types between $1 and $3 mismatch, convert $3 into the type of $1
                    if(type != to_assign_type) tmpVar = convert_and_create_tmp_var(to_assign_type, $3.name, type);
                    // if a type mismatch exists
                    if(tmpVar == NULL) generate_assignment(type, $3.name, $1, NULL);
                    else generate_assignment(type, tmpVar->name, $1, NULL);

                }else if($3.kind == flt_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    // Implicit type conversion
                    if(type == integer) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", (int)$3.dval);
                    else if(type == float_) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%f", $3.dval);
                    // Generate the instruction
                    generate_assignment(type, literalstr, $1, NULL);
                }else if($3.kind == int_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    // Implicit type conversion
                    if(type == integer) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $3.ival);
                    else if(type == float_) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%f", (double)$3.ival);
                    // Generate the instruction
                    generate_assignment(type, literalstr, $1, NULL);
                }else assert(0);

                // Free ID's memory
                free($1);
              }
              | ID LSQPAREN Expression RSQPAREN ASSIGNOP Expression /* ID[10] = expression */ {
                // Check the $3 type is correct
                declare_type type, array_type;
                if($3.kind == id_expr) type = search_symbol_table($3.name, &symbol_table);
                else if($3.kind == temp_expr) type = search_symbol_table($3.name, &tmpSymbol_table);
                else if($3.kind == int_literal_expr) type = integer;
                else if($3.kind == flt_literal_expr) type = float_;
                else assert(0);
                if(type != integer){
                    yyerror("The expression in the square parentheses should be integer type");
                    return;
                }

                // Get array type
                Var *var = get_symbol_table_record($1, &symbol_table);
                if(var == NULL){
                    yyerror("This array does not exist.");
                    return;
                }else if(var->isarray == 0){
                    yyerror("This variable is not an array type");
                    return;
                }else array_type = var->decltype; // Get the array type
                
                
                // Set a temporary register(`T&?`) that saves `$ID + $3` address
                bool ret = insert_tmp_symbol(integer); // create a new temporary register
                assert(ret == 1);
                int top = tmpSymbol_table.size-1;

                if($3.kind == id_expr || $3.kind == temp_expr){
                    // T&? = ID's address + $3 value
                    generate_arithmetic(integer, op2string(plus), $1, $3.name, tmpSymbol_table.var_list[top].name);
                }else if($3.kind == int_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $3.ival);
                    // T&? = ID's address + $3's literal value
                    generate_arithmetic(integer, op2string(plus), $1, literalstr, tmpSymbol_table.var_list[top].name);
                }
                else assert(0);
                // Store $6 into it
                declare_type to_assign_type;
                Var *tmpVar = NULL;
                
                if($6.kind == id_expr){
                    // Search symbol table
                    to_assign_type = search_symbol_table($6.name, &symbol_table);
                    // if two types do not match(), we will transform rhs into lhs type(with a new register)
                    if(array_type != to_assign_type){
                        tmpVar = convert_and_create_tmp_var(to_assign_type, $6.name, array_type);
                    }
                    // Generate the instruction: if tmpVar is not NULL(means there is a type mismatch)
                    if(tmpVar == NULL) generate_assignment(array_type, $6.name, tmpSymbol_table.var_list[top].name, "0");
                    else generate_assignment(array_type, tmpVar->name, tmpSymbol_table.var_list[top].name, "0");
                }else if($6.kind == temp_expr){
                    // Search temporary table
                    to_assign_type = search_symbol_table($6.name, &tmpSymbol_table);
                    if(array_type != to_assign_type){
                        tmpVar = convert_and_create_tmp_var(to_assign_type, $6.name, array_type);
                    }
                    // Generate the instruction: if tmpVar is not NULL(means there is a type mismatch)
                    if(tmpVar == NULL) generate_assignment(array_type, $6.name, tmpSymbol_table.var_list[top].name, "0");
                    else generate_assignment(array_type, tmpVar->name, tmpSymbol_table.var_list[top].name, "0");
                }else if($6.kind == int_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    // if array_type is integer 
                    if(array_type == integer) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $6.ival);
                    else if(array_type == float_) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%f", (double)$6.ival);
                    else assert(0);
                    // Generate the instruction
                    generate_assignment(array_type, literalstr, tmpSymbol_table.var_list[top].name, "0");
                }else if($6.kind == flt_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    if(array_type == integer) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", (int)$6.dval);
                    else if(array_type == float_) snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%f", $6.dval);
                    else assert(0);
                    // Generate the instruction
                    generate_assignment(array_type, literalstr, tmpSymbol_table.var_list[top].name, "0");
                }else assert(0);

                // Free $1 memory
                free($1);
              }
              | Expression {
                }
              ;

ForStmt: ForHeader Stmt_list ENDFOR{
            // [*] INC I or DEC I
            // [*] I_CMP I,100
            // [*] JL lb&1 or JG lb&1
            // [*] lb&2:
            generate_for_tail(); 
       };

 /*Ex. For( I := 1 TO 100 ) */
ForHeader: FOR LPAREN ID ASSIGNOP Expression FOR_DIR Expression RPAREN{
            Var *var = get_symbol_table_record($3, &symbol_table);
            if(var == NULL){ yyerror("This variable does not exist"); return;}
            // Check whether the loop variable is integer type
            if(var->decltype != integer){ yyerror("The loop variable should be integer type"); return;}
            // Check two Expressions are integer type
            if(isInt($5) != 1){ yyerror("The value assigned to the loop variable should be integer type"); return;}
            if(isInt($7) != 1){ yyerror("The loop end variable should be integer type"); return;}
            // [*] I_STORE 1, I
            generate_assignment(integer, expressionRecordToString($5), $3, NULL);
            // [*] Create success label and fail label
            insert_label();
            char *condition_success_label = get_current_label(); // when the loop condition meets
            insert_label();
            char *condition_fail_label = get_current_label(); // when the loop condition fails
            // Put things into the for head buffer
            char *loopEndName = expressionRecordToString($7);
            push_in_for_head_stack(var->name, loopEndName, 
                        condition_success_label, condition_fail_label, $6);
            // [*] Check whether the condition fails
            // I_CMP I, 100
            // JGE lb&2 or JLE lb&2
            generate_for_start_condition(var->name, 
                loopEndName, condition_fail_label, $6);
            
            // lb&1: 
            generate_label(condition_success_label);
            // Free ID
            free($3);
         };

FOR_DIR: TO{
            $$ = 1; //true
       }
       | DOWNTO{
            $$ = 0; //false
        };

IfStmt: IfHeader THEN Stmt_list{
        // Jump to the out-of-if context
        generate_if_context_end();
      } IfTail{
        // lb&2
        generate_if_tail();
      };



 /* If(A >= 100000) */
IfHeader: IF LPAREN LogicalExpression RPAREN{
            // I_CMP $3 0 (evaulate whether this is true)
            // JNE lb&1 (if not equal, jump)
            generate_if_header($3.tmpVar->name);
        };

 /* Note: you should be careful when the nested if structure occurs */
IfTail: DummyElse Stmt_list ENDIF
      | ENDIF{
        // lb&1: 
        generate_else_start();
      };

DummyElse: ELSE{
        // lb&1: 
        generate_else_start();
    };

Comp: NEQ { $$ = neq; }
    | GT { $$ = gt; }
    | LT { $$ = lt; }
    | GEQ { $$ = geq; }
    | LEQ { $$ = leq; }
    | EQ { $$ = eq; };

  /* Left associativity(left recursive fashion) */
  /* Ex. (A >= 80) || !(B >= 10 || C < 0.1)*/
  /* Ex. (A >= 80) || (B >= 10 || C < 0.1)*/
LogicalExpression: LogicalExpression OR AndLogicalExpression{
                    // always be integer
                    insert_tmp_symbol(integer);
                    Var *tmpVar = get_tmp_top_var();
                    // generate "and" "or"  instruction
                    generate_and_or_not($1.tmpVar->name, $3.tmpVar->name, tmpVar->name, or_);
                    // Pass the variable
                    $$.tmpVar = tmpVar;
                 }
                 | AndLogicalExpression{
                    $$.tmpVar = $1.tmpVar;
                 };
  /* && should have higher precedence than ||  */
AndLogicalExpression: AndLogicalExpression AND LogicalExpressionGroup{
                        // always be integer
                        insert_tmp_symbol(integer);
                        Var *tmpVar = get_tmp_top_var();
                        // generate "and" "or"  instruction
                        generate_and_or_not($1.tmpVar->name, $3.tmpVar->name, tmpVar->name, and_);
                        // Pass the variable
                        $$.tmpVar = tmpVar;
                    }
                    | LogicalExpressionGroup{
                        $$.tmpVar = $1.tmpVar;
                    }
                    ;
  /* (B >= 10 || C < 0.1) */
  /* LEG can be decomposed into ( LE ) or ! ( LE ) (recursive fashion)*/
 /* LEG can also downgrade to a singleton logical expression */
LogicalExpressionGroup: LPAREN LogicalExpression RPAREN{
                            $$.tmpVar = $2.tmpVar;
                      }
                      | NOT LPAREN LogicalExpression RPAREN{
                            insert_tmp_symbol(integer);
                            Var *tmpVar = get_tmp_top_var();
                            // NOT i1, t
                            generate_and_or_not($3.tmpVar->name, NULL, tmpVar->name, not_);
                            $$.tmpVar = tmpVar;
                      }
                      | SingletonLogicalExpression{
                        $$.tmpVar = $1.tmpVar;
                      };
                       
 /* Support the parenthesis pair */
 /* Ex. A >= 1000, B <= 100,  (A >= 1000), ((A >= 1000)) */
SingletonLogicalExpression: Expression Comp Expression{
                                // I_CMP_GE A, 1000, t ( <----- integer type  )
                                declare_type lhs_type = getExpressionType($1);
                                declare_type rhs_type = getExpressionType($3);
                                if(lhs_type != rhs_type){ 
                                    yyerror("LHS and RHS in a comparison should be the same type");
                                    return;
                                }
                                // insert a temporary variable
                                // `t` will always be integer type
                                insert_tmp_symbol(integer); 

                                Var *tmpVar = get_tmp_top_var();
                                // generate the instruction
                                char lhs_str[MAX_LITERAL_LEN], rhs_str[MAX_LITERAL_LEN];
                                strcpy(lhs_str, expressionRecordToString($1));
                                strcpy(rhs_str, expressionRecordToString($3));
                                generate_cmp(rhs_type, lhs_str, rhs_str, tmpVar->name, $2);
                    
                                // Pass the temporary variable
                                $$.tmpVar = tmpVar;
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
                }else if($2.kind == id_expr || $2.kind == temp_expr){
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
                }else assert(0);
            }
          | LPAREN Expression RPAREN {
                $$ = $2;
            }
          | Number {
                $$ = $1;
            }
          | ID {
                Var *var = get_symbol_table_record($1, &symbol_table);
                if(var == NULL){
                    yyerror("This variable does not exist");
                    return;
                }       
                $$.kind = id_expr;
                $$.name = var->name; // Let $$.name points to the symbol table record's name(to avoid memory leakage)
                // Free $1
                free($1);
            }
            /* TODO: Support array indexing ex. LLL[I], LLL[I*j+5] */
          | ID LSQPAREN Expression RSQPAREN {
                Var *var = get_symbol_table_record($1, &symbol_table);
                if(var->isarray == 0){
                    yyerror("This variable cannot be indexed");
                    return;
                }
                declare_type type = search_symbol_table($1, &symbol_table);
                // Generate a temporary variable with `type`
                insert_tmp_symbol(type);
                int top = tmpSymbol_table.size-1;
                // array indexing
                if($3.kind == id_expr || $3.kind == temp_expr){
                    // Generate the loading word instruction
                    generate_load_word($1, $3.name, tmpSymbol_table.var_list[top].name);
                }else if($3.kind == int_literal_expr){
                    char literalstr[MAX_LITERAL_LEN];
                    snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $3.ival);
                    generate_load_word($1, literalstr, tmpSymbol_table.var_list[top].name);
                }else if($3.kind == flt_literal_expr){
                    yyerror("Array indexing with double value is not supported");
                    return;
                }else assert(0);

                // Add $$
                $$.kind = temp_expr;
                $$.name = tmpSymbol_table.var_list[top].name;
                // Free the memory
                free($1);
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
   | ID LSQPAREN Expression RSQPAREN /* ex. LLL[10]*/{
    int top = var_buf.size;
    var_buf.var_list[top].name = $1;
    if($3.kind == int_literal_expr){
        var_buf.var_list[top].array_size = $3.ival;
    }else if($3.kind == flt_literal_expr){
        yyerror("Array should be declared with integer type");
        return;
    }else{
        yyerror("Array should be declared with literal intger value");
        return;
    }
    var_buf.var_list[top].isarray = 1;
    var_buf.var_list[top].decltype = undefined;
    var_buf.size++;
}
   ;

%%
int yyerror(char *s){
    fprintf(stderr, "The error occurs at line %d: %s\n", lineno, s);
}

int main(int argc, char **argv){
    if(argc != 3){
        fprintf(stderr, "Micro/Ex Compiler Usage: ./micro-ex-compiler <input program path> <output path>\n");
        return 1;
    }
    extern FILE *yyin, *yyout;
    
    yyin = fopen(argv[1], "r");
    assert(yyin);
    // stdout redirection
    freopen(argv[2], "w", stdout);
    assert(stdout);
    
    
    init_for_head_stack();
    init_tail_label_stack();
    init_label_table(&labelTable);
    init_symbol_table(&symbol_table);
    init_symbol_table(&tmpSymbol_table);
    yyparse();
    destroy_symbol_table(&symbol_table);
    destroy_symbol_table(&tmpSymbol_table);
    return 0;
}
