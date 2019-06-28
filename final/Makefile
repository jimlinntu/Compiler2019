.PHONY: all clean run
testls := $(shell ls .)
testcases := $(shell find "$$(pwd)/testcases/" -regextype sed -regex ".*\.in")
parser_name := ./micro-ex-compiler
all: y.tab.c y.tab.h lex.yy.c
	gcc -Wall -o $(parser_name) y.tab.c lex.yy.c util.c -ly -ll

y.tab.%: parser.y
	yacc -vd parser.y

lex.yy.c: scanner.l
	lex scanner.l

clean:
	rm y.tab.c y.tab.h lex.yy.c $(parser_name)

run:
	# Loop over each testcases
	@for file in $(testcases); do \
		$(parser_name) $$file $${file%.*}.out; \
	done
