.PHONY: all clean
all: y.tab.c y.tab.h lex.yy.c
	gcc -Wall -o parser y.tab.c lex.yy.c -ly -ll

y.tab.%: parser.y
	yacc -vd parser.y

lex.yy.c: scanner.l
	lex scanner.l

clean:
	rm y.tab.c y.tab.h lex.yy.c parser
