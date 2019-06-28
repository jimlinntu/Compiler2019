# Compiler Final Project
This project code base demonstrates how to build a Micro/Ex compiler.

# Author
b04705003 台大資工四 林子雋(Jim Lin)

# Table of Content
* [Environment](#Environment)
* [Folder Structure](#folder)
* [How to run](#howtorun)
* [What I have learned and experienced during the implementation](#learned)
* [What I have implemented](#implemented)
* [Copyright claim](#copyright)
* [Appendix](#Appendix)

# Environment
* Ubuntu 18.04 Bash
* Yacc(bison (GNU Bison) 3.0.4)
* Lex(flex version 2.5.4)
* GNU Make(GNU Make 4.1)

<a name="folder" />

# Folder Structure
```
.
├── Makefile
├── README.md
├── parser.y ( the yacc file )
├── scanner.l ( the lex file )
├── spec.ppt ( the final project specification )
├── testcases ( *.in is the input program, *.out is the output target language program )
│   ├── assignment.in
│   ├── assignment.out
│   ├── declare.in
│   ├── declare.out
│   ├── expression.in
│   ├── expression.out
│   ├── for.in
│   ├── for.out
│   ├── if-for-nested.in
│   ├── if-for-nested.out
│   ├── if.in
│   ├── if.out
│   ├── nestedfor.in
│   ├── nestedfor.out
│   ├── nestedif.in
│   └── nestedif.out
├── util.c
└── util.h
```

<a name="howtorun" />

# How to run
* Run a program by yourself
```
make
./micro-ex-compiler <input program path> <output path>
make clean
```
* For lazy person, you can run `make run`, then it will generate `testcases/*.out` files for you
```
make
make run
```

<a name="learned" />

# What I have learned and experienced during the implementation
* I learned how to design these semantic records' data structure
* I found that passing these semantic records' turned out to be a complicated work. Sometimes I was a little bit lost in the code I had written.
* I use Git version control to track my progress whenever I completed some features of this compiler.
* It is very hard to maintain a clean code base during writting this compiler. There were just too many parameters or variables to pass to another place to use.
* I thoroughly generated these testcases in order to test all the possible branches in my code. This helped my pick out some bugs.

<a name="implemented" />

# What I have implemented
- [x] Declaration ( track the nonterminal `DeclareStmt` or use `testcases/declare.in` to test)
- [x] Assignment ( track the nonterminal `ExpressionStmt` or use `testcases/assignment.in` to test)
- [x] For loop ( track the nonterminal `ForStmt` or  use `testcases/for.in` )
- [x] For loop condition with complex expressions ( track the nonterminal `ForHeader` or  use `testcases/for.in` )
- [x] Nested for loop support ( track the data structure `extern LabelStack ifTailLabelStack, outOfIfLabelStack;` in `util.h` or use `testcases/nestedfor.in` to test )
- [x] If statement ( track the nonterminal `IfHeader` or use `testcases/if.in` to test )
- [x] If statement with sophisticated logical expressions ( Note that: as C language specification, `&&` would have higher precendence than `||`) ( track the nonterminal `LogicalExpression` or use `testcases/if.in` to test )
- [x] Nested if statement support ( track the data structure `extern ForHeadStack forHeadStack;` in `util.h` or use `testcases/nestedif.in` to test )
- [x] If-for nested statement support ( use `testcases/if-for-nested.in` to test )

<a name="copyright" />

# Copyright claim
These codes are fully implemented by myself.

<a name="Appendix" />

# Appendix
## Target Assembly Language
* Variable Variable declaration instruction
    * Declare A, Integer
    * Declare A, Integer\_array,20
    * Declare B, Float
    * Declare B, Float\_array,20
* Arithmetic instruction
    * I\_SUB i1,i2,t
    * I\_ADD i1,i2,t
    * I\_DIV i1,i2,t
    * I\_MUL i1,i2,t
    * I\_UMINUS i1,t
    * INC I
    * DEC I
* Type conversion instructions
    * IntToFloat i1, t 
    * FloatToInt f1, t
* Load instruction:
    * LOAD src, offset, target ( Load a `target = src[offset]` )
* Assignment
    * I\_Store i1,t
    * I\_Store i1,offset(t) (Store i1 into MEM[t + offset])
    * F\_Store f1,t
    * I\_Store f1,offset(t) (Store f1 into MEM[t + offset])
* Compare instruction
    * I\_CMP i1,i2
    * F\_CMP f1,f2
    * [I|F]\_CMP\_E x1, x2, t (equal to)
    * [I|F]\_CMP\_G x1, x2, t (greater than)
    * [I|F]\_CMP\_GE x1, x2, t (greater equal than)
    * [I|F]\_CMP\_L x1, x2, t (less than)
    * [I|F]\_CMP\_LE x1, x2, t (less equal than)
    * [I|F]\_CMP\_NE x1, x2, t (not equal to)
* Jump instruction
    * J,JE, JG, JGE, JL, JLE, JNE 
* Logical instruction
    * AND b1, b2, t
    * OR b1, b2, t
    * NOT b, t
