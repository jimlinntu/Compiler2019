Script started on 2019-04-29 08:52:51+0800
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/109_3$ gcc -Wall -[K-O2 micro.c
[01m[Kmicro.c:[m[K In function ‘[01m[Kscan_grammars[m[K’:
[01m[Kmicro.c:142:9:[m[K [01;35m[Kwarning: [m[Kignoring return value of ‘[01m[Kfgets[m[K’, declared with attribute warn_unused_result [[01;35m[K-Wunused-result[m[K]
         [01;35m[Kfgets(buf, MAXBUF, stdin)[m[K;
         [01;35m[K^~~~~~~~~~~~~~~~~~~~~~~~~[m[K
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/109_3$ ./a.out < micro_grammar.txt
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
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/109_3$ exit
exit

Script done on 2019-04-29 08:53:18+0800
