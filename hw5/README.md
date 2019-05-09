# Folder structure
```
.
├── G_3.txt (Figure 6.16 corresponding grammar)
├── README.md
├── first_follow.h
├── lr1.c 
└── output.txt(output of states)
```
# How to run
```
gcc -Wall lr1.c
./a.out < G_3.txt > output.txt
```

# Result
```
State: 0
<S> -> . <E> $, {|lambda|}
<E> -> . <E> + <T>, {$}
<E> -> . <T>, {$}
<E> -> . <E> + <T>, {+}
<E> -> . <T>, {+}
<T> -> . <T> * <P>, {$}
<T> -> . <P>, {$}
<T> -> . <T> * <P>, {+}
<T> -> . <P>, {+}
<T> -> . <T> * <P>, {*}
<T> -> . <P>, {*}
<P> -> . ID, {$}
<P> -> . ( <E> ), {$}
<P> -> . ID, {+}
<P> -> . ( <E> ), {+}
<P> -> . ID, {*}
<P> -> . ( <E> ), {*}
State: 1
<S> -> <E> . $, {|lambda|}
<E> -> <E> . + <T>, {$}
<E> -> <E> . + <T>, {+}
State: 3
<E> -> <E> + . <T>, {$}
<E> -> <E> + . <T>, {+}
<T> -> . <T> * <P>, {$}
<T> -> . <P>, {$}
<T> -> . <T> * <P>, {+}
<T> -> . <P>, {+}
<T> -> . <T> * <P>, {*}
<T> -> . <P>, {*}
<P> -> . ID, {$}
<P> -> . ( <E> ), {$}
<P> -> . ID, {+}
<P> -> . ( <E> ), {+}
<P> -> . ID, {*}
<P> -> . ( <E> ), {*}
```
