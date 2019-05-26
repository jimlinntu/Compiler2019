%{
#include "y.tab.h"
extern int yylval;
%}

%%
[0-9]+	{ yylval = atoi(yytext); return NUMBER; }
[ \t]	;		/* ignore white space */
\n  { return '\n'; };	/* logical EOF */
<<EOF>> { return 0; };
.	return yytext[0];
%%
