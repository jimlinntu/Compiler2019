%token NAME NUMBER
%%

statement_list:	statement '\n'
	|	statement_list statement '\n'
	;

statement:	NAME '=' expression
	|	expression		{ printf("= %d\n", $1); }
	;

expression: expression '+' mulexp { $$ = $1 + $3; }
    |       expression '-' mulexp { $$ = $1 - $3; }
    |       mulexp { $$ = $1; }
    ;

mulexp:     mulexp '*' primary { $$ = $1 * $3; }
    |       mulexp '/' primary { 
                if($3 == 0) yyerror("divide by zero is not valid");
                else $$ = $1 / $3; 
            }
    |       primary { $$ = $1; }
    ;

primary:    '(' expression ')' { $$ = $2; }
    |       '-' primary { $$ = -$2; }
    |       NUMBER { $$ = $1; }
    ;
%%
