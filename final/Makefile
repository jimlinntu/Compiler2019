.PHONY: all clean
all: y.tab.c y.tab.h lex.yy.c
	gcc -Wall -o micro-ex-compiler y.tab.c lex.yy.c util.c -ly -ll

y.tab.%: parser.y
	yacc -vd parser.y

lex.yy.c: scanner.l
	lex scanner.l

clean:
	rm y.tab.c y.tab.h lex.yy.c parser
