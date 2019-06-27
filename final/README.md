# Folder Structure
```
.
├── Makefile
├── declare.ts (typescript file that record the output of `./parser < testcases/declare.in`)
├── parser.y
├── scanner.l
└── testcases
    ├── declare.in
    └── declare.out
```

# How to run
```
make
diff <(./parser < testcases/declare.in) testcases/declare.out
make clean
```

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
    * IntToFloat i1, t (type conversion)
    * FloatToInt f1, t (type conversion)
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
* Subroutine operation
    * CALL rn,a1,a2



## TODO
- [ ] Check `ID` memory leakage problem
- [ ] Make sure even when `yyerror` occurs, the compiler can still compile the following line

