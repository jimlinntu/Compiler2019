# Folder structure
```
.
├── Makefile
├── README.md
├── parser.y
├── scanner.l
├── test.in
└── test.out
```
# How to run
```
make all
```

# How to test
Environment: Ubuntu 18.04
```
diff <(./parser < test.in) test.out
```
