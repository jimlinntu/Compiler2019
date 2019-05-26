.PHONY: all clean

all:
	yacc -d parser.y
	lex scanner.l
	gcc -o parser y.tab.c lex.yy.c -ly -ll
clean:
	rm lex.yy.c parser y.tab.c y.tab.h

