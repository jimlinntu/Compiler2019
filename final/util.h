#ifndef _MYPARSER
#define _MYPARSER

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#define MAX_VAR 1000
#define MAX_VAR_LEN 1000
#define MAX_TMP_VAR_LEN 1000
#define MAX_LITERAL_LEN 1000
#define PRINT_FROM_YACC (printf("[*] FROM YACC\n"))
typedef short bool;
typedef enum {undefined, integer, float_} declare_type; // ex. declare ... as [declare_type]
typedef enum { plus, minus, mult, div_ } operator_kind;

typedef enum {id_expr, flt_literal_expr, int_literal_expr, temp_expr} expr_kind;
typedef struct ExpressionRecord_ {
    expr_kind kind;
    union{
        char *name;
        int ival;
        double dval;
    };
} ExpressionRecord;
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

extern VarBuffer var_buf;

typedef struct SymbolTable_{
    Var *var_list;
    int capacity; 
    int size;
} SymbolTable;

extern SymbolTable symbol_table; // For variables
extern SymbolTable tmpSymbol_table; // For temporary variables


void init_symbol_table(SymbolTable *table);
void destroy_symbol_table(SymbolTable *table);
bool symbol_lookup(Var *var, SymbolTable *table);
Var *get_symbol_table_record(char *name, SymbolTable *table);
declare_type search_symbol_table(char *name, SymbolTable *table);
bool insert_tmp_symbol(declare_type type);
void flush_var_buf(declare_type type);
void print_type(declare_type type);
void print_declaration();
void print_tmp_declaration();
char *op2string(operator_kind op_kind);
void generate_arithmetic(declare_type type, char *op, char *src1, char *src2, char *target);
// TODO: 
void generate_conversion(char *convert_command, char *src, char *target);
void generate_load_word(char *src, char *offset, char *target); // array indexing
// [*] Detect whether one of expressions is not literal value
bool has_var(ExpressionRecord expr1, ExpressionRecord expr2);
bool has_double(ExpressionRecord expr1, declare_type *ltype, ExpressionRecord expr2, declare_type *rtype);
ExpressionRecord expression_action(ExpressionRecord $1, ExpressionRecord $3, operator_kind op);
#endif
