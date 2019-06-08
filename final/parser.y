%{

#define MAX_VAR 1000
typedef struct Var_{
    char *name;
    int size; // variable size
} Var;

// [*] A table save 
Var var_list[MAX_VAR];

%}
%union {
    int ival;
    double dval;

}

%token PROGRAM FAIL BEGIN_ END READ WRITE ID INTLITERAL FLTLITERAL EXPFLTLITERAL STRLITERAL LPAREN RPAREN SEMICOL COMMA ASSIGNOP PLUSOP MINUSOP MULTOP DIVOP NEQ GT LT GEQ LEQ EQ IF THEN ELSE ENDIF FOR TO ENDFOR WHILE ENDWHILE DECLARE AS INTEGER REAL FLOATTOK SCANEOF IGNORE NEWLINE
%%
Start: PROGRAM ID BEGIN_ Stmt_list END;

Stmt_list: Stmt ';'
         | Stmt_list Stmt ';'
         ;

 /* TODO: Add more statement type */
Stmt: DeclareStmt;

DeclareStmt: DECLARE Variable_list AS Type;

Type: INTEGER | FLOATTOK;

Variable_list: Var
             | Variable_list ',' Var
             ;


Var: ID
   | ID '[' INTLITERAL ']'
   ;

%%

