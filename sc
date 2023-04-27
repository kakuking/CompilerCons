lex beta.l
yacc -d -v parser.y
gcc lex.yy.c y.tab.c -o main
./main input.c
