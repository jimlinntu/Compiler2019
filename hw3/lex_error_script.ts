Script started on 2019-04-08 16:27:06+0800
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/hw3$ make clean
rm hw3.c
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/hw3$ make 
lex -ohw3.c hw3.l
gcc -o hw3 hw3.c -lfl
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/hw3$ ./hw3 < lex_error_test.txt 
Token number=1(BEGIN), value is "begin"
Token number=34(DECLARE), value is "declare"
Token number=5(ID), value is "A"
Token number=13(COMMA), value is ","
Token number=5(ID), value is "I"
Token number=35(AS), value is "as"
Token number=36(INTEGER), value is "integer"
Token number=12(SEMICOL), value is ";"
Token number=34(DECLARE), value is "declare"
Token number=5(ID), value is "B"
Token number=13(COMMA), value is ","
Token number=5(ID), value is "C"
Token number=13(COMMA), value is ","
Token number=5(ID), value is "D"
Token number=13(COMMA), value is ","
Token number=5(ID), value is "size"
Token number=35(AS), value is "as"
Token number=37(REAL), value is "real"
Token number=12(SEMICOL), value is ";"
Token number=34(DECLARE), value is "declare"
Token number=5(ID), value is "P"
Token number=[0;31mERROR[0m, value is "$"
Token number=5(ID), value is "I"
Token number=12(SEMICOL), value is ";"
Token number=[0;31mERROR[0m, value is "@"
[*] Lexcial Errors at line 5:
 declare P$I;@
          [0;32m^[0m  [0;32m^[0m 
Token number=34(DECLARE), value is "declare"
Token number=5(ID), value is "LLL"
Token number=10(LPAREN), value is "("
Token number=6(INTLITERAL), value is "100"
Token number=11(RPAREN), value is ")"
Token number=35(AS), value is "AS"
Token number=37(REAL), value is "REAL"
Token number=12(SEMICOL), value is ";"
Token number=5(ID), value is "PI"
Token number=14(ASSIGNOP), value is ":="
Token number=7(FLTLITERAL), value is "3.1416"
Token number=12(SEMICOL), value is ";"
Token number=5(ID), value is "B"
Token number=14(ASSIGNOP), value is ":="
Token number=5(ID), value is "PI"
Token number=17(MULTOP), value is "*"
Token number=5(ID), value is "B"
Token number=17(MULTOP), value is "*"
Token number=5(ID), value is "B"
Token number=15(PLUSOP), value is "+"
Token number=5(ID), value is "C"
Token number=18(DIVOP), value is "/"
Token number=5(ID), value is "D"
Token number=15(PLUSOP), value is "+"
Token number=8(EXPFLTLITERAL), value is "0.345E-6"
Token number=12(SEMICOL), value is ";"
Token number=29(FOR), value is "FOR"
Token number=10(LPAREN), value is "("
Token number=5(ID), value is "I"
Token number=14(ASSIGNOP), value is ":="
Token number=6(INTLITERAL), value is "1"
Token number=30(TO), value is "TO"
Token number=6(INTLITERAL), value is "100"
Token number=11(RPAREN), value is ")"
Token number=5(ID), value is "C"
Token number=14(ASSIGNOP), value is ":="
Token number=5(ID), value is "LLL"
Token number=10(LPAREN), value is "("
Token number=5(ID), value is "I"
Token number=11(RPAREN), value is ")"
Token number=15(PLUSOP), value is "+"
Token number=5(ID), value is "B"
Token number=17(MULTOP), value is "*"
Token number=5(ID), value is "D"
Token number=16(MINUSOP), value is "-"
Token number=5(ID), value is "C"
Token number=12(SEMICOL), value is ";"
Token number=31(ENDFOR), value is "ENDFOR"
Token number=25(IF), value is "IF"
Token number=10(LPAREN), value is "("
Token number=5(ID), value is "C"
Token number=22(GEQ), value is ">="
Token number=6(INTLITERAL), value is "10000"
Token number=11(RPAREN), value is ")"
Token number=26(THEN), value is "THEN"
Token number=5(ID), value is "print"
Token number=10(LPAREN), value is "("
Token number=9(STRLITERAL), value is ""Good!""
Token number=11(RPAREN), value is ")"
Token number=12(SEMICOL), value is ";"
Token number=28(ENDIF), value is "ENDIF"
Token number=2(END), value is "end"
Token number=38(SCANEOF), value is "EOF"
End of the execution
ubuntu@ubuntu-VirtualBox:~/Desktop/ubuntuSharedFolder/hw3$ ext[Kit
exit

Script done on 2019-04-08 16:27:25+0800