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
#define MAX_LABEL 1000
#define MAX_LABEL_LEN 1000
#define PRINT_FROM_YACC (printf("[*] FROM YACC\n"))
typedef short bool;
typedef enum {undefined, integer, float_} declare_type; // ex. declare ... as [declare_type]
typedef enum { plus, minus, mult, div_ } operator_kind;
typedef enum {id_expr, flt_literal_expr, int_literal_expr, temp_expr} expr_kind;
typedef enum { neq, gt, lt, geq, leq, eq} comp_kind; // compare operation
typedef enum { and_, or_, not_ } logical_expr_kind;

typedef struct ExpressionRecord_ {
    expr_kind kind;
    union{
        char *name; // `id_expr` or `temp_expr`
        int ival; // `flt_literal_expr`
        double dval; // `int_literal_expr`
    };
} ExpressionRecord;
typedef struct Var_{
    char *name;
    int array_size; 
    bool isarray;
    declare_type decltype;
} Var;
typedef struct LogicalExpressionRecord_{
    Var *tmpVar; // Saving temporary variable name
}LogicalExpressionRecord;

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

typedef struct LabelTable_{
    char labelName[MAX_LABEL][MAX_LABEL_LEN];
    int size;
} LabelTable;

typedef struct ForHeadBuffer_{
    char *loopVarName; // A variable name
    char loopEndName[MAX_LITERAL_LEN]; // A variable or a literal value
    char *condition_success_label; // points to a record in the label table
    char *condition_fail_label; // points to a record in the label table
    bool isTo; // true: to, false: downto
} ForHeadBuffer;

#define STACK_SIZE 1000
typedef struct LabelStack_{
    int top;
    char *labelName[STACK_SIZE]; // point to LabelTable's record
} LabelStack;

typedef struct ForHeadStack_{
    int top;
    ForHeadBuffer buffer_list[STACK_SIZE];
} ForHeadStack;



extern SymbolTable symbol_table; // For variables
extern SymbolTable tmpSymbol_table; // For temporary variables
extern LabelTable labelTable; // For recording the label counter
extern LabelStack ifTailLabelStack, outOfIfLabelStack;
extern ForHeadStack forHeadStack;


void init_for_head_stack();
void init_tail_label_stack();
void init_label_table(LabelTable *lt);
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
void print_halt(char *program_name);
char *op2string(operator_kind op_kind);
void generate_arithmetic(declare_type type, char *op, char *src1, char *src2, char *target);
void generate_conversion(char *convert_command, char *src, char *target);
void generate_load_word(char *src, char *offset, char *target); // array indexing
void generate_assignment(declare_type type, char *src, char *target, char *offset);
void generate_label();
void generate_for_tail();
void generate_for_start_condition(char *loopVarName, char *loopEndName, char *jumpLabel, bool isTo);
void generate_cmp(declare_type type, char *src1, char *src2, char *target, comp_kind cmp);
void generate_and_or_not(char *src1, char *src2, char *target, logical_expr_kind logic);
void generate_if_header(char *src);
void generate_else_start();
void generate_if_tail();
void generate_if_context_end();
void insert_label();
char *get_current_label();
// [*] Detect whether one of expressions is not literal value
bool has_var(ExpressionRecord expr1, ExpressionRecord expr2);
bool has_double(ExpressionRecord expr1, declare_type *ltype, ExpressionRecord expr2, declare_type *rtype);
ExpressionRecord expression_action(ExpressionRecord $1, ExpressionRecord $3, operator_kind op);
Var *convert_and_create_tmp_var(declare_type src_type, char *src, declare_type target_type);
char *expressionRecordToString(ExpressionRecord expr);
bool isInt(ExpressionRecord expr);
declare_type getExpressionType(ExpressionRecord expr);
// get the top variable in the tmpSymbol_table
Var* get_tmp_top_var();
// 
void push_in_for_head_stack(char *loopVarName, char *loopEndName, 
            char *condition_success_label, char *condition_fail_label, bool isTo);
#endif
