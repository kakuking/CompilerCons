%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    /*
    union {
        int num;
        float fnum;
        char* id;
        char* str;
        char chr;
    } YYSTYPE;
    */

    //YYSTYPE yylval;

    int yylex();

    void yyerror(char const *s){
        fprintf(stderr, "%s\n", s);
    }
%}
%union {
    int num;
    float fnum;
    char* id;
    char* str;
    char chr;
}
%token INT FLOAT CHAR STRING CHARLIT
%token IF ELSE FOR WHILE SWITCH CASE DEFAULT
%token PRINTF SCANF
%token <id> IDENTIFIER
%token <num> INTEGER FLOATING
%left '+' '-'
%left '*' '/'
%left UMINUS
%nonassoc '<' '>' LE GE EQ NE
%left AND
%left OR

%%

program: decl_list
       | decl
       ;

decl_list: decl_list decl
         | decl
         ;

decl: var_decl
    | func_decl
    ;

var_decl: type_spec var_list ';'
        ;

type_spec: INT
         | FLOAT
         | CHAR
         ;

var_list: var_list ',' var
        | var
        ;

var: IDENTIFIER
   | IDENTIFIER '['INTEGER']'
   ;

func_decl: type_spec IDENTIFIER '(' param_list ')' compound_stmt
         ;

param_list: param_list ',' param
          | param
          ;

param: type_spec IDENTIFIER
     | type_spec IDENTIFIER'['']'
     |
     ;

compound_stmt: '{' local_decl_list stmt_list '}'
             ;

local_decl_list: local_decl_list var_decl
               |
               ;

stmt_list: stmt_list statement
         |
         ;

statement: open_if_stmt
         | closed_if_stmt
         ;

open_if_stmt: IF '(' expr ')' statement
            | IF '(' expr ')' closed_if_stmt ELSE open_if_stmt
            ;

closed_if_stmt: IF '(' expr ')' closed_if_stmt ELSE closed_if_stmt
              | expr_stmt
              | compound_stmt
              | for_stmt
              | while_stmt
              | switch_stmt
              | print_stmt
              | scan_stmt
              ;


expr_stmt: expr ';'
         | ';'
         ;

for_stmt: FOR '(' expr_stmt expr_stmt expr ')' statement
        ;

while_stmt: WHILE '(' expr ')' statement
          ;
    
switch_stmt: SWITCH '(' expr ')' '{' case_list '}'
           ;

case_list: case_list case
         | case
         ;

case: CASE INTEGER ':' stmt_list
    | DEFAULT ':' stmt_list
    ;

print_stmt: PRINTF '(' STRING ',' arg_list ')' ';'
          | PRINTF '(' STRING ')' ';'
          ;

arg_list: arg_list ',' expr
        | expr
        ;

scan_stmt: SCANF '(' STRING ',' '&' IDENTIFIER ')' ';'
         ;

expr: IDENTIFIER '=' expr
    | IDENTIFIER '[' expr ']' '=' expr
    | logical_or_expr
    ;

logical_or_expr: logical_and_expr
               | logical_or_expr OR logical_and_expr
               ;
        
logical_and_expr: equality_expr
                | logical_and_expr AND equality_expr
                ;

equality_expr: relational_expr
             | equality_expr EQ relational_expr
             | equality_expr NE relational_expr
             ;

relational_expr: additive_expr
               | relational_expr '<' additive_expr
               | relational_expr '>' additive_expr
               | relational_expr LE additive_expr
               | relational_expr GE additive_expr
               %prec '<'
               ;

additive_expr: multiplicative_expr
             | additive_expr '+' multiplicative_expr
             | additive_expr '-' multiplicative_expr
             %prec '+'
             ;

multiplicative_expr: unary_expr
                   | multiplicative_expr '*' unary_expr
                   | multiplicative_expr '/' unary_expr
                   ;

unary_expr: postfix_expr
          | '-' unary_expr %prec UMINUS
          ;

postfix_expr: primary_expr
            | IDENTIFIER '(' arg_list ')'
            | postfix_expr '[' expr ']'
            ;

primary_expr: IDENTIFIER
            | INTEGER
            | FLOATING
            | CHARLIT
            | '(' expr ')'
            ;
%%

