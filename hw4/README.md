# Folder structure
```
.
├── README.md
├── micro.c
├── micro_grammar.txt
└── typescript.ts
```
# How to compile
```
gcc -Wall -O2 micro.c
```
# How to run
```
./a.out < micro_grammar.txt
```
# Result (also shown in `typescript.ts`)
```
first_set:
|<program>|: |begin|
|<statement list>|: |ID| |read| |write|
|<statement>|: |ID| |read| |write|
|<statement tail>|: |ID| |read| |write| |lambda|
|<expression>|: |ID| |(| |INTLIT|
|<id list>|: |ID|
|<expr list>|: |ID| |(| |INTLIT|
|<id tail>|: |,| |lambda|
|<expr tail>|: |,| |lambda|
|<primary>|: |ID| |(| |INTLIT|
|<primary tail>|: |+| |-| |lambda|
|<add op>|: |+| |-|
|<system goal>|: |begin|
======================
follow_set:
|<program>|: |$|
|<statement list>|: |end|
|<statement>|: |end| |ID| |read| |write|
|<statement tail>|: |end|
|<expression>|: |;| |)| |,|
|<id list>|: |)|
|<expr list>|: |)|
|<id tail>|: |)|
|<expr tail>|: |)|
|<primary>|: |;| |)| |,| |+| |-|
|<primary tail>|: |;| |)| |,|
|<add op>|: |ID| |(| |INTLIT|
|<system goal>|: |lambda|
======================
```
