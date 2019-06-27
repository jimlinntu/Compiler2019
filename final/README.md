# Folder Structure
```
.
├── Makefile
├── README.md
├── parser.y
├── scanner.l
├── testcases
│   ├── assignment.in
│   ├── declare.in
│   ├── expression.in
│   ├── for.in
│   ├── if.in
│   ├── nestedfor.in
│   └── nestedif.in
├── util.c
└── util.h
```

# How to run
```
make
./micro-ex-compiler <input program path> <output path>
make clean
```

# What I have learned and experienced during the implementation
* I learned how to design these semantic records' data structure
* I found that passing these semantic records' turned out to be a complicated work. Sometimes I was a little bit lost in the code I written.
* I use Git version control to track my progress whenever I completed some features of this compiler.
* It is very hard to maintain a clean code base during writting this compiler. There were just too many parameters or variables to pass to another place to use.
* I thoroughly generated these testcases in order to test all the possible branches in my code. This helped my pick out some bugs.

# What I have implemented
- [x] Declaration (Track the nonterminal `DeclareStmt` or use `testcases/declare.in` to test)
- [x] Assignment (Track the nonterminal `ExpressionStmt` or use `testcases/assignment.in` to test)
- [x] For loop
- [x] For loop condition with any complex expression
- [x] Nested for loop support
- [x] If statement
- [x] If statement with sophisticated logical expressions
- [x] Nested if statement support

# Copyright claim
These codes are fully implemented by myself.

# Appendix
## Target Assembly Language
* Variable Variable declaration instruction
    * Declare A, Integer
    * Declare A, Integer_array,20
    * Declare B, Float
    * Declare B, Float_array,20
* Arithmetic instruction
    * I_SUB i1,i2,t
    * I_ADD i1,i2,t
    * I_DIV i1,i2,t
    * I_MUL i1,i2,t
    * I_UMINUS i1,t
    * INC I
    * DEC I
* Type conversion instructions
    * IntToFloat i1, t 
    * FloatToInt f1, t
* Assignment
    * I_Store i1,t
    * I_Store i1,offset(t) (Store i1 into MEM[t + offset])
    * F_Store f1,t
    * I_Store f1,offset(t) (Store f1 into MEM[t + offset])
* Compare instruction
    * I_CMP i1,i2
    * F_CMP f1,f2
    * [I|F]_CMP_E x1, x2, t (equal to)
    * [I|F]_CMP_G x1, x2, t (greater than)
    * [I|F]_CMP_GE x1, x2, t (greater equal than)
    * [I|F]_CMP_L x1, x2, t (less than)
    * [I|F]_CMP_LE x1, x2, t (less equal than)
    * [I|F]_CMP_NE x1, x2, t (not equal to)
* Jump instruction
    * J,JE, JG, JGE, JL, JLE, JNE 
