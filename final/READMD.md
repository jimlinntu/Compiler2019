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

