%{
/*
 * 
 * 
 */
#include <string.h>
#include <assert.h>
#define LINELEN 1000
typedef enum token_types{
    FAIL, BEGIN_, END, READ, WRITE, ID, INTLITERAL, FLTLITERAL, EXPFLTLITERAL, STRLITERAL, LPAREN, RPAREN, SEMICOL, COMMA, ASSIGNOP, PLUSOP, MINUSOP, MULTOP, DIVOP, NEQ, GT, LT, GEQ, LEQ, EQ, IF, THEN, ELSE, ENDIF, FOR, TO, ENDFOR, WHILE, ENDWHILE, DECLARE, AS, INTEGER, REAL, SCANEOF, IGNORE, NEWLINE
} token;
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
SCANEOF     {s}{c}{a}{n}{e}{o}{f}

%%
 /* Ignore characters */
{IGNORE}     {
    if(strcmp(yytext, "\n") == 0){
        return NEWLINE;
    }
    return IGNORE;
}
{COMMENT}   { return IGNORE;}
 /* Keywords: should be matched with high priority */ 
{BEGIN}     { return BEGIN_;}
{END}       { return END;}
{READ}      { return READ;}
{WRITE}     { return WRITE;}
{LPAREN}    { return LPAREN;}
{RPAREN}    { return RPAREN;}
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

 /* Literal */
{INTLIT}    { return INTLITERAL;}   
{FLOAT}     { return FLTLITERAL;}
{EXP}       { return EXPFLTLITERAL;}
{STR}       { return STRLITERAL;}
 /* Variable */
{ID}        { return ID;}
 /* Scaneof */
<<EOF>>     { return SCANEOF;}
 /* Illegal characters will fall in here */
.           { return FAIL;}
%%

char *RED="\033[0;31m";
char *GREEN="\033[0;32m";
char *NC="\033[0m";
char *token_map[] = { "ERROR", "BEGIN", "END", "READ", "WRITE", "ID", "INTLITERAL", "FLTLITERAL", "EXPFLTLITERAL", "STRLITERAL", "LPAREN", "RPAREN", "SEMICOL", "COMMA", "ASSIGNOP", "PLUSOP", "MINUSOP", "MULTOP", "DIVOP", "NEQ", "GT", "LT", "GEQ", "LEQ", "EQ", "IF", "THEN", "ELSE", "ENDIF", "FOR", "TO", "ENDFOR", "WHILE", "ENDWHILE", "DECLARE", "AS", "INTEGER", "REAL", "SCANEOF", "IGNORE", "NEWLINE"};
int main(){
    int line_count = 0;
    int line_len = 0;
    char line_buffer[LINELEN] = {0};
    token line_token[LINELEN] = {0};
    int is_fail = 0;
    int ret;
    while((ret=yylex()) >= 0){
        // Record token type
        for(int i = line_len; i < line_len + yyleng; i++){
            line_token[i] = ret;
        }
        // Concate line buffer to yytext
        strcat(line_buffer, yytext);
        // Record line length
        line_len += yyleng;
        // Note: EOF pattern will have yyleng == 1 but yytext == null string
        assert(strlen(line_buffer) == line_len || ret == SCANEOF) ;
        // Record current line position
        if(ret != FAIL && ret != IGNORE && ret != NEWLINE && ret != SCANEOF){
            printf("Token number=%d(%s), value is \"%s\"\n", ret, token_map[ret], yytext);
        }
        else if(ret == NEWLINE || ret == SCANEOF){
            line_count += 1;
            if(is_fail){
                printf("[*] Lexcial Errors at line %d:\n", line_count);
                // Note: SCANEOF will not have '\n' character at the end of line_buffer
                if(ret == SCANEOF){
                    printf("%s\n", line_buffer);
                }else printf("%s", line_buffer);
                for(int i = 0; i < line_len; i++){
                    if(line_token[i] != FAIL){
                        if(line_buffer[i] == '\t') fputs("\t", stdout);
                        else fputs(" ", stdout);
                    }else{
                        fputs(GREEN, stdout);
                        fputs("^", stdout); 
                        fputs(NC, stdout);
                    } 
                }
                printf("\n");
            }
            // Reset
            memset(line_buffer, 0, LINELEN);
            memset(line_token, 0, LINELEN);
            line_len = 0;
            is_fail = 0;
            if(ret == SCANEOF){
                printf("Token number=%d(%s), value is \"EOF\"\n", ret, token_map[ret]);
                break;
            }
        }
        else if(ret == FAIL){
            // Lexical Error
            printf("Token number=%sERROR%s, value is \"%s\"\n", RED, NC, yytext);
            is_fail = 1;
        }
    }
    printf("End of the execution\n");
}



