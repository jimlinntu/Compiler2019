.PHONY=clean
hw3: hw3.c
	gcc -o hw3 hw3.c -lfl
hw3.c: hw3.l
	lex -ohw3.c hw3.l
clean:
	rm hw3.c
