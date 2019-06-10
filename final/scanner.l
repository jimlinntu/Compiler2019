%{
/*
 * 
 * 
 */
#include "y.tab.h"
#include <string.h>
#include <assert.h>
#define LINELEN 1000
/*
typedef enum token_types{
    FAIL, BEGIN_, END, READ, WRITE, ID, INTLITERAL, FLTLITERAL, EXPFLTLITERAL, STRLITERAL, LPAREN, RPAREN, SEMICOL, COMMA, ASSIGNOP, PLUSOP, MINUSOP, MULTOP, DIVOP, NEQ, GT, LT, GEQ, LEQ, EQ, IF, THEN, ELSE, ENDIF, FOR, TO, ENDFOR, WHILE, ENDWHILE, DECLARE, AS, INTEGER, REAL, SCANEOF, IGNORE, NEWLINE
} token;
*/
%}
 /* alphabet aliases .*/
a           [aA]
b           [bB]
c           [cC]
d           [dD]
e           [eE]
f           [fF]
g           [gG]
h           [hH]
i           [iI]
j           [jJ]
k           [kK]
l           [lL]
m           [mM]
n           [nN]
o           [oO]
p           [pP]
q           [qQ]
r           [rR]
s           [sS]
t           [tT]
u           [uU]
v           [vV]
w           [wW]
x           [xX]
y           [yY]
z           [zZ]


IGNORE      [\t\n ]
PROGRAM     {p}{r}{o}{g}{r}{a}{m}
COMMENT     %%.*\n? 
BEGIN       {b}{e}{g}{i}{n}
END         {e}{n}{d}
READ        {r}{e}{a}{d}
WRITE       {w}{r}{i}{t}{e}
ID          [a-zA-Z]([a-zA-Z]|[0-9]|"_")*
INTLIT      (0|([1-9][0-9]*))
 /* FLOAT - Test cases:
    0.0000 ac
    000.0 wa
    .0 ac
    0. ac
    . wa
    0.0 ac
 */
FLOAT       ({INTLIT}\.[0-9]*)|(({INTLIT})?\.[0-9]+) 
EXP         ({FLOAT}{e}([+-]?{INTLIT}))
STR         \"[^"\n]*\"
LPAREN      \(
RPAREN      \)
LSQPAREN    \[
RSQPAREN    \]
SEMICOL     ";"
COMMA       ","
ASSIGNOP    ":="
PLUSOP      "+"
MINUSOP     "-"
MULTOP      "*"
DIVOP       "/"
NEQ         "!="
GT          ">"
LT          "<"
GEQ         ">="
LEQ         "<="
EQ          "=="
IF          {i}{f}
THEN        {t}{h}{e}{n}
ELSE        {e}{l}{s}{e}
ENDIF       {e}{n}{d}{i}{f}
FOR         {f}{o}{r}
TO          {t}{o}
ENDFOR      {e}{n}{d}{f}{o}{r}
WHILE       {w}{h}{i}{l}{e}
ENDWHILE    {e}{n}{d}{w}{h}{i}{l}{e}
DECLARE     {d}{e}{c}{l}{a}{r}{e}
AS          {a}{s}
INTEGER     {i}{n}{t}{e}{g}{e}{r}
REAL        {r}{e}{a}{l}
FLOATTOK    {f}{l}{o}{a}{t}
SCANEOF     {s}{c}{a}{n}{e}{o}{f}

%%
 /* Ignore characters: do not need to return token */
{IGNORE}     {
    if(strcmp(yytext, "\n") == 0){
        //return NEWLINE; 
    }
    //return IGNORE;
}
{PROGRAM} {return PROGRAM;}
{COMMENT}   { 
    //printf("COMMENT\n"); 
} /* Ignore comment*/
 /* Keywords: should be matched with high priority */ 
{BEGIN}     { return BEGIN_;}
{END}       { return END;}
{READ}      { return READ;}
{WRITE}     { return WRITE;}
{LPAREN}    { return LPAREN;}
{RPAREN}    { return RPAREN;}
{LSQPAREN}  { return LSQPAREN;}
{RSQPAREN}  { return RSQPAREN;}
{SEMICOL}   { return SEMICOL;}
{COMMA}     { return COMMA;}
{ASSIGNOP}  { return ASSIGNOP;}
{PLUSOP}    { return PLUSOP;}
{MINUSOP}   { return MINUSOP;}
{MULTOP}    { return MULTOP;}
{DIVOP}     { return DIVOP;}
{NEQ}       { return NEQ;}
{GT}        { return GT;}
{LT}        { return LT;}
{GEQ}       { return GEQ;}
{LEQ}       { return LEQ;}
{EQ}        { return EQ;}
{IF}        { return IF;}
{THEN}      { return THEN;}
{ELSE}      { return ELSE;}
{ENDIF}     { return ENDIF;}
{FOR}       { return FOR;}
{TO}        { return TO;}
{ENDFOR}    { return ENDFOR;}
{WHILE}     { return WHILE;}
{ENDWHILE}  { return ENDWHILE;}
{DECLARE}   { return DECLARE;}
{AS}        { return AS;}
{INTEGER}   { return INTEGER;}
{REAL}      { return REAL;}
{FLOATTOK}  { return FLOATTOK;}

 /* Literal */
{INTLIT}    { 
    yylval.ival = atoi(yytext);
    return INTLITERAL;
}   
{FLOAT}     { 
    yylval.dval = atof(yytext);
    return FLTLITERAL;
}
{EXP}       { return EXPFLTLITERAL;}
{STR}       { return STRLITERAL;}
 /* Variable */
{ID}        { 
    yylval.name = strdup(yytext); // allocate string memory
    return ID; 
}
 /* Scaneof */
<<EOF>>     { return 0;} /*End of input*/
 /* Illegal characters will fall in here */
.           { error("lexcial error\n"); }
%%

