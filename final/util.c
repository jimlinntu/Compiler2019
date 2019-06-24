#include "util.h"
VarBuffer var_buf;
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
// Get pointer of a specific var
Var *get_symbol_table_record(char *name, SymbolTable *table){
    for(int i = 0; i < table->size; i++){
        if(strcmp(name, table->var_list[i].name) == 0) return &table->var_list[i];
    }
    return NULL;
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
void print_tmp_declaration(){
    Var *var;
    for(int i = 0; i < tmpSymbol_table.size; i++){
        var = &tmpSymbol_table.var_list[i];
        printf("\tDeclare %s, ", var->name);
        print_type(var->decltype);
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
void generate_conversion(char *convert_command, char *src, char *target){
    printf("\t%s %s, %s\n", convert_command, src, target);
}
void generate_load_word(char *src, char *offset, char *target){
    printf("\tLOAD %s, %s, %s\n", src, offset, target);
}
// [*] Detect whether one of expressions is not literal value
bool has_var(ExpressionRecord expr1, ExpressionRecord expr2){
    return (expr1.kind == id_expr) || (expr1.kind == temp_expr) 
        || (expr2.kind == id_expr) || (expr2.kind == temp_expr);
}

// [*] Check whether these two expressions have at least 1 being `float` type
bool has_double(ExpressionRecord expr1, declare_type *ltype, ExpressionRecord expr2, declare_type *rtype){
    if(expr1.kind == id_expr){
        *ltype = search_symbol_table(expr1.name, &symbol_table);
    }else if(expr1.kind == temp_expr){
        *ltype = search_symbol_table(expr1.name, &tmpSymbol_table);
    }else if(expr1.kind == int_literal_expr){
        *ltype = integer;
    }else if(expr1.kind == flt_literal_expr){
        *ltype = float_;
    }else assert(0);
    
    if(expr2.kind == id_expr){
        *rtype = search_symbol_table(expr2.name, &symbol_table);
    }else if(expr2.kind == temp_expr){
        *rtype = search_symbol_table(expr2.name, &tmpSymbol_table);
    }else if(expr2.kind == int_literal_expr){
        *rtype = integer;
    }else if(expr2.kind == flt_literal_expr){
        *rtype = float_;
    }else assert(0);
    return (*ltype == float_) || (*rtype == float_);
}
// [*] To avoid duplication of expression [+|-|*|/] expression
ExpressionRecord expression_action(ExpressionRecord $1, ExpressionRecord $3, operator_kind op){
    bool ret = has_var($1, $3); // check whether there are variables. If not, then we will compute literal value
    ExpressionRecord $$;
    // [*] if there is variable
    if(ret){
        declare_type ltype, rtype;
        ret = has_double($1, &ltype, $3, &rtype);
        // if one of expressions has double type, then we will assign
        declare_type return_type = (ret)? (float_):(integer); 
        // Type conversion instruction
        if(return_type == float_){
            if(ltype == integer && ($1.kind == id_expr || $1.kind == temp_expr)){
                insert_tmp_symbol(float_); // generate float temporary variable
                generate_conversion("IntToFloat", $1.name, tmpSymbol_table.var_list[tmpSymbol_table.size-1].name);
                // substitute
                $1.kind = temp_expr;
                $1.name = tmpSymbol_table.var_list[tmpSymbol_table.size-1].name;
            }

            if(rtype == integer && ($3.kind == id_expr || $3.kind == temp_expr)){
                insert_tmp_symbol(float_); // generate float temporary variable
                generate_conversion("IntToFloat", $3.name, tmpSymbol_table.var_list[tmpSymbol_table.size-1].name);
                $3.kind = temp_expr;
                $3.name = tmpSymbol_table.var_list[tmpSymbol_table.size-1].name;
            } 
        }
        
        ret = insert_tmp_symbol(return_type); // create float temporary variable
        assert(ret == 1);
        // Assign lhs expression to temporary variable
        $$.kind = temp_expr;
        $$.name = tmpSymbol_table.var_list[tmpSymbol_table.size-1].name;
        // Generate instructions
        if($1.kind == int_literal_expr){
            char literalstr[MAX_LITERAL_LEN];
            snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $1.ival);
            generate_arithmetic(return_type, op2string(op), literalstr, $3.name, $$.name);
        }else if($1.kind == flt_literal_expr){
            char literalstr[MAX_LITERAL_LEN];
            snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%f", $1.dval);
            generate_arithmetic(return_type, op2string(op), literalstr, $3.name, $$.name);
        }else if($3.kind == int_literal_expr){
            char literalstr[MAX_LITERAL_LEN];
            snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%d", $3.ival);
            generate_arithmetic(return_type, op2string(op), $1.name, literalstr, $$.name);
        }else if($3.kind == flt_literal_expr){
            char literalstr[MAX_LITERAL_LEN];
            snprintf(literalstr, sizeof(char) * MAX_LITERAL_LEN, "%f", $3.dval);
            generate_arithmetic(return_type, op2string(op), $1.name, literalstr, $$.name);
        }
        // Both are variables
        else{
            generate_arithmetic(return_type, op2string(op), $1.name, $3.name, $$.name);
        }
    }
    // [*] if there is no variables
    else{
        declare_type ltype, rtype; // left declared type and right declare type
        bool has_double_ = has_double($1, &ltype, $3, &rtype); // check if at least one of literal values is double literal value

        if(has_double_){
            $$.kind = flt_literal_expr;
            $$.dval = 0.0;
        }else{
            // If there is no double expression, we will use the integer literal expression as return kind
            $$.kind = int_literal_expr;
            $$.ival = 0;
        }

        if($1.kind == flt_literal_expr){
            $$.dval = $1.dval;
        }else if($1.kind == int_literal_expr){
            if(has_double_){
                $$.dval = $1.ival; // use dval field
            }else{
                $$.ival = $1.ival; // use ival field
            }
        }else assert(0);
        
        if($3.kind == flt_literal_expr){
            if(op == plus) $$.dval += $3.dval;
            else if(op == minus) $$.dval -= $3.dval;
            else if(op == mult) $$.dval *= $3.dval;
            else if(op == div_){
                assert($3.dval != 0);
                $$.dval /= $3.dval;
            }
            else assert(0);
        }else if($1.kind == int_literal_expr){
            if(has_double_){
                if(op == plus) $$.dval += $3.ival;
                else if(op == minus) $$.dval -= $3.ival;
                else if(op == mult) $$.dval *= $3.ival;
                else if(op == div_){
                    assert($3.ival != 0);
                    $$.dval /= $3.ival;
                }
                else assert(0);
            }else{
                if(op == plus) $$.ival += $3.ival;
                else if(op == minus) $$.ival -= $3.ival;
                else if(op == mult) $$.ival *= $3.ival;
                else if(op == div_){
                    assert($3.ival != 0);
                    $$.ival /= $3.ival;
                }
                else assert(0);
            }
        }else assert(0);
    }
    return $$;
}
